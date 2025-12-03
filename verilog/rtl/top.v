module top (
    input clk,
    input rst,
    input start,
    output done,
    output fail
);
    // MBIST instance wires
    wire mem_we_mbist;
    wire [7:0] mem_addr_mbist;
    wire [7:0] mem_wdata_mbist;
    wire [7:0] mem_rdata_mbist;
    wire fail_valid_mbist;
    wire [7:0] fail_addr_mbist;

    mbist_controller mbist0 (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done),
        .fail(fail),
        .fail_valid(fail_valid_mbist),
        .fail_addr(fail_addr_mbist),
        .mem_we(mem_we_mbist),
        .mem_addr(mem_addr_mbist),
        .mem_wdata(mem_wdata_mbist),
        .mem_rdata(mem_rdata_mbist)
    );

    // MBISR instance wires (user side left mostly unused in this demo)
    wire [7:0] user_rdata;
    wire [7:0] mem_addr_mbisr;
    wire [7:0] mem_wdata_mbisr;
    wire mem_we_mbisr;
    wire mem_en_mbisr;

    mbisr_controller #(.ADDR_WIDTH(8), .DATA_WIDTH(8), .MAX_REPAIRS(16), .SPARE_BASE(8'hF0)) mbisr0 (
        .clk(clk),
        .rst(rst),
        .bist_fail_valid(fail_valid_mbist),
        .bist_fail_addr(fail_addr_mbist),
        .user_addr(8'h00),
        .user_wdata(8'h00),
        .user_we(1'b0),
        .user_en(1'b0),
        .user_rdata(user_rdata),
        .mem_addr(mem_addr_mbisr),
        .mem_wdata(mem_wdata_mbisr),
        .mem_we(mem_we_mbisr),
        .mem_en(mem_en_mbisr),
        .mem_rdata(mem_rdata_mbist)
    );

    // For user-controlled fault injection: expose regs that TB can set hierarchically
    reg fault_en;
    reg [7:0] fault_addr;
    initial begin
        fault_en = 1'b0;
        fault_addr = 8'h00;
    end

    // Simple arbitration: MBIST drives the RAM; MBISR/user signals not used for writes in this demo.
    wire final_we = mem_we_mbist;
    wire [7:0] final_addr = mem_addr_mbist;
    wire [7:0] final_wdata = mem_wdata_mbist;
    wire final_en = mem_we_mbist; // MBIST always writes then reads

    // synchronous RAM
    reg [7:0] ram [0:255];
    reg [7:0] ram_out;
    integer i;
    initial begin
        for (i=0;i<256;i=i+1) ram[i] = 8'h00;
    end

    always @(posedge clk) begin
        if (final_en && final_we) begin
            ram[final_addr] <= final_wdata;
        end
        ram_out <= ram[final_addr];
    end

    // fault injection on read: if fault_en and address matches, force LSB = 0 (stuck-at-0 example)
    wire fault_match = fault_en && (final_addr == fault_addr);
    wire [7:0] mem_rdata_comb = fault_match ? {ram_out[7:1], 1'b0} : ram_out;

    assign mem_rdata_mbist = mem_rdata_comb;

    // expose the fault control regs for hierarchical access by testbench
    // In TB: DUT.dut.fault_en = 1; DUT.dut.fault_addr = 8;
endmodule
