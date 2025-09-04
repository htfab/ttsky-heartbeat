`default_nettype none

module inverter (
    input wire a,
    output wire y
);

(* keep *)
sky130_fd_sc_hd__inv_1 i_inv (.A(a), .Y(y));

endmodule
