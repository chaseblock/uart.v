`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2021 07:26:21 PM
// Design Name: 
// Module Name: uart_test
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


module uart_test();

    reg clk, rx, start, rxack, reset;
    reg [7:0] datatx;
    wire tx, rx_err, rcvd, ready;
    wire [7:0] datarx;

    uart #(.DATA_WIDTH(8)) u0(
        .clk(clk), 
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
    
    initial begin
        clk = 0;
        forever
            #5 clk <= ~clk;
    end
    
    initial begin
        // Initialize all the inputs
        rx     <= 1;
        start  <= 0;
        rxack  <= 1;
        datatx <= 0;
        reset  <= 1;
        #53;
        reset <= 0;
        rxack <= 0;
        
        #10;
        
        // Start receiving some data
        rx <= 0;    // Start frame
        
        // Wait for ten cycles for each bit
        #100;
        rx <= 0;
        #100;
        rx <= 1;
        #100;
        rx <= 1;
        #100;
        rx <= 1;
        #100;
        rx <= 0;
        #100;
        rx <= 0;
        #100;
        rx <= 0;
        #100;
        rx <= 1;
        #100;
        rx <= 1;    // Stop bit
        #200;
        rxack <= 1;
        #100;
        rxack <= 0;
        
        // Now we set up to transmit
        datatx <= 8'hED;
        #10;
        start <= 1;
        #10;
        start <= 0;
    end

endmodule
