import os
import zipfile

# Extract test names from the ZIP file by finding all *_inputs.hex files
def extract_test_names_from_zip(zip_path: str) -> list:
    test_names = []
    with zipfile.ZipFile(zip_path, 'r') as zipf:
        for name in zipf.namelist():
            if name.endswith("_inputs.bin"):
                base = os.path.basename(name)
                test_name = base.replace("_inputs.bin", "")
                test_names.append(test_name)
    return test_names

def validate_results_with_detail(result_file_path: str, test_names: list):
    failed_tests = []

    # Read result lines from file (binary strings like '0000000000000001')
    with open(result_file_path, 'r') as f:
        lines = [line.strip() for line in f if line.strip()]

    if len(lines) != len(test_names):
        print(f"[!] Mismatch: {len(lines)} result lines vs {len(test_names)} test names")
        return

    print("=== Test Result Validation ===")
    for i, (line, name) in enumerate(zip(lines, test_names)):
        if len(line) != 16 or any(c not in '01' for c in line):
            print(f"[!] Invalid binary at line {i+1}: '{line}'")
            failed_tests.append((name, "Invalid binary"))
            continue

        # Extract least significant bit (pass/fail result)
        result_bit = int(line[-1])

        if result_bit == 1:
            print(f"[✓] {name} passed")
        else:
            print(f"[✗] {name} failed")
            failed_tests.append((name, "Output mismatch"))

    # Summary report
    print("\n=== Validation Summary ===")
    print(f"Total tests   : {len(test_names)}")
    print(f"Passed tests  : {len(test_names) - len(failed_tests)}")
    print(f"Failed tests  : {len(failed_tests)}")

    # Save failed tests to file
    if failed_tests:
        with open("failed_tests.txt", "w") as f:
            for name, reason in failed_tests:
                f.write(f"{name}: {reason}\n")
        print("\n Some tests failed — see 'failed_tests.txt' for details.")
    else:
        print("\n All tests passed — system is valid.")


# Main entry point
if __name__ == "__main__":
    zip_path = "all_tests_bin.zip"                          # ZIP in project root
    result_path = "generated_tests/validation_results"      # Results file in subfolder

    # Step 1: Get test names from ZIP
    test_names = extract_test_names_from_zip(zip_path)

    # Step 2: Validate results
    validate_results_with_detail(result_path, test_names)
