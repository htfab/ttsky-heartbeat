`default_nettype none

module tt_um_heartbeat (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

reg [7:0] counter;
reg [2:0] index;
reg manchester;
reg signal;

always @(posedge clk) begin
    signal <= counter[index] ^ manchester;
    manchester <= !manchester;
    if (manchester) begin
        index <= index - 1;
        if (index == 0) begin
            counter <= counter + 1;
        end
    end
end

assign uo_out[0] = signal;
assign uo_out[7:1] = 0;
assign uio_out = 0;
assign uio_oe = 0;

wire _unused = &{ena, rst_n, ui_in, uio_in, 1'b0};

endmodule
