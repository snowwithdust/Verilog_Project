module vga_sync
    (
        output        hsync,
        output        vsync,
        output        ready,
        output [10:0] x_addr,
        output [10:0] y_addr,
        input         clk,
        input         rst_n
    );
//ˮƽ �в���
parameter  H_SYNC_TIME   =48;
parameter  H_BACK_PROCH  =88;
parameter  H_ADDR_TIME    =800;
parameter  H_FRONT_PROCH =40;
parameter  H_TIME_TOTAL=H_FRONT_PROCH+H_SYNC_TIME+H_BACK_PROCH+H_ADDR_TIME;
parameter  H_ADDR_START_PIX  =H_BACK_PROCH+H_SYNC_TIME;
parameter  H_ADDR_END_PIX    =H_BACK_PROCH+H_SYNC_TIME+H_ADDR_TIME;
//��ֱ �в���
parameter  V_SYNC_TIME   =3;
parameter  V_BACK_PROCH  =32;
parameter  V_ADDR_TIME    =480;
parameter  V_FRONT_PROCH  =13;
parameter  V_TIME_TOTAL=V_FRONT_PROCH+V_SYNC_TIME+V_BACK_PROCH+V_ADDR_TIME;
parameter  V_ADDR_START_PIX  =V_BACK_PROCH+V_SYNC_TIME;
parameter  V_ADDR_END_PIX    =V_BACK_PROCH+V_SYNC_TIME+V_ADDR_TIME;

//�м���ģ��
reg [12:0] cnt_hreg;
always @(posedge clk, negedge rst_n) begin
    if(!rst_n)
        cnt_hreg <= 'd0;
    else if(cnt_hreg == H_TIME_TOTAL-1)  //H_TIME_TOTAL PERIOD CNT
        cnt_hreg <= 'd0;
    else
        cnt_hreg <= cnt_hreg + 'b1;
end
//������ģ��
reg [12:0] cnt_vreg;
always @(posedge clk, negedge rst_n) begin
    if(!rst_n)
        cnt_vreg <= 'd0;
    else if(cnt_vreg == V_TIME_TOTAL-1)  //V_TIME_TOTAL PERIOD CNT
        cnt_vreg <= 'd0;
    else if(cnt_hreg == H_TIME_TOTAL-1)
        cnt_vreg <= cnt_vreg + 'b1;
end
//������ʵ��ͼ��ȡ������Ч�ź�ready_reg��ʾ��ǰ��ͼ����Ч����
reg ready_reg;
always @(posedge clk, negedge rst_n) begin
    if(!rst_n)
        ready_reg <= 'b0;
    else if( (cnt_hreg >= H_ADDR_START_PIX && cnt_hreg < H_ADDR_END_PIX)  //H PIX VALID
        && (cnt_vreg >= V_ADDR_START_PIX && cnt_vreg <V_ADDR_END_PIX) )   //V PIX VALID
        ready_reg <= 'b1;
    else
        ready_reg <= 'b0;
end

//assign critical signal 
assign hsync = (cnt_hreg < H_SYNC_TIME) ? 'b0 : 'b1;//��ͬ���ź��ڼ���С��H_SYNC_TIMEʱ��Ϊ0
assign vsync = (cnt_vreg < V_SYNC_TIME)   ? 'b0 : 'b1;//��ͬ���ź��ڼ���С��V_SYNC_TIMEʱ��Ϊ0
assign ready = ready_reg;
assign x_addr = ready_reg ? cnt_hreg - H_ADDR_START_PIX : 'd0;//ͼ����Ч�������ʱ�����addr�ź�ָʾ�ǵڼ�����Ч����
assign y_addr = ready_reg ? cnt_vreg - V_ADDR_START_PIX  : 'd0;

endmodule


