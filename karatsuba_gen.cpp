#include <iostream>
#include <fstream>
#include <string>
#include <filesystem>
#include <set>

using namespace std;

void generate_karatsuba_module(ofstream &out, int N, int base_case, set<int> &generated)
{
    if (generated.find(N) != generated.end())
        return;
    generated.insert(N);

    if (N <= base_case)
    {
        out << "module karatsuba_" << N << "(\n"
            << "  input  [" << (N - 1) << ":0] a,\n"
            << "  input  [" << (N - 1) << ":0] b,\n"
            << "  output [" << (2 * N - 1) << ":0] product\n"
            << ");\n";
        out << "  integer i;\n";
        out << "  reg [" << (2 * N - 1) << ":0] prod;\n";
        out << "  always @(*) begin\n";
        out << "    prod = 0;\n";
        out << "    for (i = 0; i < " << N << "; i = i + 1) begin\n";
        out << "      if (b[i]) begin\n";
        out << "        prod = prod + (a << i);\n";
        out << "      end\n";
        out << "    end\n";
        out << "  end\n";
        out << "  assign product = prod;\n";
        out << "endmodule\n\n";
        return;
    }

    int m = (N + 1) / 2; // ceil(N/2)

    // Сначала порождённые подмодули, чтобы гарантировать правильный порядок объявлений
    generate_karatsuba_module(out, m, base_case, generated);
    generate_karatsuba_module(out, m + 1, base_case, generated);

    // Сам модуль на N бит
    out << "module karatsuba_" << N << "(\n"
        << "  input  [" << (N - 1) << ":0] a,\n"
        << "  input  [" << (N - 1) << ":0] b,\n"
        << "  output [" << (2 * N - 1) << ":0] product\n";
    out << ");\n";

    // Локальные параметры и расширенные версии операндов
    out << "  localparam m          = " << m << ";\n";
    out << "  localparam total_bits = 2 * m;\n";
    out << "  // Дополняем нулями до total_bits, чтобы разрезы были одинаковой ширины\n";
    out << "  wire [total_bits-1:0] a_ext = {{(total_bits-" << N << "){1'b0}}, a};\n";
    out << "  wire [total_bits-1:0] b_ext = {{(total_bits-" << N << "){1'b0}}, b};\n\n";

    // Разбиение на старшие / младшие части
    out << "  wire [m-1:0] a_low  = a_ext[m-1:0];\n";
    out << "  wire [m-1:0] a_high = a_ext[total_bits-1:m];\n";
    out << "  wire [m-1:0] b_low  = b_ext[m-1:0];\n";
    out << "  wire [m-1:0] b_high = b_ext[total_bits-1:m];\n\n";

    // Суммы для средней части (разрядность m+1)
    out << "  wire [m:0] a_sum = a_high + a_low;\n";
    out << "  wire [m:0] b_sum = b_high + b_low;\n\n";

    // Рекурсивные умножения
    out << "  wire [2*m-1:0]       z0;\n";
    out << "  wire [2*m-1:0]       z2;\n";
    out << "  wire [2*(m+1)-1:0]   z1_full;\n";
    out << "  karatsuba_" << m << " mul_low  (.a(a_low),  .b(b_low),  .product(z0));\n";
    out << "  karatsuba_" << m << " mul_high (.a(a_high), .b(b_high), .product(z2));\n";
    out << "  karatsuba_" << (m + 1) << " mul_sum  (.a(a_sum), .b(b_sum), .product(z1_full));\n\n";

    // Приведение всех частичных произведений к одинаковой ширине (2*(m+1) бит)
    out << "  wire [2*(m+1)-1:0] z0_ext = {{2{1'b0}}, z0};\n";
    out << "  wire [2*(m+1)-1:0] z2_ext = {{2{1'b0}}, z2};\n";
    out << "  wire [2*(m+1)-1:0] z1     = z1_full - z0_ext - z2_ext;\n\n";

    // Финальное склеивание
    out << "  // 4*m+3 бит = 2*(m+1)+2*m + 1 (на перенос)\n";
    out << "  wire [4*m+2:0] result_full;\n";
    out << "  assign result_full =\n"
        << "        {z2_ext, {2*m{1'b0}}} +   // z2_ext << 2*m\n"
        << "        {z1,     {  m{1'b0}}} +   // z1     <<   m\n"
        << "        z0_ext;\n\n";

    // Отсекаем избыточные старшие биты
    out << "  assign product = result_full[" << (2 * N - 1) << ":0];\n";
    out << "endmodule\n\n";
}

void generate_testbench(ofstream &out, int N)
{
    out << "`timescale 1ns/1ps\n\n";
    out << "module mul_karatsuba_tb;\n";
    out << "  reg  [" << (N - 1) << ":0] a;\n";
    out << "  reg  [" << (N - 1) << ":0] b;\n";
    out << "  wire [" << (2 * N - 1) << ":0] product;\n\n";
    out << "  mul_karatsuba uut (.a(a), .b(b), .product(product));\n\n";

    out << "  integer i;\n";
    out << "  reg [" << (2 * N - 1) << ":0] expected;\n";
    out << "  localparam num_random_tests = 1000;\n\n";

    out << "  initial begin\n";
    out << "    // Угловые тесты\n";
    // corner cases
    auto corner = [&](const string &aval, const string &bval, const string &name)
    {
        out << "    a = " << aval << "; b = " << bval << "; #10;\n";
        out << "    expected = a * b;\n";
        out << "    if (product !== expected)\n";
        out << "      $display(\"ERROR: " << name << ": expected %b, got %b\", expected, product);\n";
        out << "    else $display(\"Test " << name << " passed.\");\n\n";
    };
    corner("0", "0", "a=0, b=0");
    corner("0", string("{" + to_string(N) + "{1'b1}}"), "a=0, b=max");
    corner(string("{" + to_string(N) + "{1'b1}}"), "0", "a=max, b=0");
    corner(string("{" + to_string(N) + "{1'b1}}"), string("{" + to_string(N) + "{1'b1}}"), "a=max, b=max");
    corner("1", string("{" + to_string(N) + "{1'b1}}"), "a=1, b=max");
    corner(string("{" + to_string(N) + "{1'b1}}"), "1", "a=max, b=1");

    // Случайные тесты
    int words = (N + 31) / 32;
    out << "    // Случайные тесты\n";
    out << "    for (i = 0; i < num_random_tests; i = i + 1) begin\n";

    // генерируем a
    out << "      a = {";
    for (int j = 0; j < words; ++j)
    {
        if (j)
            out << ", ";
        out << "$urandom";
    }
    out << "};\n";

    // генерируем b
    out << "      b = {";
    for (int j = 0; j < words; ++j)
    {
        if (j)
            out << ", ";
        out << "$urandom";
    }
    out << "};\n";

    out << "      #5;\n";
    out << "      expected = a * b;\n";
    out << "      if (product !== expected) begin\n";
    out << "        $display(\"ERROR: Random test %d failed: a=%h, b=%h, expected=%h, got=%h\", i, a, b, expected, product);\n";
    out << "      end else begin\n";
    out << "         $display(\"Random test %d passed.\", i);\n";
    out << "      end\n";
    out << "    end\n\n";
    out << "    $display(\"All tests completed.\");\n";
    out << "    $finish;\n";
    out << "  end\n";
    out << "endmodule\n";
}

int main(int argc, char *argv[])
{
    int N = 16;               // разрядность по‑умолчанию
    int base_case = 3;        // порог, после которого умножаем напрямую
    string out_dir = "build"; // директория для сохранения результата

    // Парсинг аргументов
    for (int i = 1; i < argc; ++i)
    {
        string arg = argv[i];
        if (arg == "-N" && i + 1 < argc)
        {
            N = atoi(argv[++i]);
            if (N <= 0 || N > 1024)
            {
                cerr << "Invalid N value. Must be 1-1024." << endl;
                return 1;
            }
        }
        else if (arg == "-B" && i + 1 < argc)
        {
            base_case = atoi(argv[++i]);
            if (base_case <= 0 || base_case > 16)
            {
                cerr << "Invalid base case value. Must be 1-16." << endl;
                return 1;
            }
        }
        else if (arg == "-h" || arg == "--help")
        {
            cout << "Usage: " << argv[0] << " [-N bits] [-B base_case]\n"
                 << "Options:\n"
                 << "  -N <bits>      : Bit width (1-1024, default: 16)\n"
                 << "  -B <base_case> : Recursion threshold (1-16, default: 4)\n";
            return 0;
        }
    }

    filesystem::create_directory(out_dir);

    // Генерация модуля
    ofstream module_file(out_dir + "/mul_karatsuba.v");
    if (!module_file)
    {
        cerr << "Error creating mul_karatsuba.v" << endl;
        return 1;
    }

    set<int> generated;
    generate_karatsuba_module(module_file, N, base_case, generated);

    module_file << "module mul_karatsuba(\n"
                << "  input  [" << (N - 1) << ":0] a,\n"
                << "  input  [" << (N - 1) << ":0] b,\n"
                << "  output [" << (2 * N - 1) << ":0] product\n";
    module_file << ");\n";
    module_file << "  karatsuba_" << N << " inst(.a(a), .b(b), .product(product));\n";
    module_file << "endmodule\n";
    module_file.close();

    // Генерация тестбенча
    ofstream tb_file(out_dir + "/mul_karatsuba_tb.v");
    if (!tb_file)
    {
        cerr << "Error creating mul_karatsuba_tb.v" << endl;
        return 1;
    }
    generate_testbench(tb_file, N);
    tb_file.close();

    cout << "Generated " << N << "-bit multiplier with base case " << base_case << endl;
    cout << "Files: " << out_dir << "/mul_karatsuba.v and " << out_dir << "/mul_karatsuba_tb.v" << endl;
    return 0;
}