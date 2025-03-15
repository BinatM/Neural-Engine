import mac_item::*;

class mac_driver;
    virtual mac_if vif;
    mailbox #(mac_item) mbx;

    function new(virtual mac_if vif, mailbox #(mac_item) mbx);
        this.vif = vif;
        this.mbx = mbx;
    endfunction

    task run();
        mac_item tr;
        forever begin
            mbx.get(tr);  // Get transaction from mailbox
            vif.img_in = tr.img_in;
            vif.weight_in = tr.weight_in;
            vif.mul_mem_en = tr.mul_mem_en;
            vif.ac_mem_en = tr.ac_mem_en;
            #10;  // Wait for clock cycle
        end
    endtask
endclass
