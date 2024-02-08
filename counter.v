module top
(
    input in_clk,
    input btn1,
    input btn2,
    output [5:0] led,
    output f_out
    );

localparam MAXBIT = 31; 
reg [5:0] ledCounter = 0;
reg [MAXBIT:0] phaseAccumulator = 0;
reg [MAXBIT:0] phaseIncrement = 1;
reg [MAXBIT:0] increment_next = 1;
reg [MAXBIT:0] aa,bb,cc,carry = 0;
reg [MAXBIT:0] newcarry = 0;

reg [MAXBIT:0] sum = 0;

reg last_btn1 = 0;
reg last_btn2 = 0;

wire out_clk;
wire clk_lock;


rPLL #( // For GW1NR-9C C6/I5 (Tang Nano 9K proto dev board)
  .FCLKIN("27"),
  .IDIV_SEL(4), // -> PFD = 5.4 MHz (range: 3-400 MHz)
  .FBDIV_SEL(36), // -> CLKOUT = 199.8 MHz (range: 3.125-600 MHz)
  .ODIV_SEL(4) // -> VCO = 799.2 MHz (range: 400-1200 MHz)
) pll (.CLKOUTP(), .CLKOUTD(), .CLKOUTD3(), .RESET(1'b0), .RESET_P(1'b0), .CLKFB(1'b0), .FBDSEL(6'b0), .IDSEL(6'b0), .ODSEL(6'b0), .PSDA(4'b0), .DUTYDA(4'b0), .FDLY(4'b0),
  .CLKIN(in_clk), // 27 MHz
  .CLKOUT(out_clk), // 199.8 MHz
  .LOCK(clk_lock)
);

always@(posedge out_clk) begin
    carry <= newcarry << 1;
    phaseAccumulator <= sum;
end;

always @* begin
//  newcarry <= (phaseAccumulator & phaseIncrement) | (phaseIncrement & carry) | (phaseAccumulator & carry);
  aa <= phaseAccumulator & phaseIncrement;
  bb <= phaseIncrement & carry;
  cc <= phaseAccumulator & carry;
  newcarry <= aa | bb | cc;
  sum <= phaseAccumulator ^ phaseIncrement ^ carry;

//  sum <= 1;
//  newcarry <= 0;
end

// Button logic
always@(posedge in_clk) begin
  if (~btn1 && last_btn1)
    increment_next <= phaseIncrement + 1;
  else if (~btn2 && last_btn2)
    increment_next <= phaseIncrement - 1;
  else if (~btn1 && ~btn2)
    increment_next <= 0;

  last_btn1 <= btn1;
  last_btn2 <= btn2;
end

// D flip-flop for phaseIncrement
always @(posedge in_clk) begin
  phaseIncrement <= increment_next;
end

assign led = ~phaseAccumulator[MAXBIT:MAXBIT-5];
assign f_out = phaseAccumulator[MAXBIT];

endmodule
