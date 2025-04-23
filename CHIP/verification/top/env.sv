class top_env extends uvm_env;
	top_driver    driver;
	top_monitor   monitor;
	top_scoreboard sb;

	function void build_phase(uvm_phase phase);
	  driver  = top_driver::type_id::create("driver", this);
	  monitor = top_monitor::type_id::create("monitor", this);
	  sb      = top_scoreboard::type_id::create("sb", this);
	endfunction

	function void connect_phase(uvm_phase phase);
	  driver.seq_item_port.connect( sequencer.seq_item_export );
	  monitor.ap.connect( sb.sb_imp );
	endfunction
  endclass
