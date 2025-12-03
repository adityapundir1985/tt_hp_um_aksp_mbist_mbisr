module mbist_controller (
    input        clk,
    input        rst,
    input        start,
    output reg   done,
    output reg   fail,
    output reg   fail_valid,
    output reg [7:0] fail_addr,

    output reg       mem_we,
    output reg [7:0] mem_addr,
    output reg [7:0] mem_wdata,
    input      [7:0] mem_rdata
);
    reg [3:0]  state;
    reg [7:0] addr;
    reg [7:0] expected;
    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state      <= 0;
            addr       <= 0;
            done       <= 0;
            fail       <= 0;
            fail_valid <= 0;
            mem_we     <= 0;
            mem_addr   <= 0;
            mem_wdata  <= 0;
            expected   <= 0;
        end else begin
            // default outputs
            fail_valid <= 0;
            mem_we <= 0;

            case (state)
                0: begin
                    if (start) begin
                        addr  <= 0;
                        done  <= 0;
                        fail  <= 0;
                        state <= 1;
                    end
                end

                1: begin // write 0
                    mem_we    <= 1;
                    mem_addr  <= addr;
                    mem_wdata <= 8'h00;
                    state     <= 2;
                end

                2: begin // read back
                    mem_we    <= 0;
                    mem_addr  <= addr;
                    expected  <= 8'h00;
                    state     <= 3;
                end

                3: begin // compare and move next
                    if (mem_rdata !== expected) begin
                        fail       <= 1;
                        fail_valid <= 1;
                        fail_addr  <= addr;
                    end
                    if (addr == 8'hFF) begin
                        state <= 4;
                    end else begin
                        addr  <= addr + 1;
                        state <= 1;
                    end
                end

                4: begin
                    done <= 1;
                    state <= 4;
                end
            endcase
        end
    end
endmodule
