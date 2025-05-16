import os
import random
import shutil
from typing import List, Tuple, Callable, Dict

# Constants defining matrix dimensions and bit-widths
MATRIX_SIZE = 8
PIXEL_WIDTH = 8
WEIGHT_WIDTH = 8
THRESHOLD_WIDTH = 22
MAX_VAL = (1 << PIXEL_WIDTH) - 1  # Maximum pixel/weight value (255)

# Generates an 8x8 matrix based on a custom value function
def generate_matrix(value_func: Callable[[int, int], int]) -> List[List[int]]:
    return [[value_func(i, j) for j in range(MATRIX_SIZE)] for i in range(MATRIX_SIZE)]

# Flattens a 2D matrix to a 1D list (row-major order)
def flatten_matrix(mat: List[List[int]]) -> List[int]:
    return [mat[i][j] for i in range(MATRIX_SIZE) for j in range(MATRIX_SIZE)]

# Calculates MAC result as dot product of flattened pixel-weight lists
def calculate_mac(pixels: List[int], weights: List[int]) -> int:
    return sum(p * w for p, w in zip(pixels, weights))

# Split 22-bit integer into two 16-bit padded hex strings
def split_22bit_to_2words(val: int) -> Tuple[str, str]:
    lower = val & 0xFFFF
    upper = (val >> 16) & 0x3F
    return f"{lower:016b}", f"{upper:016b}"

# Write all tests into one .hex file in custom test format
def export_all_tests_to_binary_file(tests: list, output_file: str):
    lines = []

    # First line: number of tests as 16-bit binary
    lines.append(f"{len(tests):016b}")

    for test in tests:
        pixels = flatten_matrix(test['pixels'])
        weights = flatten_matrix(test['weights'])
        mac_result = calculate_mac(pixels, weights)
        binary_result = int(mac_result >= test['threshold'])

        # Start-of-test marker
        lines.append(f"{0xABCD:016b}")

        # 64 pixel-weight pairs
        for px, wt in zip(pixels, weights):
            combined = (px << 8) | wt
            lines.append(f"{combined:016b}")

        # Threshold (22-bit split into 2 binary words)
        thr_low, thr_high = split_22bit_to_2words(test['threshold'])
        lines.append(thr_low)
        lines.append(thr_high)

        # Expected result: 0 or 1 as 16-bit word
        lines.append(f"{binary_result:016b}")

    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    with open(output_file, 'w') as f:
        for line in lines:
            f.write(line + '\n')


# === TEST CASE GENERATORS ===

# Typical input test: pixels = 1..64, weights = 2
def generate_typical_input_test() -> dict:
    pixels = generate_matrix(lambda i, j: i * MATRIX_SIZE + j + 1)
    weights = generate_matrix(lambda i, j: 2)
    return {
        "name": "Functional_Typical",
        "pixels": pixels,
        "weights": weights,
        "threshold": 4000
    }

# Generates multiple randomized test cases
def generate_random_tests(num_tests: int) -> list[dict]:
    tests = []
    for i in range(num_tests):
        pixels = generate_matrix(lambda i, j: random.randint(0, 255))
        weights = generate_matrix(lambda i, j: random.randint(0, 255))
        threshold = random.randint(0, (1 << THRESHOLD_WIDTH) - 1)
        tests.append({
            "name": f"Random_Test_{i+1}",
            "pixels": pixels,
            "weights": weights,
            "threshold": threshold
        })
    return tests

# Test with all max values (255)
def generate_max_value_test() -> dict:
    pixels = generate_matrix(lambda i, j: 255)
    weights = generate_matrix(lambda i, j: 255)
    return {
        "name": "Max_Value_Test",
        "pixels": pixels,
        "weights": weights,
        "threshold": (1 << THRESHOLD_WIDTH) - 1
    }

# Test with all zero values
def generate_min_value_test() -> dict:
    pixels = generate_matrix(lambda i, j: 0)
    weights = generate_matrix(lambda i, j: 0)
    return {
        "name": "Min_Value_Test",
        "pixels": pixels,
        "weights": weights,
        "threshold": 0
    }


# Test for threshold sensitivity: MAC result just above threshold
def generate_threshold_sensitivity_test() -> dict:
    pixels = generate_matrix(lambda i, j: 2)
    weights = generate_matrix(lambda i, j: 2)
    mac = calculate_mac(flatten_matrix(pixels), flatten_matrix(weights))
    return {
        "name": "Threshold_Sensitivity_Test",
        "pixels": pixels,
        "weights": weights,
        "threshold": mac - 1
    }

# Test for MAC overflow (large accumulation)
def generate_overflow_test() -> dict:
    pixels = generate_matrix(lambda i, j: 255)
    weights = generate_matrix(lambda i, j: 255)
    return {
        "name": "Overflow_Test",
        "pixels": pixels,
        "weights": weights,
        "threshold": 0
    }

# Test with mostly zero values and a few non-zero pairs
def generate_sparse_input_test() -> dict:
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

# Pattern test: custom pixel-weight patterns based on index
def generate_pattern_test(name: str, pattern_func: Callable[[int], int]) -> dict:
    pattern = lambda i, j: pattern_func(i * MATRIX_SIZE + j)
    pixels = generate_matrix(pattern)
    weights = generate_matrix(pattern)
    return {
        "name": name,
        "pixels": pixels,
        "weights": weights,
        "threshold": 0
    }

# Walking 1s test: each pixel-weight pair set to 1 one at a time
def generate_walking_1s_tests() -> List[dict]:
    return [
        {
            "name": f"Walking_1s_{idx}",
            "pixels": generate_matrix(lambda i, j: 1 if i * MATRIX_SIZE + j == idx else 0),
            "weights": generate_matrix(lambda i, j: 1 if i * MATRIX_SIZE + j == idx else 0),
            "threshold": 0
        }
        for idx in range(64)
    ]

# Walking 0s test: each pixel-weight pair set to 0 one at a time
def generate_walking_0s_tests() -> List[dict]:
    return [
        {
            "name": f"Walking_0s_{idx}",
            "pixels": generate_matrix(lambda i, j: 0 if i * MATRIX_SIZE + j == idx else 1),
            "weights": generate_matrix(lambda i, j: 0 if i * MATRIX_SIZE + j == idx else 1),
            "threshold": 64
        }
        for idx in range(64)
    ]

# Test with an invalid threshold (greater than 22-bit)
def generate_invalid_threshold_test() -> dict:
    pixels = generate_matrix(lambda i, j: 5)
    weights = generate_matrix(lambda i, j: 5)
    threshold = (1 << THRESHOLD_WIDTH) + 100
    return {
        "name": "Invalid_Threshold_Test",
        "pixels": pixels,
        "weights": weights,
        "threshold": threshold
    }

# Test simulating partial input followed by pause (half matrix active)
def generate_interrupted_data_test() -> dict:
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

# Test for two-cycle MAC read (output expected to be split)
def generate_two_cycle_read_test() -> dict:
    pixels = generate_matrix(lambda i, j: 5)
    weights = generate_matrix(lambda i, j: 6)
    return {
        "name": "Two_Cycle_MAC_Read_Test",
        "pixels": pixels,
        "weights": weights,
        "threshold": 0
    }

# Retention test with checkerboard pattern
def generate_retention_test() -> dict:
    pattern = lambda i, j: (i * MATRIX_SIZE + j) % 2
    pixels = generate_matrix(pattern)
    weights = generate_matrix(pattern)
    return {
        "name": "Retention_Test",
        "pixels": pixels,
        "weights": weights,
        "threshold": 0
    }

# Address decoding test: each pixel and weight has unique pattern
def generate_address_decoding_test() -> dict:
    pixels = generate_matrix(lambda i, j: (i + j) % 256)
    weights = generate_matrix(lambda i, j: (i * j) % 256)
    return {
        "name": "Address_Decoding_Test",
        "pixels": pixels,
        "weights": weights,
        "threshold": 1000
    }

# Data bus stress test with alternating max and zero values
def generate_data_bus_stress_test() -> dict:
    pattern = lambda i, j: ((i * MATRIX_SIZE + j) % 2) * 255
    pixels = generate_matrix(pattern)
    weights = generate_matrix(pattern)
    return {
        "name": "Data_Bus_Stress_Test",
        "pixels": pixels,
        "weights": weights,
        "threshold": 0
    }

# === MAIN TEST GENERATION SCRIPT ===

# Generates and exports all test cases into HEX format
def generate_all_tests(output_folder: str):
    tests = [
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
    ]

    # Add many randomized tests (e.g., 2000)
    tests.extend(generate_random_tests(5))

    # Add walking bit tests
    tests.extend(generate_walking_1s_tests())
    tests.extend(generate_walking_0s_tests())

    # Write full test file
    export_all_tests_to_binary_file(tests, os.path.join(output_folder, "full_tests.bin"))


    # Archive all test files into a ZIP
    shutil.make_archive("all_tests_hex", 'zip', output_folder)

# Script entry point
if __name__ == "__main__":
    generate_all_tests("generated_tests")
