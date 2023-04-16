module vga_driver(
	input                 clk,           //pixel clock
	input                 rst_n,           //reset signal high active
	output                hs,            //horizontal synchronization
	output                vs,            //vertical synchronization
	output                ready,            //video valid
	output[7:0]           rgb_r,         //video red data
	output[7:0]           rgb_g,         //video green data
	output[7:0]           rgb_b          //video blue data
);

wire [10:0] cl_adr;
wire [10:0] rw_adr;
reg[2:0]test_mode_reg;
//VGA信号同步产生模块
vga_sync vga_sync_inst(
    .hsync(hs),
    .vsync(vs),
    .ready(ready),
    .x_addr(cl_adr),
    .y_addr(rw_adr),
    .clk(clk),
    .rst_n(rst_n)
);
//彩色渐变测试模块
color_generate color_generate_inst(
    .R(rgb_r),
    .G(rgb_g),
    .B(rgb_b),

    .clk(clk),
    .rst_n(rst_n),
    //.mode(test_mode_reg),
    .col_addr(cl_adr),
    .row_addr(rw_adr),
    .ready(ready)
);

parameter CLK_FREQ='d50000000;//时钟频率定义50Mhz=50000000.
parameter COUNT_ONE_SECONDS=CLK_FREQ/2;//计数半秒钟
reg [31:0]counter_timeout_reg;
//敏感块进行0.5秒的计数，控制test_mode_reg自加，有000-111一共八种模式
always @(posedge clk, negedge rst_n) begin
    if(!rst_n)begin
        test_mode_reg<='d0;
        counter_timeout_reg<='d0;
    end
    else begin
        if(counter_timeout_reg<COUNT_ONE_SECONDS-1)counter_timeout_reg<=counter_timeout_reg+'d1;
        else begin
            counter_timeout_reg<='d0;
            test_mode_reg<=test_mode_reg+'d1;
        end
    end
end

endmodule 