// Top-level TinyTapeout-HP wrapper (user module)
module tt_hp_um_aksp_mbist_mbisr (
    input wire clk,
    input wire rst,
    input wire start,
    output wire done,
    output wire fail
);
    top dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done),
        .fail(fail)
    );
endmodule
