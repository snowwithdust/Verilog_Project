`timescale 1ns/1ps

module uart_loop_tb;


    reg            sys_clk;
    reg            sys_rst_n;
    reg            tx_en;
    reg    [7:0]   tx_din;
    reg            rec_en;

    wire   [7:0] rec_dout;
    wire         tx_busy;
    wire         rec_busy;

    parameter  CLK_FREQ = 50000000;
    parameter  UART_BPS = 115200;

    always #20 sys_clk = ~sys_clk;//50MHZ
    always #174000 tx_din = $random;

    reg [31:0] data_ram [7:0];
    reg [3:0] num;
/*
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if(!sys_rst_n)
            num <= 4'b0;
        else if(!tx_busy && rec_busy)begin
            data_ram[num] <= rec_dout; 
    end 
    end
*/
    initial begin
        sys_clk = 1'b0;
        sys_rst_n = 1'b0;
        tx_en = 1'b1;
        rec_en = 1'b1;
        #50 sys_rst_n = 1'b1;
        tx_en = 1'b1;
        tx_din = 8'b101011;
    end

    uart_loop my_loop(
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .tx_en(tx_en),
        .tx_din(tx_din),
        .rec_en(rec_en),

        .rec_dout(rec_dout),
        .tx_busy(tx_busy),
        .rec_busy(rec_busy)
    );



endmodule 