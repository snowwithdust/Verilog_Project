module rgb_lcd_top
        (
            input  wire clk,
            input  wire rst_n,
            output wire[7:0] Red,
            output wire[7:0] Green,
            output wire[7:0] Blue,
            output wire Hsync,
            output wire Vsync,
            output wire ready,
            output wire dclk,
            output wire disp,
            output wire back_led_en
         );
   
   assign back_led_en=1'b1;
   assign disp=1'b1;
    wire pixel_clk;
    clk_wiz_0 clk_wiz_0_inst
    (
        .clk_in(clk),
        .resetn(rst_n),
        .clk_out1(pixel_clk)
    );
    assign dclk=pixel_clk;
    vga_driver vga_driver_inst(
        .clk(clk),           //pixel clock
        .rst_n(rst_n),           //reset signal high active
        .hs(Hsync),            //horizontal synchronization
        .vs(Vsync),            //vertical synchronization
        .ready(ready),            //video valid
        .rgb_r(Red),         //video red data
        .rgb_g(Green),         //video green data
        .rgb_b(Blue)          //video blue data
    );
endmodule
