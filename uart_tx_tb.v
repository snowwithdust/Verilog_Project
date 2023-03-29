`timescale 1ns/1ps

module uart_tx_tb;

    reg            sys_clk;
    reg            sys_rst_n;
    reg            tx_en;
    reg    [7:0]   tx_din;

    wire       tx_dout;
    wire       tx_busy;

    parameter  CLK_FREQ = 50000000;
    parameter  UART_BPS = 115200;

    always #20 sys_clk = ~sys_clk;//50MHZ

    initial begin
        sys_clk = 1'b0;
        sys_rst_n = 1'b0;
        #50 sys_rst_n = 1'b1;
        tx_en = 1'b1;
        tx_din = 8'b101011;
    end

    uart_tx my_send 
        (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .tx_en(tx_en),
        .tx_din(tx_din),

        .tx_dout(tx_dout),
        .tx_busy(tx_busy)
        );

endmodule

