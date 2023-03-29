`timescale 1ns/1ps

module zynq_loop_tb;


    reg            sys_clk;
    reg            sys_rst_n;
    reg            tx_en;
    reg            rec_din;
    reg            rec_en;

    wire         tx_dout;
    wire         tx_busy;
    wire         rec_busy;

    parameter  CLK_FREQ = 50000000;
    parameter  UART_BPS = 115200;

    always #20 sys_clk = ~ sys_clk;
    always #174000 rec_din = $random;

    initial begin
        sys_clk = 1'b0;
        sys_rst_n = 1'b0;
        tx_en = 1'b1;
        rec_en = 1'b1;
        #50 sys_rst_n = 1'b1;
    end
        zynq_loop my_loop1(
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .tx_en(tx_en),
        .rec_din(rec_din),
        .rec_en(rec_en),

        .tx_dout(tx_dout),
        .tx_busy(tx_busy),
        .rec_busy(rec_busy)
    );


endmodule 