import os
import random
import shutil
from typing import List, Callable

# Constants
MATRIX_SIZE = 8
PIXEL_WIDTH = 8
WEIGHT_WIDTH = 8
THRESHOLD_WIDTH = 22
ADDR_WIDTH = 16
DATA_WIDTH = 16
LOAD_DEPTH = 66
TOTAL_TESTS = 500

# Paths
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OUTPUT_DIR = os.path.join(SCRIPT_DIR, "on_chip_memory_sv")
OUTPUT_FILE = "on_chip_memory_large.sv"

# Utility functions
def generate_matrix(value_func: Callable[[int, int], int]) -> List[List[int]]:
    return [[value_func(i, j) for j in range(MATRIX_SIZE)] for i in range(MATRIX_SIZE)]

def flatten_matrix(mat: List[List[int]]) -> List[int]:
    return [mat[i][j] for i in range(MATRIX_SIZE) for j in range(MATRIX_SIZE)]

def calculate_mac(pixels: List[int], weights: List[int]) -> int:
    return sum(p * w for p, w in zip(pixels, weights))

def to_bin16(val: int) -> str:
    return f"{val & 0xFFFF:016b}"

# Test generators
def generate_threshold_sensitivity_tests(num: int) -> List[dict]:
    base_pixels = generate_matrix(lambda i, j: 2)
    base_weights = generate_matrix(lambda i, j: 2)
    flat_p = flatten_matrix(base_pixels)
    flat_w = flatten_matrix(base_weights)
    base_mac = calculate_mac(flat_p, flat_w)
    tests = []
    for _ in range(num):
        delta = random.choice([-1, 0, 1])
        threshold = max(0, base_mac + delta)
        tests.append({
            "pixels": base_pixels,
            "weights": base_weights,
            "threshold": threshold
        })
    return tests

def generate_dense_one_tests(num: int) -> List[dict]:
    tests = []
    for i in range(num):
        pixels = generate_matrix(lambda i, j: 1)
        weights = generate_matrix(lambda i, j: 1 if i < MATRIX_SIZE - 1 else random.randint(1, 255))
        threshold = random.randint(0, (1 << THRESHOLD_WIDTH) - 1)
        tests.append({
            "pixels": pixels,
            "weights": weights,
            "threshold": threshold
        })
    return tests

def generate_all_ones_test() -> dict:
    pixels = generate_matrix(lambda i, j: 255)
    weights = generate_matrix(lambda i, j: 255)
    threshold = (1 << THRESHOLD_WIDTH) - 1
    return {
        "pixels": pixels,
        "weights": weights,
        "threshold": threshold
    }

def generate_random_tests(num: int) -> List[dict]:
    tests = []
    for i in range(num):
        pixels = generate_matrix(lambda i, j: random.randint(0, 255))
        weights = generate_matrix(lambda i, j: random.randint(0, 255))
        threshold = random.randint(0, (1 << THRESHOLD_WIDTH) - 1)
        tests.append({
            "pixels": pixels,
            "weights": weights,
            "threshold": threshold
        })
    return tests

# SV generation
def create_combined_sv_module(tests: List[dict]) -> str:
    lines = []
    lines.append("module on_chip_memory #(")
    lines.append(f"    parameter ADDR_WIDTH = {ADDR_WIDTH},")
    lines.append(f"    parameter DATA_WIDTH = {DATA_WIDTH},")
    lines.append(f"    parameter LOAD_DEPTH = {LOAD_DEPTH * TOTAL_TESTS},")
    lines.append(f"    parameter TOTAL_TESTS = {TOTAL_TESTS}")
    lines.append(")(")
    lines.append("    input  wire                     clk,")
    lines.append("    input  wire                     reset_n,")
    lines.append("    input  wire                     rd_en,")
    lines.append(f"    input  wire [{ADDR_WIDTH-1}:0]    address_in,")
    lines.append(f"    input  wire [{TOTAL_TESTS.bit_length()-1}:0] test_count,")
    lines.append(f"    output reg  [{DATA_WIDTH-1}:0]    data_out,")
    lines.append("    output reg                      expected_out")
    lines.append(");")
    lines.append("")
    lines.append(f"    reg [{DATA_WIDTH-1}:0] mem [0:LOAD_DEPTH-1];")
    lines.append(f"    reg expected_mem [0:TOTAL_TESTS-1];")
    lines.append("")
    lines.append("    initial begin")
    for t, test in enumerate(tests):
        pixels = flatten_matrix(test['pixels'])
        weights = flatten_matrix(test['weights'])
        threshold = test['threshold']
        mac_result = calculate_mac(pixels, weights)
        expected_bit = int(mac_result >= threshold)
        lines.append(f"        // Test {t}")
        for idx, (p, w) in enumerate(zip(pixels, weights)):
            word = (p << 8) | w
            lines.append(f"        mem[{t*LOAD_DEPTH + idx}] = 16'b{to_bin16(word)};")
        lines.append(f"        mem[{t*LOAD_DEPTH + 64}] = 16'b{to_bin16(threshold & 0xFFFF)};")
        lines.append(f"        mem[{t*LOAD_DEPTH + 65}] = 16'b{to_bin16((threshold >> 16) & 0x3F)};")
        lines.append(f"        expected_mem[{t}] = 1'b{expected_bit};")
    lines.append("    end")
    lines.append("")
    lines.append("    always_ff @(posedge clk or negedge reset_n) begin")
    lines.append("        if (!reset_n) begin")
    lines.append("            data_out     <= '0;")
    lines.append("            expected_out <= 1'b0;")
    lines.append("        end else begin")
    lines.append("            if (rd_en) begin")
    lines.append("                data_out <= mem[address_in];")
    lines.append("            end")
    lines.append("            expected_out <= expected_mem[test_count];")
    lines.append("        end")
    lines.append("    end")
    lines.append("endmodule")
    return "\n".join(lines)

# Save function
def save_combined_sv(tests: List[dict]):
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    sv_code = create_combined_sv_module(tests)
    path = os.path.join(OUTPUT_DIR, OUTPUT_FILE)
    with open(path, "w") as f:
        f.write(sv_code)
    print(f"✅ Generated {OUTPUT_FILE} with {len(tests)} tests at: {path}")

# Main
if __name__ == "__main__":
    threshold_tests = generate_threshold_sensitivity_tests(200)
    dense_one_tests = generate_dense_one_tests(200)
    random_tests = generate_random_tests(TOTAL_TESTS - 200 - 1 - len(threshold_tests))
    final_test = [generate_all_ones_test()]
    combined_tests = threshold_tests + dense_one_tests + random_tests + final_test
    save_combined_sv(combined_tests)