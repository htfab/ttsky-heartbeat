`default_nettype none

`define INVERTER_CHAIN_LENGTH 1024

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
wire manchester_delayed;

wire [`INVERTER_CHAIN_LENGTH:0] inverter_chain;
assign inverter_chain[0] = !manchester;
assign manchester_delayed = !inverter_chain[`INVERTER_CHAIN_LENGTH];

genvar i;
generate
    for (i=0; i<`INVERTER_CHAIN_LENGTH; i=i+1) begin
`ifdef SIM
        assign inverter_chain[i+1] = #1 inverter_chain[i];
`else
        inverter i_inv(.a(inverter_chain[i]), .y(inverter_chain[i+1]));
`endif
    end
endgenerate

always @(posedge clk) begin
    manchester <= !manchester_delayed;
    if (manchester) begin
        index <= index - 1;
        if (index == 0) begin
            counter <= counter + 1;
        end
    end
end

assign uo_out[0] = counter[index] ^ manchester_delayed;
assign uo_out[7:1] = 0;
assign uio_out = 0;
assign uio_oe = 0;

wire _unused = &{ena, rst_n, ui_in, uio_in, 1'b0};

endmodule
