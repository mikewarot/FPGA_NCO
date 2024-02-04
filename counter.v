module top
(
    input in_clk,
    input btn1,
    input btn2,
    output [5:0] led
);

localparam MAXBIT = 31; 
reg [5:0] ledCounter = 0;
reg [MAXBIT:0] clockCounter = 0;
reg [MAXBIT+1:0] increment = 1;
reg [MAXBIT+1:0] carry = 0;
reg [MAXBIT+1:0] newcarry = 0;

reg [MAXBIT+1:0] sum = 0;
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
//    clockCounter <= clockCounter + increment;
    sum[MAXBIT:0] <= clockCounter[MAXBIT:0] ^ increment[MAXBIT:0] ^ carry[MAXBIT:0];
    newcarry <= (clockCounter[MAXBIT:0] & increment[MAXBIT:0]) | (increment[MAXBIT:0] & carry[MAXBIT:0]) | (clockCounter[MAXBIT:0] & carry[MAXBIT:0]);
    carry[MAXBIT+1:1] <= newcarry[MAXBIT:0];
    carry[0] <= 0;
    clockCounter[MAXBIT:0] <= sum[MAXBIT:0];

    ledCounter <= clockCounter[MAXBIT:MAXBIT-5];
end;

always @(posedge in_clk) begin
    if (~btn1 && last_btn1) begin
        increment <= increment - 1;
    end
    else if (~btn2 && last_btn2) begin
        increment <= increment + 1;
    end
    else if (~btn1 && ~btn2) begin
        increment <= 0;
    end;
    last_btn1 <= btn1;
    last_btn2 <= btn2;
end

assign led = ~ledCounter;

endmodule
