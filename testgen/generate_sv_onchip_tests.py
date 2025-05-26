import os
import random
import shutil
from typing import List, Callable

# Constants for matrix and bit widths
MATRIX_SIZE = 8
PIXEL_WIDTH = 8
WEIGHT_WIDTH = 8
THRESHOLD_WIDTH = 22
OUTPUT_DIR = "on_chip_test_sv"

# Generate an 8x8 matrix using a value-generating function
def generate_matrix(value_func: Callable[[int, int], int]) -> List[List[int]]:
    return [[value_func(i, j) for j in range(MATRIX_SIZE)] for i in range(MATRIX_SIZE)]

# Flatten a 2D matrix into a 1D row-major list
def flatten_matrix(mat: List[List[int]]) -> List[int]:
    return [mat[i][j] for i in range(MATRIX_SIZE) for j in range(MATRIX_SIZE)]

# Compute the MAC (Multiply-Accumulate) result
def calculate_mac(pixels: List[int], weights: List[int]) -> int:
    return sum(p * w for p, w in zip(pixels, weights))

# Convert an integer to a 16-bit binary string
def to_bin16(val: int) -> str:
    return f"{val & 0xFFFF:016b}"

# Create a SystemVerilog memory module from a test case
def create_sv_module(test: dict, name: str) -> str:
    pixels = flatten_matrix(test['pixels'])
    weights = flatten_matrix(test['weights'])
    threshold = test['threshold']
    mac_result = calculate_mac(pixels, weights)
    binary_result = int(mac_result >= threshold)

    data_lines = []
    for i, (p, w) in enumerate(zip(pixels, weights)):
        word = (p << 8) | w
        data_lines.append(f"\t\t mem[{i}] = 16'b{to_bin16(word)};")

    data_lines.append(f"\t\t mem[64] = 16'b{to_bin16(threshold & 0xFFFF)};")
    data_lines.append(f"\t\t mem[65] = 16'b{to_bin16((threshold >> 16) & 0x3F)};")
    data_lines.append(f"\t\t expected_reg = 1'b{binary_result};")

    return f"""module on_chip_memory #(
    parameter ADDR_WIDTH = 7,
    parameter DATA_WIDTH = 16,
    parameter LOAD_DEPTH = 66
)(
    input  wire                     clk,
    input  wire                     reset_n,
    input  wire                     rd_en,
    input  wire [ADDR_WIDTH-1:0]    address_in,
    output reg  [DATA_WIDTH-1:0]              data_out,
    output reg                      expected_out
);

    reg [DATA_WIDTH-1:0] mem [0:LOAD_DEPTH-1];
    reg expected_reg;

    initial begin
{chr(10).join(data_lines)}
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            data_out     <= 16'b0;
            expected_out <= 1'b0;
        end else begin
            if (rd_en) begin
                data_out <= mem[address_in];
            end
            expected_out <= expected_reg;
        end
    end

endmodule
"""

# Save each SV module as a file and create a ZIP
def save_sv_files_and_zip(tests: List[dict]):
    if os.path.exists(OUTPUT_DIR):
        shutil.rmtree(OUTPUT_DIR)
    os.makedirs(OUTPUT_DIR)

    for test in tests:
        module_code = create_sv_module(test, test["name"])
        filename = f"on_chip_memory_{test['name']}.sv"
        with open(os.path.join(OUTPUT_DIR, filename), "w") as f:
            f.write(module_code)


# Generate all predefined tests
def generate_all_named_tests() -> List[dict]:
    def generate_typical_input_test():
        return {
            "name": "Functional_Typical",
            "pixels": generate_matrix(lambda i, j: i * MATRIX_SIZE + j + 1),
            "weights": generate_matrix(lambda i, j: 2),
            "threshold": 4000
        }

    def generate_max_value_test():
        return {
            "name": "Max_Value_Test",
            "pixels": generate_matrix(lambda i, j: 255),
            "weights": generate_matrix(lambda i, j: 255),
            "threshold": (1 << THRESHOLD_WIDTH) - 1
        }

    def generate_min_value_test():
        return {
            "name": "Min_Value_Test",
            "pixels": generate_matrix(lambda i, j: 0),
            "weights": generate_matrix(lambda i, j: 0),
            "threshold": 0
        }

    def generate_threshold_sensitivity_test():
        pixels = generate_matrix(lambda i, j: 2)
        weights = generate_matrix(lambda i, j: 2)
        mac = calculate_mac(flatten_matrix(pixels), flatten_matrix(weights))
        return {
            "name": "Threshold_Sensitivity_Test",
            "pixels": pixels,
            "weights": weights,
            "threshold": mac - 1
        }

    def generate_overflow_test():
        return {
            "name": "Overflow_Test",
            "pixels": generate_matrix(lambda i, j: 255),
            "weights": generate_matrix(lambda i, j: 255),
            "threshold": 0
        }

    def generate_sparse_input_test():
        pixels = generate_matrix(lambda i, j: 0)
        weights = generate_matrix(lambda i, j: 0)
        pixels[0][0] = 10
        weights[0][0] = 3
        pixels[7][7] = 5
        weights[7][7] = 2
        return {
            "name": "Sparse_Input_Test",
            "pixels": pixels,
            "weights": weights,
            "threshold": 30
        }

    def generate_pattern_test(name, func):
        pattern = lambda i, j: func(i * MATRIX_SIZE + j)
        return {
            "name": name,
            "pixels": generate_matrix(pattern),
            "weights": generate_matrix(pattern),
            "threshold": 0
        }

    def generate_invalid_threshold_test():
        return {
            "name": "Invalid_Threshold_Test",
            "pixels": generate_matrix(lambda i, j: 5),
            "weights": generate_matrix(lambda i, j: 5),
            "threshold": (1 << THRESHOLD_WIDTH) + 100
        }

    def generate_interrupted_data_test():
        pixels = generate_matrix(lambda i, j: 0)
        weights = generate_matrix(lambda i, j: 0)
        for idx in range(32):
            i, j = divmod(idx, MATRIX_SIZE)
            pixels[i][j] = 3
            weights[i][j] = 4
        return {
            "name": "Interrupted_Data_Test",
            "pixels": pixels,
            "weights": weights,
            "threshold": 384
        }

    def generate_two_cycle_read_test():
        return {
            "name": "Two_Cycle_MAC_Read_Test",
            "pixels": generate_matrix(lambda i, j: 5),
            "weights": generate_matrix(lambda i, j: 6),
            "threshold": 0
        }

    def generate_retention_test():
        return {
            "name": "Retention_Test",
            "pixels": generate_matrix(lambda i, j: (i * MATRIX_SIZE + j) % 2),
            "weights": generate_matrix(lambda i, j: (i * MATRIX_SIZE + j) % 2),
            "threshold": 0
        }

    def generate_address_decoding_test():
        return {
            "name": "Address_Decoding_Test",
            "pixels": generate_matrix(lambda i, j: (i + j) % 256),
            "weights": generate_matrix(lambda i, j: (i * j) % 256),
            "threshold": 1000
        }

    def generate_data_bus_stress_test():
        pattern = lambda i, j: ((i * MATRIX_SIZE + j) % 2) * 255
        return {
            "name": "Data_Bus_Stress_Test",
            "pixels": generate_matrix(pattern),
            "weights": generate_matrix(pattern),
            "threshold": 0
        }

    def generate_walking_1s_tests():
        return [
            {
                "name": f"Walking_1s_{idx}",
                "pixels": generate_matrix(lambda i, j: 1 if i * MATRIX_SIZE + j == idx else 0),
                "weights": generate_matrix(lambda i, j: 1 if i * MATRIX_SIZE + j == idx else 0),
                "threshold": 0
            } for idx in range(64)
        ]

    def generate_walking_0s_tests():
        return [
            {
                "name": f"Walking_0s_{idx}",
                "pixels": generate_matrix(lambda i, j: 0 if i * MATRIX_SIZE + j == idx else 1),
                "weights": generate_matrix(lambda i, j: 0 if i * MATRIX_SIZE + j == idx else 1),
                "threshold": 64
            } for idx in range(64)
        ]

    return [
        generate_typical_input_test(),
        generate_max_value_test(),
        generate_min_value_test(),
        generate_threshold_sensitivity_test(),
        generate_overflow_test(),
        generate_sparse_input_test(),
        generate_pattern_test("Pattern_010101", lambda idx: 1 if idx % 2 == 0 else 0),
        generate_pattern_test("Pattern_101010", lambda idx: 0 if idx % 2 == 0 else 1),
        generate_invalid_threshold_test(),
        generate_interrupted_data_test(),
        generate_two_cycle_read_test(),
        generate_retention_test(),
        generate_address_decoding_test(),
        generate_data_bus_stress_test()
    ] + generate_walking_1s_tests() + generate_walking_0s_tests()

# Main execution
if __name__ == "__main__":
    all_tests = generate_all_named_tests()
    save_sv_files_and_zip(all_tests)