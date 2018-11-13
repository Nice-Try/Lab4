`include "regfile.v"

/*************************
 ** register test bench **
 *************************/

module testregister();

  // Instantiate test vars
  wire [31:0] q;
  wire [31:0] qzero;
  reg [31:0]  d;
  reg         wrenable;
  reg         clk;

  // Instantiate helper vars
  reg testregpassed = 1;
  reg testregzeropassed = 1;
  reg [7:0] value = 147980200;
  reg [7:0] value1 = 153000324;

  // Instantiate DUTs
  register32 testreg(.q(q),
                     .d(d),
                     .wrenable(wrenable),
                     .clk(clk));
  register32zero testregzero(
                     .q(qzero),
                     .d(d),
                     .wrenable(wrenable),
                     .clk(clk));

  // Generate clock
  initial clk = 0;
  always #10 clk = !clk;

  initial begin
    $display("Begin testing register32, register32zero");

    // Test writing some value
    d=value;wrenable=1; #40
    if (q !== value) begin
      $display("Test write to register32 failed");
      $display("Expected: %b", d);
      $display("Actual:   %b", q);
      testregpassed = 0;
    end
    if (qzero !== 32'b0) begin
      $display("Test write to register32 failed");
      $display("Expected: %b", 32'b0);
      $display("Actual:   %b", qzero);
      testregzeropassed = 0;
    end

    // Test wrenable (with some other val)
    wrenable=0;
    d=value1; #40
    if (q !== value) begin
      $display("Test don't write to register32 failed");
      $display("Expected: %b", value);
      $display("Actual:   %b", q);
      testregpassed = 0;
    end
    if (qzero !== 32'b0) begin
      $display("Test don't write to register32 failed");
      $display("Expected: %b", 32'b0);
      $display("Actual:   %b", qzero);
      testregzeropassed = 0;
    end

    // More tests

    // Show if tests passed
    if (testregpassed) begin
      $display("register32 tests passed");
    end
    if (testregzeropassed) begin
      $display("register32zero tests passed");
    end
    if (testregpassed ~| testregzeropassed) begin
      $display("Tests complete");
    end

    $finish();
  end
endmodule

/*************************
 **   mux test bench    **
 *************************/

module testmux();

  // Instantiate test vars
  wire [31:0] out;
  reg  [4:0]  address;
  reg  [31:0] input0,  input1,  input2,  input3,  input4,
              input5,  input6,  input7,  input8,  input9,
              input10,  input11,  input12,  input13,  input14,
              input15,  input16,  input17,  input18,  input19,
              input20,  input21,  input22,  input23,  input24,
              input25,  input26,  input27,  input28,  input29,
              input30,  input31;

  // Instantiate helper vars
  reg dutpassed = 1;
  reg [5:0] i;

  // Instantiate DUT
  mux32to1by32 dut(out, address,
                  input0,  input1,  input2,  input3,  input4,
                  input5,  input6,  input7,  input8,  input9,
                  input10,  input11,  input12,  input13,  input14,
                  input15,  input16,  input17,  input18,  input19,
                  input20,  input21,  input22,  input23,  input24,
                  input25,  input26,  input27,  input28,  input29,
                  input30,  input31);

  initial begin
    $display("Begin testing mux32to1by32");

    // Set some inputs
    input0 = 10100011100100100000000001111;
    input1 = 1000111100101011011110101110110;
    input2 = 1101010111111001000011111011011;
    input3 = 11111000011000001110011111000111;
    input4 = 10011101100111110101000011110111;
    input5 = 10010001011011111001110011110100;
    input6 = 11110010011111101011001100000111;
    input7 = 10011111010101011100011011110011;
    input8 = 1110101010010001100111100000;
    input9 = 10111010110011010000100010100111;
    input10 = 10010110100100110101010000010000;
    input11 = 11010000001111001101011000010000;
    input12 = 100110000111100000000010111110;
    input13 = 11111011000010001110001001001000;
    input14 = 10010100110001101000000110000111;
    input15 = 10101001001101110111101110100001;
    input16 = 10110101000100000101000001101101;
    input17 = 10000011101011010011001101011110;
    input18 = 10011111000010101000010001111011;
    input19 = 10001110001010101001010111001010;
    input20 = 11011011100001101111111011100000;
    input21 = 10101111100110110000110110;
    input22 = 10011100000110100001101000100110;
    input23 = 11110101001000000100001101000011;
    input24 = 1001011100111110001110000110110;
    input25 = 10010111001010101110000011101101;
    input26 = 1011001000100101010111111110010;
    input27 = 11000011011100111100110001010000;
    input28 = 1111000100001010001011101100011;
    input29 = 10110011111101100111110100111111;
    input30 = 1101000010011001010001010000001;
    input31 = 110001001000111111000111111001;

    // Test all of them! Generated in Python
    // Test address 0
    address=0; #20
    if (out !== input0) begin
      $display("Test address 0 failed");
      $display("Expected: %b", input0);
      $display("Actual:   %b", out);
      dutpassed = 0;
    end
    // Test address 1
    address=1; #20
    if (out !== input1) begin
      $display("Test address 1 failed");
      $display("Expected: %b", input1);
      $display("Actual:   %b", out);
      dutpassed = 0;
    end
    // Test address 2
    address=2; #20
    if (out !== input2) begin
      $display("Test address 2 failed");
      $display("Expected: %b", input2);
      $display("Actual:   %b", out);
      dutpassed = 0;
    end
    // Test address 3
    address=3; #20
    if (out !== input3) begin
      $display("Test address 3 failed");
      $display("Expected: %b", input3);
      $display("Actual:   %b", out);
      dutpassed = 0;
    end
    // Test address 4
    address=4; #20
    if (out !== input4) begin
      $display("Test address 4 failed");
      $display("Expected: %b", input4);
      $display("Actual:   %b", out);
      dutpassed = 0;
    end
    // Test address 5
    address=5; #20
    if (out !== input5) begin
      $display("Test address 5 failed");
      $display("Expected: %b", input5);
      $display("Actual:   %b", out);
      dutpassed = 0;
    end
    // Test address 6
    address=6; #20
    if (out !== input6) begin
      $display("Test address 6 failed");
      $display("Expected: %b", input6);
      $display("Actual:   %b", out);
      dutpassed = 0;
    end
    // Test address 7
    address=7; #20
    if (out !== input7) begin
      $display("Test address 7 failed");
      $display("Expected: %b", input7);
      $display("Actual:   %b", out);
      dutpassed = 0;
    end
    // Test address 8
    address=8; #20
    if (out !== input8) begin
      $display("Test address 8 failed");
      $display("Expected: %b", input8);
      $display("Actual:   %b", out);
      dutpassed = 0;
    end
    // Test address 9
    address=9; #20
    if (out !== input9) begin
      $display("Test address 9 failed");
      $display("Expected: %b", input9);
      $display("Actual:   %b", out);
      dutpassed = 0;
    end
    // Test address 10
    address=10; #20
    if (out !== input10) begin
      $display("Test address 10 failed");
      $display("Expected: %b", input10);
      $display("Actual:   %b", out);
      dutpassed = 0;
    end
    // Test address 11
    address=11; #20
    if (out !== input11) begin
      $display("Test address 11 failed");
      $display("Expected: %b", input11);
      $display("Actual:   %b", out);
      dutpassed = 0;
    end
    // Test address 12
    address=12; #20
    if (out !== input12) begin
      $display("Test address 12 failed");
      $display("Expected: %b", input12);
      $display("Actual:   %b", out);
      dutpassed = 0;
    end
    // Test address 13
    address=13; #20
    if (out !== input13) begin
      $display("Test address 13 failed");
      $display("Expected: %b", input13);
      $display("Actual:   %b", out);
      dutpassed = 0;
    end
    // Test address 14
    address=14; #20
    if (out !== input14) begin
      $display("Test address 14 failed");
      $display("Expected: %b", input14);
      $display("Actual:   %b", out);
      dutpassed = 0;
    end
    // Test address 15
    address=15; #20
    if (out !== input15) begin
      $display("Test address 15 failed");
      $display("Expected: %b", input15);
      $display("Actual:   %b", out);
      dutpassed = 0;
    end
    // Test address 16
    address=16; #20
    if (out !== input16) begin
      $display("Test address 16 failed");
      $display("Expected: %b", input16);
      $display("Actual:   %b", out);
      dutpassed = 0;
    end
    // Test address 17
    address=17; #20
    if (out !== input17) begin
      $display("Test address 17 failed");
      $display("Expected: %b", input17);
      $display("Actual:   %b", out);
      dutpassed = 0;
    end
    // Test address 18
    address=18; #20
    if (out !== input18) begin
      $display("Test address 18 failed");
      $display("Expected: %b", input18);
      $display("Actual:   %b", out);
      dutpassed = 0;
    end
    // Test address 19
    address=19; #20
    if (out !== input19) begin
      $display("Test address 19 failed");
      $display("Expected: %b", input19);
      $display("Actual:   %b", out);
      dutpassed = 0;
    end
    // Test address 20
    address=20; #20
    if (out !== input20) begin
      $display("Test address 20 failed");
      $display("Expected: %b", input20);
      $display("Actual:   %b", out);
      dutpassed = 0;
    end
    // Test address 21
    address=21; #20
    if (out !== input21) begin
      $display("Test address 21 failed");
      $display("Expected: %b", input21);
      $display("Actual:   %b", out);
      dutpassed = 0;
    end
    // Test address 22
    address=22; #20
    if (out !== input22) begin
      $display("Test address 22 failed");
      $display("Expected: %b", input22);
      $display("Actual:   %b", out);
      dutpassed = 0;
    end
    // Test address 23
    address=23; #20
    if (out !== input23) begin
      $display("Test address 23 failed");
      $display("Expected: %b", input23);
      $display("Actual:   %b", out);
      dutpassed = 0;
    end
    // Test address 24
    address=24; #20
    if (out !== input24) begin
      $display("Test address 24 failed");
      $display("Expected: %b", input24);
      $display("Actual:   %b", out);
      dutpassed = 0;
    end
    // Test address 25
    address=25; #20
    if (out !== input25) begin
      $display("Test address 25 failed");
      $display("Expected: %b", input25);
      $display("Actual:   %b", out);
      dutpassed = 0;
    end
    // Test address 26
    address=26; #20
    if (out !== input26) begin
      $display("Test address 26 failed");
      $display("Expected: %b", input26);
      $display("Actual:   %b", out);
      dutpassed = 0;
    end
    // Test address 27
    address=27; #20
    if (out !== input27) begin
      $display("Test address 27 failed");
      $display("Expected: %b", input27);
      $display("Actual:   %b", out);
      dutpassed = 0;
    end
    // Test address 28
    address=28; #20
    if (out !== input28) begin
      $display("Test address 28 failed");
      $display("Expected: %b", input28);
      $display("Actual:   %b", out);
      dutpassed = 0;
    end
    // Test address 29
    address=29; #20
    if (out !== input29) begin
      $display("Test address 29 failed");
      $display("Expected: %b", input29);
      $display("Actual:   %b", out);
      dutpassed = 0;
    end
    // Test address 30
    address=30; #20
    if (out !== input30) begin
      $display("Test address 30 failed");
      $display("Expected: %b", input30);
      $display("Actual:   %b", out);
      dutpassed = 0;
    end
    // Test address 31
    address=31; #20
    if (out !== input31) begin
      $display("Test address 31 failed");
      $display("Expected: %b", input31);
      $display("Actual:   %b", out);
      dutpassed = 0;
    end


    if (dutpassed) begin
      $display("Tests passed");
    end else begin
      $display("Tests complete");
    end

  end
endmodule
