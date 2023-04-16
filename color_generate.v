module color_generate(
    output reg [7:0]  R,
    output reg [7:0]  G,
    output reg [7:0]  B,
    
    input wire         clk,
    input wire         rst_n,
    //input wire  [2:0]  mode,
    input wire  [10:0] col_addr,
    input wire  [10:0] row_addr,
    input wire         ready
);

reg [7:0] num;

always @(posedge clk, negedge rst_n) begin
    if(!rst_n)begin
        R<='d0;
        G<='d0;
        B<='d0;
    end
    else begin
        R<=num + 8'd200;
        G<=num + 8'd20;
        B<=num + 8'd100;
        num = num + 1;

    end
end
endmodule