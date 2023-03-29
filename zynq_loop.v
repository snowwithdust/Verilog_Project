`timescale 1ns/1ps

module zynq_loop
(
    input	         sys_clk,                   //系统时钟
    input            sys_rst_n,                 //系统复位，低电平有效
     
    input            tx_en,
    input            rec_en,
    input            rec_din,

    output           tx_dout,
    output           tx_busy,
    output           rec_busy
    );
/*
    wire [7:0] rec_dout;
    reg  [7:0] rec_dout;

    always@(*)begin
        tx_din = rec_dout;
    end
*/
    wire [7:0] rec_dout;
    parameter  CLK_FREQ = 50000000;
    parameter  UART_BPS = 115200;

    uart_recv my_recv1(
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .rec_en(rec_en),
        .rec_din(rec_din),

        .rec_dout(rec_dout),
        .rec_busy(rec_busy)
    );

    uart_tx my_send1 
        (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .tx_en(tx_en),
        .tx_din(rec_dout),

        .tx_dout(tx_dout),
        .tx_busy(tx_busy)
        );


endmodule 