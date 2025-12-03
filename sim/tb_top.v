module tb_top;
    reg clk;
    reg rst;
    reg start;

    wire done;
    wire fail;

    // instantiate wrapper
    tt_hp_um_aksp_mbist_mbisr dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done),
        .fail(fail)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_top);

        rst = 1; start = 0;
        #20 rst = 0; #20;

        // inject a fault at address 8 (example) via hierarchical access
        // set regs inside top through the wrapper: dut.dut.fault_en = 1; dut.dut.fault_addr = 8;
        dut.dut.fault_en = 1;
        dut.dut.fault_addr = 8;

        // run MBIST
        start = 1; #10; start = 0;

        // wait for completion
        wait (done == 1);
        $display("MBIST complete. fail=%0d", fail);

        // change fault location and re-run
        #50;
        dut.dut.fault_en = 1;
        dut.dut.fault_addr = 42;

        start = 1; #10; start = 0;
        wait (done == 1);
        $display("MBIST second run complete. fail=%0d", fail);

        #100;
        $finish;
    end
endmodule
