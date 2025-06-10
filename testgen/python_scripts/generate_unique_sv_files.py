import os
import random
from typing import List, Dict, Callable

# Constants
MATRIX_SIZE = 8
PIXEL_WIDTH = 8
WEIGHT_WIDTH = 8
THRESHOLD_WIDTH = 22  
ADDR_WIDTH = 16
DATA_WIDTH = 16
LOAD_DEPTH = 66
TOTAL_TESTS_PER_FILE = 490
TOTAL_FILES = 10

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OUTPUT_DIR = os.path.join(SCRIPT_DIR, "on_chip_memory_sv_unique_new")
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Utility Functions
def generate_matrix(val_fn: Callable[[int, int], int]) -> List[List[int]]:
    return [[val_fn(i, j) for j in range(MATRIX_SIZE)] for i in range(MATRIX_SIZE)]

def flatten_matrix(matrix: List[List[int]]) -> List[int]:
    return [matrix[i][j] for i in range(MATRIX_SIZE) for j in range(MATRIX_SIZE)]

def calculate_mac(pixels: List[int], weights: List[int]) -> int:
    return sum(p * w for p, w in zip(pixels, weights))

def to_bin16(val: int) -> str:
    return f"{val & 0xFFFF:016b}"

def generate_unique_test(existing_keys: set) -> Dict:
    while True:
        pixels = generate_matrix(lambda i, j: random.choice([0, random.randint(0, 255)]))
        weights = generate_matrix(lambda i, j: random.choice([0, random.randint(0, 255)]))
        flat_pixels = flatten_matrix(pixels)
        flat_weights = flatten_matrix(weights)
        mac = calculate_mac(flat_pixels, flat_weights)
        threshold = random.randint(0, (1 << THRESHOLD_WIDTH) - 1)
        expected = int(mac >= threshold)

        # Unique key representation
        key = (tuple(flat_pixels), tuple(flat_weights), threshold)
        if key not in existing_keys:
            existing_keys.add(key)
            return {
                "pixels": pixels,
                "weights": weights,
                "threshold": threshold,
                "expected": expected
            }

def create_sv_module(tests: List[Dict], filename: str):
    lines = []
    # ─── module header ──────────────────────────────────────────────────────────
    lines.append("module on_chip_memory #(")
    lines.append(f"    parameter ADDR_WIDTH = {ADDR_WIDTH},")
    lines.append(f"    parameter DATA_WIDTH = {DATA_WIDTH},")
    lines.append(f"    parameter LOAD_DEPTH = {LOAD_DEPTH * TOTAL_TESTS_PER_FILE},")
    lines.append(f"    parameter TOTAL_TESTS = {TOTAL_TESTS_PER_FILE}")
    lines.append(")(")
    lines.append("    input  wire                     clk,")
    lines.append("    input  wire                     reset_n,")
    lines.append(f"    input  wire [{ADDR_WIDTH-1}:0] address_in,")
    lines.append(f"    input  wire [{TOTAL_TESTS_PER_FILE.bit_length()-1}:0] test_count,")
    lines.append(f"    output reg  [{DATA_WIDTH-1}:0] data_out,")
    lines.append("    output reg                     expected_out")
    lines.append(");")
    lines.append("")  # end of header

    # ─── memory declarations ────────────────────────────────────────────────────
    lines.append(f"    reg [{DATA_WIDTH-1}:0] mem [0:LOAD_DEPTH-1];")
    lines.append(f"    reg expected_mem [0:TOTAL_TESTS-1];")
    lines.append("")  # blank line before initial

    # ─── initial block ──────────────────────────────────────────────────────────
    lines.append("    initial begin")


    for t, test in enumerate(tests):
        pixels   = flatten_matrix(test['pixels'])
        weights  = flatten_matrix(test['weights'])
        threshold= test['threshold']
        expected = test['expected']

        # split threshold into two DATA_WIDTH-bit words
        low_bits  = threshold & ((1 << DATA_WIDTH) - 1)  # lower DATA_WIDTH bits
        high_bits = threshold >> DATA_WIDTH              # remaining upper bits

        # comment before each test
        lines.append(f"        // Test {t}")

        # write the 64 pixel–weight words
        for i, (px, wt) in enumerate(zip(pixels, weights)):
            word = (px << WEIGHT_WIDTH) | wt
            lines.append(f"        mem[{t*LOAD_DEPTH + i}] = 16'b{to_bin16(word)};")

        # after the 64 words, write the two threshold words
        lines.append(f"        mem[{t*LOAD_DEPTH + 64}] = 16'b{to_bin16(low_bits)};   // lower DATA_WIDTH bits of threshold")
        lines.append(f"        mem[{t*LOAD_DEPTH + 65}] = 16'b{to_bin16(high_bits)};  // upper threshold bits")

        # then write the expected result
        lines.append(f"        expected_mem[{t}] = 1'b{expected};")

   
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

    with open(os.path.join(OUTPUT_DIR, filename), "w") as f:
        f.write("\n".join(lines))



# Main generation loop
if __name__ == "__main__":
    global_keys = set()
    for i in range(1, TOTAL_FILES + 1):
        tests = []
        while len(tests) < TOTAL_TESTS_PER_FILE:
            test = generate_unique_test(global_keys)
            tests.append(test)

        filename = f"on_chip_memory_{i}.sv"
        create_sv_module(tests, filename)
        print(f" Generated {filename} with {TOTAL_TESTS_PER_FILE} unique tests")