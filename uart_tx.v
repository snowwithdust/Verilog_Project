`timescale 1ns/1ps

module uart_tx
#(
    parameter CLK_FREQ = 50000000,
    parameter UART_BPS = 115200//波特率
)
(
    input            sys_clk,
    input            sys_rst_n,

    input            tx_en,
    input   [7:0]    tx_din, //发送的数据

    output reg       tx_dout,  //发送1bit数据
    output reg       tx_busy

);

localparam BPS_CNT = CLK_FREQ/UART_BPS; //localparam 不可参数传递

reg [3:0]   tx_cnt; //发送数据bit位计数
reg [15:0]  clk_cnt; //时钟计数

reg [7:0]  reg_8;


localparam VERIFY_0	  = 0;          //无校验
localparam VERIFY_1   = 1;          //奇校验
localparam VERIFY_2	  = 2;          //偶校验

localparam STATE_IDLE    = 3'b000;//空闲状态
localparam STATE_START   = 3'b100;//发送起始位
localparam STATE_DATA    = 3'b101;//发送数据位
//localparam STATE_VERIFY  = 3'b110;//发送校验位
localparam STATE_STOP    = 3'b111;//发送停止位

reg [2:0] current_state;
reg [2:0] next_state;

/********************clk_bps**************************/
//时钟计数，发生在发送数据期间
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        clk_cnt <= 16'b0;
    else if(tx_en)begin
        if(clk_cnt < BPS_CNT-1) //一个bit位发送所需要的时间
            clk_cnt <= clk_cnt + 1'b1;
        else 
            clk_cnt <= 16'b0;
    end
    else begin
        clk_cnt <= 16'b0;
    end

end
/*******************tx_cnt**************************/
//发送数据bit位
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)begin
        tx_cnt <= 4'b0;
    end
    else if(tx_en)begin
        if(clk_cnt == BPS_CNT - 1 && tx_cnt <= 8)
            tx_cnt <= tx_cnt + 1'b1;
        else if(clk_cnt == BPS_CNT - 1 && tx_cnt > 8)
            tx_cnt <= 4'b0;
        else
            tx_cnt <= tx_cnt;
    end
    else begin
        tx_cnt <= 4'b0;

    end

end
/****************MEALY 1************************/
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        current_state <= STATE_IDLE;
    else
        current_state <= next_state; //只有时钟到来，才会令当前状态变化，就可以保证在组合逻辑中当前状态跳变下一个状态不会继续跳变
end

/****************MEALY 2************************/
always@(*)begin
    case (current_state)
        STATE_IDLE: 
            if(tx_en)
                next_state = STATE_START;
            else
                next_state = STATE_IDLE;
        STATE_START: 
            if(clk_cnt >= BPS_CNT - 2)
                next_state = STATE_DATA;
            else
                next_state = STATE_START; 
        STATE_DATA: 
            if(clk_cnt >= BPS_CNT - 2 && tx_cnt == 8)
                next_state = STATE_STOP;
            else
                next_state = STATE_DATA;
        STATE_STOP: 
            if(clk_cnt >= BPS_CNT - 2 && tx_cnt == 9)
                next_state = STATE_IDLE;
            else
                next_state = STATE_STOP;
        default: next_state = STATE_IDLE;
    endcase
end

/****************MEALY 3************************/
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)begin
        tx_busy <= 1'b0;           //空闲为0
        tx_dout <= 1'b1;           //空闲为1
    end
    else
        case (current_state)
            STATE_IDLE: begin
                tx_busy <= 1'b0;   //空闲为0
                tx_dout <= 1'b1;        //空闲为1
            end
            STATE_START: begin
                tx_busy <= 1'b1;   //开始位进入数据发送
                tx_dout <= 1'b0;        //开始位拉低数据线
            end
            STATE_DATA: begin
                tx_busy <= 1'b1;
                if(tx_cnt == 0)       //发送数据
                    tx_dout <= 1'b0;
                else
                    tx_dout <= tx_din[tx_cnt-1];
            end
            STATE_STOP: begin           //停止位
                tx_busy <= 1'b1;
                tx_dout <= 1'b1;
            end
            default: begin
                tx_busy <= 1'b0;
                tx_dout <= 1'b1;
            end
        endcase
end


endmodule