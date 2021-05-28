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
    input clk, rx, rst,
    output tx
    );
    
    reg clk_10_115200;
    reg [12:0] clk_count;
    initial begin
        clk_count <= 0;
        clk_10_115200 <= 0;
    end
    
    // Divide the clock
    always @(posedge clk) begin
        if(clk_count >= 43) begin
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
    reg rxack, start;
    
    wire reset = rst;
    
    reg d1, d2;
    
    always @(posedge clk) begin
        d1 <= rx;
        d2 <= d1;
    end
    
    uart #(.DATA_WIDTH(8)) u0(
        .clk(clk_10_115200), 
        .rx(d2), 
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
    
    reg [7:0] msg;
    reg [1:0] hasmsg;
    
    always @(posedge clk) begin
        if(rst) hasmsg <= 0;
        
        // If there's data, take it out
        if(rcvd == 1) begin
            msg    <= datarx;
            hasmsg <= 1;
            rxack  <= 1;
        end else begin
            rxack <= 0;
        end
        
        if(hasmsg && ready) begin
            datatx <= msg;
            hasmsg <= 2;
            start  <= 1;
        end else begin
            start  <= 0;
            if(hasmsg == 2)
                hasmsg <= 0;
        end
    end
    
endmodule
