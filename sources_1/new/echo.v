`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2021 07:50:48 PM
// Design Name: 
// Module Name: echo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module echo(
    input clk, rx,
    output tx
    );
    
    reg clk_10_115200;
    reg [12:0] clk_count;
    // Divide the clock
    always @(posedge clk) begin
        if(clk_count >= 4340) begin
            clk_count <= 0;
            clk_10_115200 <= ~clk_10_115200;
        end
        else begin
            clk_count <= clk_count + 1;
        end
    end
    
    wire rx_err, rcvd, ready;
    wire [7:0] datarx;
    reg [7:0] datatx;
    reg rxack, start, reset;
    
    uart #(.DATA_WIDTH(8)) u0(
        .clk(clk_10_115200), 
        .rx(rx), 
        .tx(tx),
        .rx_err(rx_err), 
        .rcvd(rcvd),
        .datarx(datarx), 
        .datatx(datatx),
        .start(start), 
        .rxack(rxack),
        .ready(ready),
        .reset(reset)
    );
    
    always @(posedge clk) begin
        reset = 0;
        rxack = 0;
        start = 0;
        
        // If there's data, take it out
        if(rcvd == 1) begin
            datatx <= datarx;
            rxack = 1;
            start = 1;
        end
    end
    
endmodule
