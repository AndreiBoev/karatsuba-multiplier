`timescale 1ns/1ps

module mul_karatsuba_tb;
  reg  [15:0] a;
  reg  [15:0] b;
  wire [31:0] product;

  mul_karatsuba uut (.a(a), .b(b), .product(product));

  integer i;
  reg [31:0] expected;
  localparam num_random_tests = 1000;

  initial begin
    // Угловые тесты
    a = 0; b = 0; #10;
    expected = a * b;
    if (product !== expected)
      $display("ERROR: a=0, b=0: expected %b, got %b", expected, product);
    else $display("Test a=0, b=0 passed.");

    a = 0; b = {16{1'b1}}; #10;
    expected = a * b;
    if (product !== expected)
      $display("ERROR: a=0, b=max: expected %b, got %b", expected, product);
    else $display("Test a=0, b=max passed.");

    a = {16{1'b1}}; b = 0; #10;
    expected = a * b;
    if (product !== expected)
      $display("ERROR: a=max, b=0: expected %b, got %b", expected, product);
    else $display("Test a=max, b=0 passed.");

    a = {16{1'b1}}; b = {16{1'b1}}; #10;
    expected = a * b;
    if (product !== expected)
      $display("ERROR: a=max, b=max: expected %b, got %b", expected, product);
    else $display("Test a=max, b=max passed.");

    a = 1; b = {16{1'b1}}; #10;
    expected = a * b;
    if (product !== expected)
      $display("ERROR: a=1, b=max: expected %b, got %b", expected, product);
    else $display("Test a=1, b=max passed.");

    a = {16{1'b1}}; b = 1; #10;
    expected = a * b;
    if (product !== expected)
      $display("ERROR: a=max, b=1: expected %b, got %b", expected, product);
    else $display("Test a=max, b=1 passed.");

    // Случайные тесты
    for (i = 0; i < num_random_tests; i = i + 1) begin
      a = {$urandom};
      b = {$urandom};
      #5;
      expected = a * b;
      if (product !== expected) begin
        $display("ERROR: Random test %d failed: a=%h, b=%h, expected=%h, got=%h", i, a, b, expected, product);
      end else begin
         $display("Random test %d passed.", i);
      end
    end

    $display("All tests completed.");
    $finish;
  end
endmodule
