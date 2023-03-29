`timescale 1ns/1ps

module uart_loop
(
    input	         sys_clk,                   //系统时钟
    input            sys_rst_n,                 //系统复位，低电平有效
     
    input            tx_en,
    input            rec_en,
    input     [7:0]  tx_din,

    output    [7:0]  rec_dout,
    output           tx_busy,
    output           rec_busy
    );


    parameter  CLK_FREQ = 50000000;
    parameter  UART_BPS = 115200;


    uart_tx my_send 
        (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .tx_en(tx_en),
        .tx_din(tx_din),

        .tx_dout(tx_dout),
        .tx_busy(tx_busy)
        );

    uart_recv my_recv(
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .rec_en(rec_en),
        .rec_din(tx_dout),

        .rec_dout(rec_dout),
        .rec_busy(rec_busy)
    );

endmodule 