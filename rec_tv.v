`timescale 1ns/1ps

module uart_recv_tb();

    reg            sys_clk;
    reg            sys_rst_n;
    reg            rec_en;
    reg            rec_din;

    wire [7:0] rec_dout;
    wire       rec_busy;


    uart_recv my_recv(
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .rec_en(rec_en),
        .rec_din(rec_din),

        .rec_dout(rec_dout),
        .rec_busy(rec_busy)
    );

    always #20 sys_clk = ~sys_clk;//50MHZ

    initial begin
        sys_clk = 1'b0;
        sys_rst_n = 1'b0;
        rec_en = 1'b0;
        #5 sys_rst_n = 1;

        rec_din = 1'b1;
        #15404 rec_din = 1'b0;
                rec_en = 1'b1;
        #50000 rec_din = 1'b1;
        #15404 rec_din = 1'b0;
        #15404 rec_din = 1'b0;
        #15404 rec_din = 1'b1;
        #15404 rec_din = 1'b1;
        #15404 rec_din = 1'b1;
        #15404 rec_din = 1'b1;
        #15404 rec_din = 1'b0;
        #15404 rec_din = 1'b0;
        #15404 rec_din = 1'b1;
        #15404 rec_din = 1'b0;
        #15404 rec_din = 1'b1;
    end



endmodule

