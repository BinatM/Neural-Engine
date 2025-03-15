class mac_monitor;
    virtual mac_if vif;
    mailbox #(mac_item) mbx;

    function new(virtual mac_if vif, mailbox #(mac_item) mbx);
        this.vif = vif;
        this.mbx = mbx;
    endfunction

    task run();
        mac_item tr;
        forever begin
            #10;
            tr = new();
            tr.mac_out = vif.mac_out;  // Capture DUT output
            mbx.put(tr);  // Send result to mailbox
            $display("Monitor - MAC Output: %0d", tr.mac_out);
        end
    endtask
endclass
