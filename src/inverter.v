`default_nettype none

module inverter (
    input wire a,
    output wire y
);

`ifdef SCL_sky130_fd_sc_hd
(* keep *)
sky130_fd_sc_hd__inv_1 i_inv (
    .A(a),
    .Y(y)
);
`endif

endmodule
