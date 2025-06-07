module karatsuba_4(input  [3:0] a,
                   input  [3:0] b,
                   output [7:0] product);
  assign product = a * b;
endmodule

module karatsuba_3(input  [2:0] a,
                   input  [2:0] b,
                   output [5:0] product);
  assign product = a * b;
endmodule

module karatsuba_5(
  input  [4:0] a,
  input  [4:0] b,
  output [9:0] product
);
  localparam m          = 3;
  localparam total_bits = 2 * m;
  // Дополняем нулями до total_bits, чтобы разрезы были одинаковой ширины
  wire [total_bits-1:0] a_ext = {{(total_bits-5){1'b0}}, a};
  wire [total_bits-1:0] b_ext = {{(total_bits-5){1'b0}}, b};

  wire [m-1:0] a_low  = a_ext[m-1:0];
  wire [m-1:0] a_high = a_ext[total_bits-1:m];
  wire [m-1:0] b_low  = b_ext[m-1:0];
  wire [m-1:0] b_high = b_ext[total_bits-1:m];

  wire [m:0] a_sum = a_high + a_low;
  wire [m:0] b_sum = b_high + b_low;

  wire [2*m-1:0]       z0;
  wire [2*m-1:0]       z2;
  wire [2*(m+1)-1:0]   z1_full;
  karatsuba_3 mul_low  (.a(a_low),  .b(b_low),  .product(z0));
  karatsuba_3 mul_high (.a(a_high), .b(b_high), .product(z2));
  karatsuba_4 mul_sum  (.a(a_sum), .b(b_sum), .product(z1_full));

  wire [2*(m+1)-1:0] z0_ext = {{2{1'b0}}, z0};
  wire [2*(m+1)-1:0] z2_ext = {{2{1'b0}}, z2};
  wire [2*(m+1)-1:0] z1     = z1_full - z0_ext - z2_ext;

  // 4*m+3 бит = 2*(m+1)+2*m + 1 (на перенос)
  wire [4*m+2:0] result_full;
  assign result_full =
        {z2_ext, {2*m{1'b0}}} +   // z2_ext << 2*m
        {z1,     {  m{1'b0}}} +   // z1     <<   m
        z0_ext;

  assign product = result_full[9:0];
endmodule

module karatsuba_8(
  input  [7:0] a,
  input  [7:0] b,
  output [15:0] product
);
  localparam m          = 4;
  localparam total_bits = 2 * m;
  // Дополняем нулями до total_bits, чтобы разрезы были одинаковой ширины
  wire [total_bits-1:0] a_ext = {{(total_bits-8){1'b0}}, a};
  wire [total_bits-1:0] b_ext = {{(total_bits-8){1'b0}}, b};

  wire [m-1:0] a_low  = a_ext[m-1:0];
  wire [m-1:0] a_high = a_ext[total_bits-1:m];
  wire [m-1:0] b_low  = b_ext[m-1:0];
  wire [m-1:0] b_high = b_ext[total_bits-1:m];

  wire [m:0] a_sum = a_high + a_low;
  wire [m:0] b_sum = b_high + b_low;

  wire [2*m-1:0]       z0;
  wire [2*m-1:0]       z2;
  wire [2*(m+1)-1:0]   z1_full;
  karatsuba_4 mul_low  (.a(a_low),  .b(b_low),  .product(z0));
  karatsuba_4 mul_high (.a(a_high), .b(b_high), .product(z2));
  karatsuba_5 mul_sum  (.a(a_sum), .b(b_sum), .product(z1_full));

  wire [2*(m+1)-1:0] z0_ext = {{2{1'b0}}, z0};
  wire [2*(m+1)-1:0] z2_ext = {{2{1'b0}}, z2};
  wire [2*(m+1)-1:0] z1     = z1_full - z0_ext - z2_ext;

  // 4*m+3 бит = 2*(m+1)+2*m + 1 (на перенос)
  wire [4*m+2:0] result_full;
  assign result_full =
        {z2_ext, {2*m{1'b0}}} +   // z2_ext << 2*m
        {z1,     {  m{1'b0}}} +   // z1     <<   m
        z0_ext;

  assign product = result_full[15:0];
endmodule

module karatsuba_6(
  input  [5:0] a,
  input  [5:0] b,
  output [11:0] product
);
  localparam m          = 3;
  localparam total_bits = 2 * m;
  // Дополняем нулями до total_bits, чтобы разрезы были одинаковой ширины
  wire [total_bits-1:0] a_ext = {{(total_bits-6){1'b0}}, a};
  wire [total_bits-1:0] b_ext = {{(total_bits-6){1'b0}}, b};

  wire [m-1:0] a_low  = a_ext[m-1:0];
  wire [m-1:0] a_high = a_ext[total_bits-1:m];
  wire [m-1:0] b_low  = b_ext[m-1:0];
  wire [m-1:0] b_high = b_ext[total_bits-1:m];

  wire [m:0] a_sum = a_high + a_low;
  wire [m:0] b_sum = b_high + b_low;

  wire [2*m-1:0]       z0;
  wire [2*m-1:0]       z2;
  wire [2*(m+1)-1:0]   z1_full;
  karatsuba_3 mul_low  (.a(a_low),  .b(b_low),  .product(z0));
  karatsuba_3 mul_high (.a(a_high), .b(b_high), .product(z2));
  karatsuba_4 mul_sum  (.a(a_sum), .b(b_sum), .product(z1_full));

  wire [2*(m+1)-1:0] z0_ext = {{2{1'b0}}, z0};
  wire [2*(m+1)-1:0] z2_ext = {{2{1'b0}}, z2};
  wire [2*(m+1)-1:0] z1     = z1_full - z0_ext - z2_ext;

  // 4*m+3 бит = 2*(m+1)+2*m + 1 (на перенос)
  wire [4*m+2:0] result_full;
  assign result_full =
        {z2_ext, {2*m{1'b0}}} +   // z2_ext << 2*m
        {z1,     {  m{1'b0}}} +   // z1     <<   m
        z0_ext;

  assign product = result_full[11:0];
endmodule

module karatsuba_9(
  input  [8:0] a,
  input  [8:0] b,
  output [17:0] product
);
  localparam m          = 5;
  localparam total_bits = 2 * m;
  // Дополняем нулями до total_bits, чтобы разрезы были одинаковой ширины
  wire [total_bits-1:0] a_ext = {{(total_bits-9){1'b0}}, a};
  wire [total_bits-1:0] b_ext = {{(total_bits-9){1'b0}}, b};

  wire [m-1:0] a_low  = a_ext[m-1:0];
  wire [m-1:0] a_high = a_ext[total_bits-1:m];
  wire [m-1:0] b_low  = b_ext[m-1:0];
  wire [m-1:0] b_high = b_ext[total_bits-1:m];

  wire [m:0] a_sum = a_high + a_low;
  wire [m:0] b_sum = b_high + b_low;

  wire [2*m-1:0]       z0;
  wire [2*m-1:0]       z2;
  wire [2*(m+1)-1:0]   z1_full;
  karatsuba_5 mul_low  (.a(a_low),  .b(b_low),  .product(z0));
  karatsuba_5 mul_high (.a(a_high), .b(b_high), .product(z2));
  karatsuba_6 mul_sum  (.a(a_sum), .b(b_sum), .product(z1_full));

  wire [2*(m+1)-1:0] z0_ext = {{2{1'b0}}, z0};
  wire [2*(m+1)-1:0] z2_ext = {{2{1'b0}}, z2};
  wire [2*(m+1)-1:0] z1     = z1_full - z0_ext - z2_ext;

  // 4*m+3 бит = 2*(m+1)+2*m + 1 (на перенос)
  wire [4*m+2:0] result_full;
  assign result_full =
        {z2_ext, {2*m{1'b0}}} +   // z2_ext << 2*m
        {z1,     {  m{1'b0}}} +   // z1     <<   m
        z0_ext;

  assign product = result_full[17:0];
endmodule

module karatsuba_16(
  input  [15:0] a,
  input  [15:0] b,
  output [31:0] product
);
  localparam m          = 8;
  localparam total_bits = 2 * m;
  // Дополняем нулями до total_bits, чтобы разрезы были одинаковой ширины
  wire [total_bits-1:0] a_ext = {{(total_bits-16){1'b0}}, a};
  wire [total_bits-1:0] b_ext = {{(total_bits-16){1'b0}}, b};

  wire [m-1:0] a_low  = a_ext[m-1:0];
  wire [m-1:0] a_high = a_ext[total_bits-1:m];
  wire [m-1:0] b_low  = b_ext[m-1:0];
  wire [m-1:0] b_high = b_ext[total_bits-1:m];

  wire [m:0] a_sum = a_high + a_low;
  wire [m:0] b_sum = b_high + b_low;

  wire [2*m-1:0]       z0;
  wire [2*m-1:0]       z2;
  wire [2*(m+1)-1:0]   z1_full;
  karatsuba_8 mul_low  (.a(a_low),  .b(b_low),  .product(z0));
  karatsuba_8 mul_high (.a(a_high), .b(b_high), .product(z2));
  karatsuba_9 mul_sum  (.a(a_sum), .b(b_sum), .product(z1_full));

  wire [2*(m+1)-1:0] z0_ext = {{2{1'b0}}, z0};
  wire [2*(m+1)-1:0] z2_ext = {{2{1'b0}}, z2};
  wire [2*(m+1)-1:0] z1     = z1_full - z0_ext - z2_ext;

  // 4*m+3 бит = 2*(m+1)+2*m + 1 (на перенос)
  wire [4*m+2:0] result_full;
  assign result_full =
        {z2_ext, {2*m{1'b0}}} +   // z2_ext << 2*m
        {z1,     {  m{1'b0}}} +   // z1     <<   m
        z0_ext;

  assign product = result_full[31:0];
endmodule

module mul_karatsuba(
  input  [15:0] a,
  input  [15:0] b,
  output [31:0] product
);
  karatsuba_16 inst(.a(a), .b(b), .product(product));
endmodule
