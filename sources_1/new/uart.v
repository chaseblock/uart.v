
// A UART implementation
// Requires one stop bit, no parity
module uart(
    clk, rx, tx,
    rx_err, rcvd,
    datarx, datatx,
    start, rxack,
    ready,
    reset
    );
    
    input reset;
    input clk;  // A clock at 10x the baud rate
    
    // The data pins connected to the uart
    input rx;
    output reg tx;
    
    // Flags for indicating an rx error
    // or an rx success
    output reg rx_err;
    output reg rcvd;
    
    // Must be less than or equal to 32
    parameter DATA_WIDTH = 8;
    output reg [DATA_WIDTH-1 : 0] datarx; // The data that is received on the rx line
    input [DATA_WIDTH-1 : 0] datatx; // The data to be transmitted
    
    reg [DATA_WIDTH-1 : 0] rx_buf;
    reg [DATA_WIDTH-1 : 0] tx_buf;
    
    input start;    // Set this for one clock cycle when data is ready to be sent
    
    input rxack;    // Set this to clear the rx_err/rcvd bits
    
    reg [3:0] rx_pulse; // The clock count to read on
    reg [5:0] rx_bit;   // The current rx bit being read
    
    reg [5:0] tx_bit;   // The bit on the tx line which needs to transmit next
    
    reg [3:0] clk_cnt;  // A number between 0 and 9 for the current clock cycle
    
    reg reading = 0, transmitting = 0;
    
    // Whether we are ready to receive more data
    output ready;
    assign ready = ~transmitting;
    
    // Handle transmission, reception, and any data things
    always @(posedge clk) begin
        if(reset == 1) begin
            clk_cnt <= 0;
            tx      <= 1;
            rx_err  <= 0;
            rcvd    <= 0;
            datarx  <= 0;
            rx_buf  <= 0;
            tx_buf  <= 0;
            rx_pulse <= 0;
            rx_bit  <= 0;
            tx_bit  <= 0;
            clk_cnt <= 0;
            reading <= 0;
            transmitting <= 0;
        end
        else begin
            // Increment the clk count
            clk_cnt <= (clk_cnt + 1) % 10;
        
            // Check for an ack from the controller
            if(rxack) rcvd <= 0;
        
            // Handle the receive
            if(reading == 0) begin
                // Find a start bit
                if(rx == 0) begin
                    reading  <= 1;
                    rx_pulse <= (clk_cnt + 5) % 10; // Close to the center of the frame
                    rx_bit   <= 6'h3f;  // A big number to show that we are reading the start bit
                    rx_buf   <= 0;
                end
            end
            else begin
                // We are reading
                if(clk_cnt == rx_pulse) begin
                    // It's the clock cycle that we're supposed to read
                    if(rx_bit == 6'h3f) begin
                        // This is the start frame. Skip.
                        rx_bit <= 0;
                    end
                    else if(rx_bit == DATA_WIDTH) begin
                        // This should be the stop bit
                        if(rx == 1) begin
                            // Put the data
                            datarx <= rx_buf;
                            // Signal completion, but only if the ack signal is not held
                            if(!rxack) rcvd <= 1;
                        end
                        else begin
                            // It wasn't the stop bit
                            if(!rxack) rx_err <= 1;
                        end
                        
                        reading <= 0;
                    end
                    else begin
                        // It's a normal data bit
                        rx_buf <= {rx, rx_buf[DATA_WIDTH-1 : 1]};    // Shift the data in
                        rx_bit <= rx_bit + 1;
                    end
                end
            end
            
            // Handle the transmit
            if(transmitting == 0) begin
                tx <= 1;
                if(start == 1) begin
                    transmitting <= 1;
                    tx_buf <= datatx;
                    tx_bit <= 6'h3f;    // start bit is next
                end
            end
            else begin
                // We only transmit on the zero counts
                if(clk_cnt == 0) begin
                    if(tx_bit == 6'h3f) begin 
                        tx <= 0;
                        tx_bit <= 0;
                    end
                    else if(tx_bit < DATA_WIDTH) begin
                        // Transmit the next bit
                        tx <= tx_buf[0];
                        tx_buf <= {1'b1, tx_buf[DATA_WIDTH-1:1]};
                        tx_bit <= tx_bit + 1;
                    end
                    else if(tx_bit == DATA_WIDTH) begin
                        // Stop bit
                        tx <= 1;
                        tx_bit <= tx_bit + 1;
                    end
                    else begin
                        tx <= 1;
                        transmitting <= 0;
                    end
                end
            end
        end
    end
    
endmodule