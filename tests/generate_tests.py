import os
import random
from typing import List, Tuple, Callable, Dict

# Constants
MATRIX_SIZE = 8
PIXEL_WIDTH = 8
WEIGHT_WIDTH = 8
THRESHOLD_WIDTH = 22
MAX_VAL = (1 << PIXEL_WIDTH) - 1

def generate_matrix(value_func: Callable[[int, int], int]) -> List[List[int]]:
    return [[value_func(i, j) for j in range(MATRIX_SIZE)] for i in range(MATRIX_SIZE)]

def flatten_matrix(mat: List[List[int]]) -> List[int]:
    return [mat[i][j] for i in range(MATRIX_SIZE) for j in range(MATRIX_SIZE)]

def calculate_mac(pixels: List[int], weights: List[int]) -> int:
    return sum(p * w for p, w in zip(pixels, weights))

def export_to_hex(test: dict, directory: str):
    name = test['name']
    pixels = flatten_matrix(test['pixels'])
    weights = flatten_matrix(test['weights'])
    mac_result = calculate_mac(pixels, weights)
    binary_result = int(mac_result >= test['threshold'])

    os.makedirs(directory, exist_ok=True)

    with open(os.path.join(directory, f"{name}_inputs.hex"), 'w') as f:
        for val in pixels:
            f.write(f"{val:02X}\n")

    with open(os.path.join(directory, f"{name}_weights.hex"), 'w') as f:
        for val in weights:
            f.write(f"{val:02X}\n")

    with open(os.path.join(directory, f"{name}_threshold.hex"), 'w') as f:
        f.write(f"{(test['threshold'] >> 16) & 0xFF:02X}\n")
        f.write(f"{(test['threshold'] >> 8) & 0xFF:02X}\n")
        f.write(f"{test['threshold'] & 0xFF:02X}\n")

    with open(os.path.join(directory, f"{name}_expected.hex"), 'w') as f:
        f.write(f"{(mac_result >> 16) & 0xFF:02X}\n")
        f.write(f"{(mac_result >> 8) & 0xFF:02X}\n")
        f.write(f"{mac_result & 0xFF:02X}\n")
        f.write(f"{binary_result:02X}\n")

# === TEST CASE GENERATORS ===

def generate_typical_input_test() -> dict:
    pixels = generate_matrix(lambda i, j: i * MATRIX_SIZE + j + 1)
    weights = generate_matrix(lambda i, j: 2)
    return {
        "name": "Functional_Typical",
        "pixels": pixels,
        "weights": weights,
        "threshold": 4000
    }

def generate_random_test(seed: int = 42) -> dict:
    random.seed(seed)
    pixels = generate_matrix(lambda i, j: random.randint(0, MAX_VAL))
    weights = generate_matrix(lambda i, j: random.randint(0, MAX_VAL))
    return {
        "name": "Random_Test",
        "pixels": pixels,
        "weights": weights,
        "threshold": random.randint(0, (1 << THRESHOLD_WIDTH) - 1)
    }

def generate_max_value_test() -> dict:
    pixels = generate_matrix(lambda i, j: 255)
    weights = generate_matrix(lambda i, j: 255)
    return {
        "name": "Max_Value_Test",
        "pixels": pixels,
        "weights": weights,
        "threshold": (1 << THRESHOLD_WIDTH) - 1
    }

def generate_min_value_test() -> dict:
    pixels = generate_matrix(lambda i, j: 0)
    weights = generate_matrix(lambda i, j: 0)
    return {
        "name": "Min_Value_Test",
        "pixels": pixels,
        "weights": weights,
        "threshold": 0
    }

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

def generate_overflow_test() -> dict:
    pixels = generate_matrix(lambda i, j: 255)
    weights = generate_matrix(lambda i, j: 255)
    return {
        "name": "Overflow_Test",
        "pixels": pixels,
        "weights": weights,
        "threshold": 0
    }

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


def generate_invalid_threshold_test() -> dict:
    pixels = generate_matrix(lambda i, j: 5)
    weights = generate_matrix(lambda i, j: 5)
    threshold = (1 << THRESHOLD_WIDTH) + 100  # Invalid 22-bit threshold (overflow)
    return {
        "name": "Invalid_Threshold_Test",
        "pixels": pixels,
        "weights": weights,
        "threshold": threshold
    }

def generate_interrupted_data_test() -> dict:
    pixels = generate_matrix(lambda i, j: 0)
    weights = generate_matrix(lambda i, j: 0)
    # Simulate streaming + pause by filling half the matrix
    for idx in range(32):
        i, j = divmod(idx, MATRIX_SIZE)
        pixels[i][j] = 3
        weights[i][j] = 4
    return {
        "name": "Interrupted_Data_Test",
        "pixels": pixels,
        "weights": weights,
        "threshold": 384  # 3*4*32
    }

def generate_two_cycle_read_test() -> dict:
    pixels = generate_matrix(lambda i, j: 5)
    weights = generate_matrix(lambda i, j: 6)
    return {
        "name": "Two_Cycle_MAC_Read_Test",
        "pixels": pixels,
        "weights": weights,
        "threshold": 0
    }

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

def generate_address_decoding_test() -> dict:
    pixels = generate_matrix(lambda i, j: (i + j) % 256)
    weights = generate_matrix(lambda i, j: (i * j) % 256)
    return {
        "name": "Address_Decoding_Test",
        "pixels": pixels,
        "weights": weights,
        "threshold": 1000
    }

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


# === MAIN GENERATION SCRIPT ===

def generate_all_tests(output_folder: str):
    tests = [
        generate_typical_input_test(),
        generate_random_test(),
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
    tests.extend(generate_walking_1s_tests())
    tests.extend(generate_walking_0s_tests())

    for test in tests:
        export_to_hex(test, output_folder)

# To run and generate the HEX files:
if __name__ == "__main__":
    generate_all_tests("generated_tests")
