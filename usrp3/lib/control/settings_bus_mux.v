//
// Copyright 2015 Ettus Research LLC
//
// Mux multiple settings buses

module settings_bus_mux #(
  parameter PRIO=0, // 0 = Round robin, 1 = Lower ports get priority (see axi_mux)
  parameter AWIDTH=8,
  parameter DWIDTH=32,
  parameter BUFFER=1,
  parameter NUM_BUSES=2)
(
  input clk, input reset,
  input [NUM_BUSES-1:0] in_set_stb, input [NUM_BUSES*AWIDTH-1:0] in_set_addr, input [NUM_BUSES*DWIDTH-1:0] in_set_data,
  output out_set_stb, output [AWIDTH-1:0] out_set_addr, output [DWIDTH-1:0] out_set_data, input ready
);

  wire [NUM_BUSES*(AWIDTH+DWIDTH)-1:0] i_tdata;

  genvar i;
  generate
    for (i = 0; i < NUM_BUSES; i = i + 1) begin
      assign i_tdata[(i+1)*(AWIDTH+DWIDTH)-1:i*(AWIDTH+DWIDTH)] = {in_set_addr[(i+1)*AWIDTH-1:i*AWIDTH],in_set_data[(i+1)*DWIDTH-1:i*DWIDTH]};
    end
  endgenerate

  axi_mux #(.PRIO(PRIO), .WIDTH(AWIDTH+DWIDTH), .BUFFER(BUFFER), .SIZE(NUM_BUSES))
  axi_mux (
    .clk(clk), .reset(reset), .clear(1'b0),
    .i_tdata(i_tdata), .i_tlast(1'b0), .i_tvalid(in_set_stb), .i_tready(),
    .o_tdata({out_set_addr,out_set_data}), .o_tlast(), .o_tvalid(out_set_stb), .o_tready(ready));

endmodule