`timescale 1ns/1ps

module uart_recv 
#(
    parameter CLK_FREQ = 50000000,
    parameter UART_BPS = 115200//波特率
)
(
    input            sys_clk,
    input            sys_rst_n,
    input            rec_din,
    input            rec_en,

    output reg [7:0] rec_dout,
    output reg       rec_busy

);

localparam BPS_CNT = CLK_FREQ/UART_BPS; //localparam 不可参数传递

//reg [7:0]   rec_dout;
reg [3:0]   rec_cnt; //接受数据bit位计数
reg [15:0]  clk_cnt; //时钟计数

reg   [4:0] rec_reg_5;

localparam STATE_IDLE    = 3'b000;//空闲状态
localparam STATE_START   = 3'b100;//发送起始位
localparam STATE_DATA    = 3'b101;//发送数据位
localparam STATE_STOP    = 3'b111;//发送停止位

reg [2:0] current_state;
reg [2:0] next_state;

/******************rec_reg_5***************************/
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        rec_reg_5 <= 5'b11111;
    else
        rec_reg_5 <= {rec_reg_5[3:0], rec_din};
end

/********************clk_cnt**************************/
//时钟计数，发生在接收数据期间
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        clk_cnt <= 9'b0;
    else if(rec_en && current_state != STATE_IDLE)begin
        if(clk_cnt < BPS_CNT-1) //1个bit位接收所需要的时间
            clk_cnt <= clk_cnt + 1'b1;
        else 
            clk_cnt <= 9'b0;
    end
    else begin
        clk_cnt <= 9'b0;
    end
end
/*******************rec_cnt**************************/
//接收数据bit计数
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)begin
        rec_cnt <= 4'b0;
    end
    else if(rec_en)begin
        if(clk_cnt == BPS_CNT - 1 && rec_cnt <= 8)
            rec_cnt <= rec_cnt + 1'b1;
        else if(clk_cnt == BPS_CNT - 1 && rec_cnt > 8)
            rec_cnt <= 4'b0;
        else
            rec_cnt <= rec_cnt;
    end
    else begin
        rec_cnt <= 4'b0;

    end

end

/*******************MEALY 1***********************/
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        current_state <= STATE_IDLE;
    else
        current_state <= next_state; //只有时钟到来，才会令当前状态变化，就可以保证在组合逻辑中当前状态跳变下一个状态不会继续跳变
end
/********************MEALY 2**********************/
always@(*)begin
    case (current_state)
        STATE_IDLE: 
            if(rec_en && rec_reg_5 == 5'b0)
                next_state = STATE_START;
            else
                next_state = STATE_IDLE;
        STATE_START: 
            if(clk_cnt >= BPS_CNT - 2)
                next_state = STATE_DATA;
            else
                next_state = STATE_START; 
        STATE_DATA: 
            if(clk_cnt >= BPS_CNT - 2 && rec_cnt == 8)
                next_state = STATE_STOP;
            else
                next_state = STATE_DATA;
        STATE_STOP: 
            if(clk_cnt >= BPS_CNT - 2 && rec_cnt == 9)
                next_state = STATE_IDLE;
            else
                next_state = STATE_STOP;
        default: next_state = STATE_IDLE;
    endcase
end
/********************MEALY 3***********************/
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)begin
        rec_busy <= 1'b0;          
        rec_dout <= 8'b0;           
    end
    else
        case (current_state)
            STATE_IDLE: begin
                rec_busy <= 1'b0;   //空闲为0
                rec_dout <= rec_dout;        //空闲为1
            end
            STATE_START: begin
                rec_busy <= 1'b1;   //起始位进入数据发送
                rec_dout <= 8'b0;        //起始位拉低数据线
            end
            STATE_DATA: begin
                rec_busy <= 1'b1;
                if(rec_reg_5 == 5'b0 && clk_cnt > BPS_CNT/3 && clk_cnt < BPS_CNT*2/3)
                    rec_dout[rec_cnt-1] <= 1'b0;
                else if(rec_reg_5 == 5'b11111 && clk_cnt > BPS_CNT/3 && clk_cnt < BPS_CNT*2/3)
                    rec_dout[rec_cnt-1] <= 1'b1;
                else
                    rec_dout <= rec_dout;
            end
            STATE_STOP: begin 
                rec_busy <= 1'b1;
                rec_dout <= rec_dout;
            end
            default: begin
                rec_busy <= 1'b0;
                rec_dout <= rec_dout;
            end
        endcase
end

endmodule
