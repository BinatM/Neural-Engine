import os
import random
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
NUM_FILES = 5

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OUTPUT_DIR = os.path.join(SCRIPT_DIR, "on_chip_memory_sv_multi")

# Utility functions
def generate_matrix(func: Callable[[int, int], int]) -> List[List[int]]:
    return [[func(i, j) for j in range(MATRIX_SIZE)] for i in range(MATRIX_SIZE)]

def flatten(mat: List[List[int]]) -> List[int]:
    return [mat[i][j] for i in range(MATRIX_SIZE) for j in range(MATRIX_SIZE)]

def mac(pix: List[int], wei: List[int]) -> int:
    return sum(p * w for p, w in zip(pix, wei))

def to_bin16(val: int) -> str:
    return f"{val & 0xFFFF:016b}"

# Test generator
def generate_balanced_tests(n: int) -> List[dict]:
    tests = []
    for _ in range(n):
        threshold = random.randint(0, 0xFFFF)  # Limit to 16-bit
        desired = random.choice([0, 1])

        while True:
            if random.random() < 0.3:
                # edge case: full ones
                pixels = generate_matrix(lambda i, j: 255)
                weights = generate_matrix(lambda i, j: 255)
            elif random.random() < 0.6:
                # sparse: mostly zeros
                pixels = generate_matrix(lambda i, j: 0 if random.random() < 0.8 else random.randint(1, 30))
                weights = generate_matrix(lambda i, j: 0 if random.random() < 0.8 else random.randint(1, 30))
            else:
                # mixed
                pixels = generate_matrix(lambda i, j: random.randint(0, 255))
                weights = generate_matrix(lambda i, j: random.randint(0, 255))

            mac_val = mac(flatten(pixels), flatten(weights))
            if (mac_val >= threshold and desired == 1) or (mac_val < threshold and desired == 0):
                tests.append({
                    "pixels": pixels,
                    "weights": weights,
                    "threshold": threshold
                })
                break
    return tests

# SV creation
def create_sv_module(tests: List[dict], total_tests: int) -> str:
    lines = []
    lines.append("module on_chip_memory #(")
    lines.append(f"    parameter ADDR_WIDTH = {ADDR_WIDTH},")
    lines.append(f"    parameter DATA_WIDTH = {DATA_WIDTH},")
    lines.append(f"    parameter LOAD_DEPTH = {LOAD_DEPTH * total_tests},")
    lines.append(f"    parameter TOTAL_TESTS = {total_tests}")
    lines.append(")(")
    lines.append("    input  wire                     clk,")
    lines.append("    input  wire                     reset_n,")
    lines.append("    input  wire                     rd_en,")
    lines.append(f"    input  wire [{ADDR_WIDTH-1}:0]    address_in,")
    lines.append(f"    input  wire [{total_tests.bit_length()-1}:0] test_count,")
    lines.append(f"    output reg  [{DATA_WIDTH-1}:0]    data_out,")
    lines.append("    output reg                      expected_out")
    lines.append(");")
    lines.append("")
    lines.append(f"    reg [{DATA_WIDTH-1}:0] mem [0:LOAD_DEPTH-1];")
    lines.append(f"    reg expected_mem [0:TOTAL_TESTS-1];")
    lines.append("")
    lines.append("    initial begin")

    for t, test in enumerate(tests):
        pixels = flatten(test["pixels"])
        weights = flatten(test["weights"])
        threshold = test["threshold"]
        mac_result = mac(pixels, weights)
        expected = int(mac_result >= threshold)

        lines.append(f"        // Test {t}")
        for idx, (p, w) in enumerate(zip(pixels, weights)):
            word = (p << 8) | w
            lines.append(f"        mem[{t*LOAD_DEPTH + idx}] = 16'b{to_bin16(word)};")
        lines.append(f"        mem[{t*LOAD_DEPTH + 64}] = 16'b{to_bin16(threshold)};")
        lines.append(f"        mem[{t*LOAD_DEPTH + 65}] = 16'b0000000000000000;")
        lines.append(f"        expected_mem[{t}] = 1'b{expected};")

    lines.append("    end\n")
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
    lines.append("    end\n")
    lines.append("endmodule")

    return "\n".join(lines)

# Save to file
def save_sv_file(tests: List[dict], index: int):
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    filename = f"on_chip_memory_set{index}.sv"
    full_path = os.path.join(OUTPUT_DIR, filename)
    code = create_sv_module(tests, TOTAL_TESTS)
    with open(full_path, "w") as f:
        f.write(code)
    print(f"✅ Generated {filename} with {len(tests)} tests at {full_path}")

# Main
if __name__ == "__main__":
    for i in range(1, NUM_FILES + 1):
        test_set = generate_balanced_tests(TOTAL_TESTS)
        save_sv_file(test_set, i)