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

# Exports test case data to Binary files: inputs, weights, threshold, and expected result
def export_to_bin(test: dict, directory: str):
    name = test['name']
    pixels = flatten_matrix(test['pixels'])
    weights = flatten_matrix(test['weights'])
    mac_result = calculate_mac(pixels, weights)
    binary_result = int(mac_result >= test['threshold'])

    os.makedirs(directory, exist_ok=True)

    # Write inputs in binary (each byte is a pixel)
    with open(os.path.join(directory, f"{name}_inputs.bin"), 'wb') as f:
        f.write(bytes(pixels))

    # Write weights in binary
    with open(os.path.join(directory, f"{name}_weights.bin"), 'wb') as f:
        f.write(bytes(weights))

    # Write threshold as 3 bytes (big endian)
    with open(os.path.join(directory, f"{name}_threshold.bin"), 'wb') as f:
        threshold_bytes = [
            (test['threshold'] >> 16) & 0xFF,
            (test['threshold'] >> 8) & 0xFF,
            test['threshold'] & 0xFF
        ]
        f.write(bytes(threshold_bytes))

    # Write expected output: 3 bytes for MAC + 1 byte for binary result
    with open(os.path.join(directory, f"{name}_expected.bin"), 'wb') as f:
        expected_bytes = [
            (mac_result >> 16) & 0xFF,
            (mac_result >> 8) & 0xFF,
            mac_result & 0xFF,
            binary_result
        ]
        f.write(bytes(expected_bytes))


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

# Test with only one active pixel-weight pair
def generate_one_pair_test() -> dict:
    pixels = generate_matrix(lambda i, j: 0)
    weights = generate_matrix(lambda i, j: 0)
    pixels[0][0] = 10
    weights[0][0] = 3
    return {
        "name": "One_Pair_Test",
        "pixels": pixels,
        "weights": weights,
        "threshold": 30
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
        generate_one_pair_test(),
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
    tests.extend(generate_random_tests(2000))

    # Add walking bit tests
    tests.extend(generate_walking_1s_tests())
    tests.extend(generate_walking_0s_tests())

    # Export all tests to separate HEX files
    for test in tests:
        export_to_bin(test, output_folder)

    # Archive all test files into a ZIP
    shutil.make_archive("all_tests_hex", 'zip', output_folder)

# Script entry point
if __name__ == "__main__":
    generate_all_tests("generated_tests")
