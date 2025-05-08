-- Based on the work of Josh Basset https://github.com/nullobject/sdram-fpga
-- Modified to increase efficiency and flexibility by Tim Schulz

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

--! This controller is able to work with any burst length and any mode supported by the target SDRAM.
--! Currently burst termination is not supported! If it's configured to run in 8 burst mode, you have
--! to supply 8 words of data or read 8 words. If you have dynamically changing burst lengths,
--! configure it to run in single mode or bursts of 1.
--! You'll have to set most of the generics according to your target SDRAM. Please take a look at the hardware docs.

entity SDRAM_CONTROLLER is
  generic (
    ------------------------------------------------
    -- Block of parameters selectable by the user --
    ------------------------------------------------

    --! Frequency with which the SDRAM is operated. Used to calculate the delay counters.
    G_CLK_FREQ           : real      := 96.0;

    --! Delay in clock cycles between a read command and the output of valid data.
    G_CAS_LATENCY        : natural   := 2;

    --! Decides if the sdram is run in burst or single access mode.
    G_WRITE_BURST_MODE   : std_logic := '0'; -- 0=burst, 1=single

    --! If sdram is used in burst mode, this value sets the burst length. Otherwise it gets overridden to 1.
    G_BURST_LENGTH       : natural   := 8;

    --! Decides if the controller uses the auto precharge function. Auto precharge can cause unnecessary delays!
    G_USE_AUTO_PRECHARGE : std_logic := '0';

    --! The ordering of the accesses within a burst
    G_BURST_TYPE         : std_logic := '0'; -- 0=sequential, 1=interleaved

    ------------------------------------------------
    -- Block of parameters specified by the SDRAM --
    ------------------------------------------------

    --! Address width of the controller. Sum of row, col and bank width.
    G_ADDR_WIDTH         : natural;

    -- SDRAM interface
    --! Width of the sdram address register. Either row- or column register size, whichever is larger.
    G_SDRAM_ADDR_WIDTH   : natural;

    --! Width of the sdram data input.
    G_SDRAM_DATA_WIDTH   : natural;

    --! Width of the sdram column input.
    G_SDRAM_COL_WIDTH    : natural;

    --! Width of the sdram row input.
    G_SDRAM_ROW_WIDTH    : natural;

    --! Width of the sdram bank input.
    G_SDRAM_BANK_WIDTH   : natural;

    --! **Startup delay** - Time until the initilization cycle may begin after power up in ns.
    G_T_DESL             : real;

    --! **Mode register programm time** - Time needed to program the mode register at init in ns.
    G_T_MRD              : real;

    --! **row cycle time** - Time to wait between two active commands, two refresh commands or between refresh and active in ns.
    G_T_RC               : real;

    --! **RAS to CAS delay** - Time to wait between an active and a subsequent write/read command in ns.
    G_T_RCD              : real;             -- RAS to CAS delay

    --! **Precharge to active delay** - Time to wait after a precharge command in ns.
    G_T_RP               : real;             -- precharge to activate delay

    --! **Write recovery time** - Sometimes called t_dpl. Time to wait until precharge after the last write command in ns.
    G_T_WR               : real;

    --! **Refresh cycle time** - Time until the sdram needs a refresh in ns.
    G_T_REFI             : real
  );
  port (
    --! Low-active async reset input.
    I_RESET_N           : in    std_logic;

    --! clock
    I_CLOCK             : in    std_logic;

    --! **address bus** - Target for the next read or write command.
    I_ADDRESS           : in    unsigned(G_ADDR_WIDTH - 1 downto 0);

    --! **input data bus** - Data for the next write cycle. Not relevant if next cmd is a read.
    I_DATA              : in    std_logic_vector(G_SDRAM_DATA_WIDTH - 1 downto 0);

    --! When the request signal is asserted, an operation will be performed.
    I_REQUEST           : in    std_logic;

    --! When request is asserted, this signal decides if the next command is a read or write.
    I_WRITE_ENABLE      : in    std_logic;

    --! When acknowledge is asserted, the next address (and if it's a write the next data) was registered.
    O_ACKNOWLEDGE       : out   std_logic;

    --! The valid signal is asserted when there is a valid word at the output
    O_VALID             : out   std_logic;

    --! output data bus
    O_Q                 : out   std_logic_vector(G_SDRAM_DATA_WIDTH - 1 downto 0);

    -- SDRAM interface
    --! Address bus connected to the sdram.
    O_SDRAM_A           : out   unsigned(G_SDRAM_ADDR_WIDTH - 1 downto 0);

    --! bank bus connected to the sdram.
    O_SDRAM_BA          : out   unsigned(G_SDRAM_BANK_WIDTH - 1 downto 0);

    --! Data bus connected to the sdram.
    IO_SDRAM_DQ         : inout std_logic_vector(G_SDRAM_DATA_WIDTH - 1 downto 0);

    --! Clock enable signal connected to the sdram.
    O_SDRAM_CKE         : out   std_logic;

    --! Chip select signal connected to the sdram.
    O_SDRAM_CS          : out   std_logic;

    --! Row address strobe signal connected to the sdram.
    O_SDRAM_RAS         : out   std_logic;

    --! Column address strobe signal connected to the sdram.
    O_SDRAM_CAS         : out   std_logic;

    --! Write enable signal connected to the sdram.
    O_SDRAM_WE          : out   std_logic;

    --! dqml signal connected to the sdram.
    O_SDRAM_DQML        : out   std_logic;

    --! dqmh signal connected to the sdram.
    O_SDRAM_DQMH        : out   std_logic;

    --! indicates if the initilization process is done.
    O_SDRAM_INITIALIZED : out   std_logic
  );
end entity SDRAM_CONTROLLER;

architecture ARCH of SDRAM_CONTROLLER is

  -- To make sure the controller still works in single burst mode, we override the burst length and replace it by 1.
  -- This function is used to decide if an override is needed.

  function decide_burst_length (write_burst_mode_a : std_logic; burst_length_a: natural) return natural is
  begin

    if (write_burst_mode_a = '1') then
      return 1;
    else
      return burst_length_a;
    end if;

  end function;

  subtype t_command is std_logic_vector(3 downto 0);

  --! Defines the states of the state machine.

  type t_state is (INIT, MODE, IDLE, ACTIVE, READ, WRITE, REFRESH, PRECHARGE, WRITE_RECOVERY, READ_RECOVERY);

  -- commands
  --! Combination of chip select, row address strobe, column address strobe and write enable to initiate a deselect command.
  constant c_cmd_deselect             : t_command := "1---";

  --! Combination of chip select, row address strobe, column address strobe and write enable to initiate a load mode command.
  constant c_cmd_load_mode            : t_command := "0000";

  --! Combination of chip select, row address strobe, column address strobe and write enable to initiate an auto refresh command.
  constant c_cmd_auto_refresh         : t_command := "0001";

  --! Combination of chip select, row address strobe, column address strobe and write enable to initiate a precharge command.
  constant c_cmd_precharge            : t_command := "0010";

  --! Combination of chip select, row address strobe, column address strobe and write enable to initiate an active command.
  constant c_cmd_active               : t_command := "0011";

  --! Combination of chip select, row address strobe, column address strobe and write enable to initiate a write command.
  constant c_cmd_write                : t_command := "0100";

  --! Combination of chip select, row address strobe, column address strobe and write enable to initiate a read command.
  constant c_cmd_read                 : t_command := "0101";

  --! Combination of chip select, row address strobe, column address strobe and write enable to initiate a burst stop command.
  constant c_cmd_stop                 : t_command := "0110";

  --! Combination of chip select, row address strobe, column address strobe and write enable to initiate a nop command.
  constant c_cmd_nop                  : t_command := "0111";

  constant c_calculated_burst_length  : natural := decide_burst_length(G_WRITE_BURST_MODE, G_BURST_LENGTH);

  -- the value written to the mode register to configure the memory
  constant c_mode_reg                 : unsigned(G_SDRAM_ADDR_WIDTH - 1 downto 0) := (
                                                                                       "000" &
                                                                                       G_WRITE_BURST_MODE &
                                                                                       "00" &
                                                                                       to_unsigned(G_CAS_LATENCY, 3) &
                                                                                       G_BURST_TYPE &
                                                                                       to_unsigned(natural(ceil(log2(real(c_calculated_burst_length)))), 3)
                                                                                     );

  --! Calculated clock period based on the clock frequency.
  constant c_clk_period               : real := 1.0 / G_CLK_FREQ * 1000.0;

  --! The number of clock cycles to wait before initialising the device.
  constant c_init_wait                : natural := natural(ceil(G_T_DESL / c_clk_period));

  --! The number of clock cycles to wait while a LOAD MODE command is being executed
  constant c_load_mode_wait           : natural := natural(ceil(G_T_MRD / c_clk_period));

  --! The number of clock cycles to wait while an ACTIVE command is being executed
  constant c_active_wait              : natural := natural(ceil(G_T_RCD / c_clk_period));

  --! The number of clock cycles to wait while a REFRESH command is being executed
  constant c_refresh_wait             : natural := natural(ceil(G_T_RC / c_clk_period));

  --! The number of clock cycles to wait while a PRECHARGE command is being executed
  constant c_precharge_wait           : natural := natural(ceil(G_T_RP / c_clk_period));

  --! The number of clock cycles to wait while a READ command is being executed
  constant c_read_wait                : natural := G_CAS_LATENCY + c_calculated_burst_length;

  --! The number of clock cycles to wait after the last write command was issued until precharge
  constant c_recovery_wait            : natural := natural(ceil((G_T_WR) / c_clk_period));

  --! The number of clock cycles to wait while a WRITE command is being executed
  constant c_write_wait               : natural := c_calculated_burst_length + natural(ceil((G_T_WR + G_T_RP) / c_clk_period));

  --! The number of clock cycles before the memory controller needs to refresh the SDRAM
  constant c_refresh_interval         : natural := natural(floor(G_T_REFI / c_clk_period)) - 10;

  --! Bitmask for setting the A10 autoprecharge (or not)
  constant c_a10_bitmask              : unsigned(G_SDRAM_ADDR_WIDTH - 1 downto 0) := (10 => G_USE_AUTO_PRECHARGE, others => '0');

  --! All zero vector to append to the column address. Needed to combine the auto precharge setting with the column.
  constant c_bitmask_padding          : unsigned(G_SDRAM_ADDR_WIDTH - G_SDRAM_COL_WIDTH - 1 downto 0) := (others => '0');

  -- control signals
  --! Indicates if the needed number of cycles after issuing the load mode cmd is over.
  signal w_load_mode_done             : std_logic;

  --! Indicates if the needed number of cycles after issuing the active cmd is over.
  signal w_active_done                : std_logic;

  --! Indicates if the needed number of cycles after issuing the refresh cmd is over.
  signal w_refresh_done               : std_logic;

  --! Indicates if the current read burst is over. If auto precharge is on it indicates that the next active cmd can be issued.
  signal w_read_done                  : std_logic;

  --! Indicates if the current write burst is over. It also indicates that the next active cmd can be issued.
  signal w_write_done                 : std_logic;

  --! Indicates if the current write burst is over.
  signal w_write_done_no_ap           : std_logic;

  --! Indicates if the needed number of cycles after issuing the last write command is over.
  signal w_write_recovery_done        : std_logic;

  --! Indicates if the needed number of cycles after issuing the precharge cmd is over.
  signal w_precharge_done             : std_logic;

  --! Indicates if the number of cycles until the next refresh is needed is over.
  signal w_should_refresh             : std_logic;

  --! Next address to load into the register based on the current state and input address.
  signal w_next_address               : unsigned(G_SDRAM_ADDR_WIDTH - 1 downto 0);

  --! Next bank to load into the register based on the current state and input address.
  signal w_next_bank                  : unsigned(G_SDRAM_BANK_WIDTH - 1 downto 0);

  --! Next data to load into the register based on the current state and input data.
  signal w_next_data                  : std_logic_vector(G_SDRAM_DATA_WIDTH - 1 downto 0);

  --! Next valid indicator to load into the flip flop based on the current valid shifter state.
  signal w_next_ack                   : std_logic;

  --! Indicates if the currently opened row is the same as the row of the next requested address.
  signal w_next_and_current_row_equal : std_logic;

  --! Next command to issue based on the current state and inputs.
  signal w_next_cmd                   : t_command;

  --! Decoded column based on the currently pending address.
  signal w_col                        : unsigned(G_SDRAM_ADDR_WIDTH - 1 downto 0);

  --! Decoded row based on the currently pending address.
  signal w_row                        : unsigned(G_SDRAM_ROW_WIDTH - 1 downto 0);

  --! Decoded bank based on the currently pending address.
  signal w_bank                       : unsigned(G_SDRAM_BANK_WIDTH - 1 downto 0);

  --! Next pending state
  signal w_next_state                 : t_state;

  --! Current state.
  signal r_state                      : t_state := INIT;

  --! Currently running command.
  signal r_cmd                        : t_command := c_cmd_nop;

  --! Stores the number of cycles since the last state change.
  signal r_wait_counter               : natural range 0 to c_init_wait + 100 := 0;

  --! Stores the number of cycles since the last refresh.
  signal r_refresh_counter            : natural range 0 to c_refresh_interval + 100 := 0;

  --! Stores the number of output data in the current burst.
  signal r_pending_data_count_dq      : natural range 0 to 20 := 0;

  --! Stores the number of burst left .
  signal r_pending_burst_count        : natural range 0 to 20 := 0;

  --! Stores the last loaded row.
  signal r_recent_row                 : unsigned(G_SDRAM_ROW_WIDTH - 1 downto 0) := (others => '0');

  --! Stores the state of the valid shift register.
  signal r_valid_shift                : std_logic_vector(G_CAS_LATENCY downto 0) := (others => '0');

  --! Stores the currently loaded address that will be forwarded to the sdram.
  signal r_address                    : unsigned(G_SDRAM_ADDR_WIDTH - 1 downto 0) := (others => '0');

  --! Stores the currently loaded addbankress that will be forwarded to the sdram.
  signal r_bank                       : unsigned(G_SDRAM_BANK_WIDTH - 1 downto 0) := (others => '0');

  --! Stores the data that will be forwarded to the sdram.
  signal r_dq                         : std_logic_vector(G_SDRAM_DATA_WIDTH - 1 downto 0) := (others => '0');

  --! Stores the data that will be forwarded to the data output.
  signal r_q                          : std_logic_vector(G_SDRAM_DATA_WIDTH - 1 downto 0) := (others => '0');

  --! Stores the valid state that will be forwarded to o_valid.
  signal r_valid                      : std_logic := '0';

  --! Stores the current state of the clock enable signal that will be forwarded to the sdram.
  signal r_cke                        : std_logic := '0';

  attribute keep : boolean;
  attribute noprune : boolean;
  attribute keep of w_next_and_current_row_equal : signal is true;

begin

  -- state machine
  STATE_TRANSITION : process (r_pending_data_count_dq, w_bank, I_DATA, w_col, w_next_and_current_row_equal, r_state, r_wait_counter, I_REQUEST, w_load_mode_done, w_active_done, w_refresh_done, w_read_done, w_write_done, w_should_refresh, w_precharge_done, w_write_done_no_ap, r_recent_row, I_WRITE_ENABLE, w_write_recovery_done, w_row) is
  begin

    case r_state is

      -- execute the initialisation sequence
      when INIT =>

        if (r_wait_counter = c_init_wait + c_precharge_wait + c_refresh_wait + c_refresh_wait) then
          w_next_state <= MODE;
        else
          w_next_state <= INIT;
        end if;

        w_next_address <= "0010000000000";
        w_next_ack     <= '0';
        w_next_bank    <= (others => '0');
        w_next_data    <= (others => 'Z');

        if (r_wait_counter = 0) then
          w_next_cmd <= c_cmd_deselect;
        elsif (r_wait_counter = c_init_wait) then
          w_next_cmd <= c_cmd_precharge;
        elsif (r_wait_counter = c_init_wait + c_precharge_wait) then
          w_next_cmd <= c_cmd_auto_refresh;
        elsif (r_wait_counter = c_init_wait + c_precharge_wait + c_refresh_wait) then
          w_next_cmd <= c_cmd_auto_refresh;
        -- next state mode
        elsif (r_wait_counter = c_init_wait + c_precharge_wait + c_refresh_wait + c_refresh_wait) then
          w_next_cmd     <= c_cmd_load_mode;
          w_next_address <= c_mode_reg;
        else
          w_next_cmd <= c_cmd_nop;
        end if;

      -- load the mode register
      when MODE =>

        if (w_load_mode_done = '1') then
          w_next_state <= IDLE;
        else
          w_next_state <= MODE;
        end if;

        w_next_address <= (others => '0');
        w_next_ack     <= '0';
        w_next_bank    <= (others => '0');
        w_next_cmd     <= c_cmd_nop;
        w_next_data    <= (others => 'Z');

      -- wait for a read/write request
      when IDLE =>

        if (w_should_refresh = '1') then
          w_next_state   <= REFRESH;
          w_next_cmd     <= c_cmd_auto_refresh;
          w_next_address <= (others => '0');
          w_next_bank    <= (others => '0');
          w_next_ack     <= '0';
          w_next_data    <= (others => 'Z');
        elsif (I_REQUEST = '1') then
          w_next_state   <= ACTIVE;
          w_next_ack     <= '0';
          w_next_cmd     <= c_cmd_active;
          w_next_address <= w_row;
          w_next_bank    <= w_bank;
          w_next_data    <= (others => 'Z');
        else
          w_next_state   <= IDLE;
          w_next_cmd     <= c_cmd_nop;
          w_next_ack     <= '0';
          w_next_address <= (others => '0');
          w_next_bank    <= (others => '0');
          w_next_data    <= (others => 'Z');
        end if;

      -- activate the row
      when ACTIVE =>

        if (w_active_done = '1') then
          if (I_WRITE_ENABLE = '1') then
            w_next_state   <= WRITE;
            w_next_ack     <= '1';
            w_next_cmd     <= c_cmd_write;
            w_next_data    <= I_DATA;
            w_next_address <= w_col;
            w_next_bank    <= w_bank;
          else
            w_next_state   <= READ;
            w_next_ack     <= '1';
            w_next_cmd     <= c_cmd_read;
            w_next_data    <= (others => 'Z');
            w_next_address <= w_col;
            w_next_bank    <= w_bank;
          end if;
        else
          w_next_state   <= ACTIVE;
          w_next_ack     <= '0';
          w_next_cmd     <= c_cmd_nop;
          w_next_address <= w_row;
          w_next_bank    <= w_bank;
          w_next_data    <= (others => 'Z');
        end if;

      -- execute a read command
      when READ =>

        case G_USE_AUTO_PRECHARGE is

          when '1' =>

            if (w_read_done = '1') then
              if (w_should_refresh = '1') then
                w_next_state   <= REFRESH;
                w_next_cmd     <= c_cmd_auto_refresh;
                w_next_address <= (others => '0');
                w_next_bank    <= (others => '0');
                w_next_ack     <= '0';
                w_next_data    <= (others => 'Z');
              elsif (I_REQUEST = '1') then
                w_next_state   <= ACTIVE;
                w_next_ack     <= '0';
                w_next_cmd     <= c_cmd_active;
                w_next_bank    <= w_bank;
                w_next_address <= w_row;
                w_next_data    <= (others => 'Z');
              else
                w_next_state   <= IDLE;
                w_next_cmd     <= c_cmd_nop;
                w_next_ack     <= '0';
                w_next_address <= (others => '0');
                w_next_bank    <= (others => '0');
                w_next_data    <= (others => 'Z');
              end if;
            else
              w_next_state   <= READ;
              w_next_cmd     <= c_cmd_nop;
              w_next_address <= w_col;
              w_next_bank    <= w_bank;
              w_next_ack     <= '0';
              w_next_data    <= (others => 'Z');
            end if;

          when '0' =>

            if (w_read_done = '1') then
              if (I_REQUEST = '1' and w_next_and_current_row_equal = '1' and w_should_refresh = '0') then
                if (I_WRITE_ENABLE = '1') then
                  -- we can't go directly to the write state, we have to empty out the rest of the data.
                  w_next_state   <= READ_RECOVERY;
                  w_next_cmd     <= c_cmd_nop;
                  w_next_ack     <= '0';
                  w_next_address <= (others => '0');
                  w_next_bank    <= (others => '0');
                  w_next_data    <= (others => 'Z');
                else
                  w_next_state   <= READ;
                  w_next_ack     <= '1';
                  w_next_cmd     <= c_cmd_read;
                  w_next_address <= w_col;
                  w_next_bank    <= w_bank;
                  w_next_data    <= (others => 'Z');
                end if;
              else
                -- if the number of pending data is bigger than the needed precharge (wait) cycles
                -- we need to add additional read recovery cycles to empty out the surplus data
                if (c_precharge_wait < r_pending_data_count_dq) then
                  w_next_state   <= READ_RECOVERY;
                  w_next_cmd     <= c_cmd_nop;
                  w_next_ack     <= '0';
                  w_next_address <= (others => '0');
                  w_next_bank    <= (others => '0');
                  w_next_data    <= (others => 'Z');
                -- if the number of pending data is smaller or equals the needed precharge cycles,
                -- we can go directly to precharge to save time.
                else
                  w_next_state   <= PRECHARGE;
                  w_next_cmd     <= c_cmd_precharge;
                  w_next_ack     <= '0';
                  w_next_address <= (others => '0');
                  w_next_bank    <= (others => '0');
                  w_next_data    <= (others => 'Z');
                end if;
              end if;
            else
              w_next_state   <= READ;
              w_next_cmd     <= c_cmd_nop;
              w_next_address <= w_col;
              w_next_bank    <= w_bank;
              w_next_ack     <= '0';
              w_next_data    <= (others => 'Z');
            end if;

        end case;

      -- empty
      when READ_RECOVERY =>

        -- if we have to refresh or there is no subsequent write request, we don't have to output all data before precharge.
        -- The last data can be read out at precharge.
        if ((w_should_refresh = '1' or (I_REQUEST = '1' and I_WRITE_ENABLE = '0') or I_REQUEST = '0') and r_pending_data_count_dq <= c_precharge_wait) then
          w_next_state   <= PRECHARGE;
          w_next_cmd     <= c_cmd_precharge;
          w_next_ack     <= '0';
          w_next_address <= (others => '0');
          w_next_bank    <= (others => '0');
          w_next_data    <= (others => 'Z');

        -- if we have a subsequent write request we have to empty out the data pipeline before going from HIGH-Z to write
        elsif (r_pending_data_count_dq = 0 and I_REQUEST = '1' and I_WRITE_ENABLE = '1') then
          w_next_state   <= WRITE;
          w_next_ack     <= '1';
          w_next_cmd     <= c_cmd_write;
          w_next_address <= w_col;
          w_next_bank    <= w_bank;
          w_next_data    <= I_DATA;
        else
          w_next_state   <= READ_RECOVERY;
          w_next_cmd     <= c_cmd_nop;
          w_next_address <= (others => '0');
          w_next_bank    <= (others => '0');
          w_next_ack     <= '0';
          w_next_data    <= (others => 'Z');
        end if;

      -- execute a write command
      when WRITE =>

        case G_USE_AUTO_PRECHARGE is

          when '1' =>

            if (w_write_done = '1') then
              if (w_should_refresh = '1') then
                w_next_state   <= REFRESH;
                w_next_cmd     <= c_cmd_auto_refresh;
                w_next_address <= (others => '0');
                w_next_bank    <= (others => '0');
                w_next_data    <= (others => 'Z');
                w_next_ack     <= '0';
              elsif (I_REQUEST = '1') then
                w_next_state   <= ACTIVE;
                w_next_ack     <= '0';
                w_next_cmd     <= c_cmd_active;
                w_next_address <= w_row;
                w_next_bank    <= w_bank;
                w_next_data    <= (others => 'Z');
              else
                w_next_state   <= IDLE;
                w_next_cmd     <= c_cmd_nop;
                w_next_ack     <= '0';
                w_next_address <= (others => '0');
                w_next_bank    <= (others => '0');
                w_next_data    <= (others => 'Z');
              end if;
            else
              w_next_state   <= WRITE;
              w_next_cmd     <= c_cmd_nop;
              w_next_address <= w_col;
              w_next_bank    <= w_bank;
              w_next_data    <= I_DATA;
              w_next_ack     <= '0';
            end if;

          when '0' =>

            if (w_write_done_no_ap = '1') then
              if (I_REQUEST = '1' and w_next_and_current_row_equal = '1' and w_should_refresh = '0') then
                if (I_WRITE_ENABLE = '1') then
                  w_next_state   <= WRITE;
                  w_next_ack     <= '1';
                  w_next_cmd     <= c_cmd_write;
                  w_next_address <= w_col;
                  w_next_bank    <= w_bank;
                  w_next_data    <= I_DATA;
                else
                  w_next_state   <= READ;
                  w_next_ack     <= '1';
                  w_next_cmd     <= c_cmd_read;
                  w_next_address <= w_col;
                  w_next_bank    <= w_bank;
                  w_next_data    <= (others => 'Z');
                end if;
              else
                w_next_state   <= WRITE_RECOVERY;
                w_next_cmd     <= c_cmd_nop;
                w_next_ack     <= '0';
                w_next_address <= (others => '0');
                w_next_bank    <= (others => '0');
                w_next_data    <= (others => 'Z');
              end if;
            else
              w_next_state   <= WRITE;
              w_next_cmd     <= c_cmd_nop;
              w_next_address <= w_col;
              w_next_bank    <= w_bank;
              w_next_data    <= I_DATA;
              w_next_ack     <= '0';
            end if;

        end case;

      when WRITE_RECOVERY =>

        if (w_write_recovery_done = '1') then
          w_next_state   <= PRECHARGE;
          w_next_cmd     <= c_cmd_precharge;
          w_next_ack     <= '0';
          w_next_address <= (others => '0');
          w_next_bank    <= (others => '0');
          w_next_data    <= (others => 'Z');
        else
          w_next_state   <= WRITE_RECOVERY;
          w_next_cmd     <= c_cmd_nop;
          w_next_ack     <= '0';
          w_next_address <= (others => '0');
          w_next_bank    <= (others => '0');
          w_next_data    <= (others => 'Z');
        end if;

      -- execute an auto refresh
      when REFRESH =>

        if (w_refresh_done = '1') then
          if (I_REQUEST = '1') then
            w_next_state   <= ACTIVE;
            w_next_ack     <= '0';
            w_next_cmd     <= c_cmd_active;
            w_next_address <= w_row;
            w_next_bank    <= w_bank;
            w_next_data    <= (others => 'Z');
          else
            w_next_state   <= IDLE;
            w_next_cmd     <= c_cmd_nop;
            w_next_ack     <= '0';
            w_next_address <= (others => '0');
            w_next_bank    <= (others => '0');
            w_next_data    <= (others => 'Z');
          end if;
        else
          w_next_state   <= REFRESH;
          w_next_cmd     <= c_cmd_nop;
          w_next_ack     <= '0';
          w_next_address <= (others => '0');
          w_next_bank    <= (others => '0');
          w_next_data    <= (others => 'Z');
        end if;

      -- execute a precharge
      when PRECHARGE =>

        if (w_precharge_done = '1') then
          if (w_should_refresh = '1') then
            w_next_state   <= REFRESH;
            w_next_cmd     <= c_cmd_auto_refresh;
            w_next_address <= (others => '0');
            w_next_bank    <= (others => '0');
            w_next_data    <= (others => 'Z');
            w_next_ack     <= '0';
          elsif (I_REQUEST = '1') then
            w_next_state   <= ACTIVE;
            w_next_ack     <= '0';
            w_next_cmd     <= c_cmd_active;
            w_next_address <= w_row;
            w_next_bank    <= w_bank;
            w_next_data    <= (others => 'Z');
          else
            w_next_state   <= IDLE;
            w_next_cmd     <= c_cmd_nop;
            w_next_ack     <= '0';
            w_next_address <= (others => '0');
            w_next_bank    <= (others => '0');
            w_next_data    <= (others => 'Z');
          end if;
        else
          w_next_state   <= PRECHARGE;
          w_next_cmd     <= c_cmd_nop;
          w_next_address <= (others => '0');
          w_next_bank    <= (others => '0');
          w_next_data    <= (others => 'Z');
          w_next_ack     <= '0';
        end if;

    end case;

  end process STATE_TRANSITION;

  -- store the next state
  FF_NEXT_STATE : process (I_CLOCK, I_RESET_N) is
  begin

    if (I_RESET_N = '0') then
      r_state <= INIT;
    elsif rising_edge(I_CLOCK) then
      r_state <= w_next_state;
    end if;

  end process FF_NEXT_STATE;

  -- Stores the pending command, address and data into the corresponding registers.
  OUTPUT_REGISTERS : process (I_CLOCK, I_RESET_N) is
  begin

    if (I_RESET_N = '0') then
      r_cmd     <= c_cmd_deselect;
      r_address <= (others => '0');
      r_dq      <= (others => 'Z');
      r_q       <= (others => '0');
      r_bank    <= (others => '0');
      r_valid   <= '0';
    elsif (rising_edge(I_CLOCK)) then
      r_cmd     <= w_next_cmd;
      r_address <= w_next_address;
      r_dq      <= w_next_data;
      r_q       <= IO_SDRAM_DQ;
      r_bank    <= w_next_bank;
      r_valid   <= r_valid_shift(r_valid_shift'left);

      if (r_state = INIT and r_wait_counter = 0) then
        r_cke <= '0';
      else
        r_cke <= '1';
      end if;
    end if;

  end process OUTPUT_REGISTERS;

  -- Store the last loaded row
  FF_RECENT_ROW : process (I_CLOCK, I_RESET_N) is
  begin

    if (I_RESET_N = '0') then
      r_recent_row <= (others => '0');
    elsif (rising_edge(I_CLOCK)) then
      if (r_cmd = c_cmd_active) then
        r_recent_row <= w_row;
      end if;
    end if;

  end process FF_RECENT_ROW;

  -- This counter counts the number of cycles since we entered the current state.
  UPDATE_WAIT_COUNTER : process (I_CLOCK, I_RESET_N) is
  begin

    if (I_RESET_N = '0') then
      r_wait_counter <= 0;
    elsif rising_edge(I_CLOCK) then
      if (r_state /= w_next_state) then -- state changing
        r_wait_counter <= 0;
      else
        r_wait_counter <= r_wait_counter + 1;
      end if;
    end if;

  end process UPDATE_WAIT_COUNTER;

  -- This counter counts the number of cycles since the last refresh.
  UPDATE_REFRESH_COUNTER : process (I_CLOCK, I_RESET_N) is
  begin

    if (I_RESET_N = '0') then
      r_refresh_counter <= 0;
    elsif rising_edge(I_CLOCK) then
      if (r_state = REFRESH and r_wait_counter = 0) then
        r_refresh_counter <= 0;
      else
        r_refresh_counter <= r_refresh_counter + 1;
      end if;
    end if;

  end process UPDATE_REFRESH_COUNTER;

  -- Counts the number of bursts left
  BURST_COUNTER : process (I_CLOCK, I_RESET_N) is
  begin

    if (I_RESET_N = '0') then
      r_pending_burst_count <= 0;
    elsif (rising_edge(I_CLOCK)) then
      -- A new read command was initiated thus we have to start the burst counter.
      if (w_next_cmd = c_cmd_read or w_next_cmd = c_cmd_write) then
        r_pending_burst_count <= c_calculated_burst_length - 1;
      elsif (r_pending_burst_count > 0) then
        r_pending_burst_count <= r_pending_burst_count - 1;
      end if;
    end if;

  end process BURST_COUNTER;

  -- Counts the number of data left in the current burst.
  -- This count is used to decide what value to push into the valid shift register.
  DQ_DATA_PENDING_COUNTER : process (I_CLOCK, I_RESET_N) is
  begin

    if (I_RESET_N = '0') then
      r_pending_data_count_dq <= 0;
    elsif (rising_edge(I_CLOCK)) then
      -- There is no new read command but valid data at dq
      if (w_next_cmd /= c_cmd_read and r_valid_shift(r_valid_shift'left - 1) = '1' and r_pending_data_count_dq > 0) then
        r_pending_data_count_dq <= r_pending_data_count_dq - 1;

      -- There is a new read command and data in the pipeline.
      -- In this case we have to subtract one extra number because
      -- there is valid data at dq at the same time
      elsif (w_next_cmd = c_cmd_read and r_valid_shift(r_valid_shift'left - 1) = '1') then
        r_pending_data_count_dq <= r_pending_data_count_dq + c_calculated_burst_length - 1;
      -- We don't have valid data at dq yet.
      elsif (w_next_cmd = c_cmd_read and r_valid_shift(r_valid_shift'left - 1) = '0') then
        r_pending_data_count_dq <= r_pending_data_count_dq + c_calculated_burst_length;
      end if;
    end if;

  end process DQ_DATA_PENDING_COUNTER;

  -- Models the shift register that pushes ones to the valid output.
  VALID_SHIFTER : process (I_CLOCK, I_RESET_N) is
  begin

    if (I_RESET_N = '0') then
      r_valid_shift <= (others => '0');
    elsif (rising_edge(I_CLOCK)) then

      for k in G_CAS_LATENCY downto 1 loop

        r_valid_shift(k) <= r_valid_shift(k - 1);

      end loop;

      -- If the next command is an actual read or the currently running burst is a read burst,
      -- we need to push the next 1 to the register.
      if (w_next_cmd = c_cmd_read or (r_valid_shift(r_valid_shift'right) = '1' and r_pending_burst_count > 0)) then
        r_valid_shift(0) <= '1';
      else
        r_valid_shift(0) <= '0';
      end if;
    end if;

  end process VALID_SHIFTER;

  ---------------------
  -- Done indicators --
  ---------------------
  w_write_done <= '1' when r_wait_counter = c_write_wait - 1 else
                  '0';

  w_write_done_no_ap <= '1' when r_pending_burst_count = 0 else
                        '0';

  w_precharge_done <= '1' when r_wait_counter = c_precharge_wait - 1 else
                      '0';

  w_write_recovery_done <= '1' when r_wait_counter = c_recovery_wait - 1 else
                           '0';

  w_load_mode_done <= '1' when r_wait_counter = c_load_mode_wait - 1 else
                      '0';
  w_active_done    <= '1' when r_wait_counter = c_active_wait - 1 else
                      '0';
  w_refresh_done   <= '1' when r_wait_counter = c_refresh_wait - 1 else
                      '0';

  w_read_done <= '1' when (G_USE_AUTO_PRECHARGE = '1' and r_wait_counter = c_read_wait - 1)
                          or (G_USE_AUTO_PRECHARGE = '0' and r_pending_burst_count = 0) else
                 '0';

  -----------------------
  -- Refresh indicator --
  -----------------------
  w_should_refresh <= '1' when r_refresh_counter >= c_refresh_interval - 1 else
                      '0';

  ----------------------
  -- Address decoders --
  ----------------------
  w_col  <= c_a10_bitmask or c_bitmask_padding & I_ADDRESS(G_SDRAM_COL_WIDTH - 1 downto 0);
  w_bank <= I_ADDRESS(G_SDRAM_COL_WIDTH + G_SDRAM_ROW_WIDTH + G_SDRAM_BANK_WIDTH - 1 downto G_SDRAM_COL_WIDTH + G_SDRAM_ROW_WIDTH);
  w_row  <= I_ADDRESS(G_SDRAM_COL_WIDTH + G_SDRAM_ROW_WIDTH - 1 downto G_SDRAM_COL_WIDTH);

  --------------------
  -- Row comparator --
  --------------------
  w_next_and_current_row_equal <= '1' when w_row = r_recent_row else
                                  '0';

  ---------------------------------------------------------------------
  -- Connect output registers with the corresponding sdram interface --
  ---------------------------------------------------------------------
  (o_sdram_cs, o_sdram_ras, o_sdram_cas, o_sdram_we) <= r_cmd;
  O_SDRAM_DQMH                                       <= '0';
  O_SDRAM_DQML                                       <= '0';
  O_ACKNOWLEDGE                                      <= w_next_ack;
  O_SDRAM_A                                          <= r_address;
  IO_SDRAM_DQ                                        <= r_dq;
  O_Q                                                <= r_q;
  O_SDRAM_BA                                         <= r_bank;
  O_VALID                                            <= r_valid;
  O_SDRAM_CKE                                        <= r_cke;
  O_SDRAM_INITIALIZED                                <= '0' when r_state = INIT or r_state = MODE else
                                                        '1';

end architecture ARCH;
