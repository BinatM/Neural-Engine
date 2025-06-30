## 1 Prerequisites

| Tool / Item            | Minimum version              | Notes                                         |
| ---------------------- | ---------------------------- | --------------------------------------------- |
| Quartus Prime Lite     | 18.0 (or newer; 23.1 tested) | Install the USB‑Blaster driver on Windows.    |
| Python                 | 3.8 +                        | Only needed when generating custom test sets. |
| ModelSim‑Intel Starter | Same as Quartus              | Optional – RTL simulation.                    |
| DE10‑Lite board        | MAX 10 10M50DAF484C7G        | Includes on‑board USB‑Blaster.                |

---

## 2 Folder layout (checked‑out **FPGA** branch)

````
Neural-Engine/FPGA ├─ project\_files/          # Quartus project (.qpf / .qsf / constraints)
                 ├─ test_environment           # RTL wrapper + `test_package.sv`
                 |   └─randomized delay files  # generator + validator spacial testing *.sv files 
                 ├─ testgen/
                 │   └─ python_scripts         # Vector generators (Python)
                 ├─ generated_tests            # Ready‑made *.sv include files
                 ├─ testbenches                # ModelSim simulations (optional)
                 └─ docs/ *.docx / *.zip       # Architecture & test documents
````

---

## 3 Step‑by‑step workflow

### 3.1 Clone the repo

```bash
git clone https://github.com/BinatM/Neural-Engine.git
cd Neural-Engine
git switch FPGA   # or: git checkout FPGA
````

### 3.2 Creating a Quartus Project (if it doesn't exist)

If the Quartus project is missing from the repository or you want to start from scratch:

1. **Open Quartus Prime Lite**.
2. Go to **File → New Project Wizard** and follow the steps:
   - **Project Name & Directory**: Use `Neural-Engine/FPGA/project_files/` as the location.
   - **Top-Level Design Entity**: Enter `top_level` (or your actual top-level module name).
3. **Add Files**: Add all relevant SystemVerilog files from `test_environment/` and any additional RTL modules.
4. **Family & Device Settings**:
   - Family: `MAX 10`
   - Device: `10M50DAF484C7G`
5. **EDA Tool Settings**: Leave default or set ModelSim for simulation support (optional).
6. Complete the wizard.

Once created:
- Make sure the constraints file (`.sdc`) is included.
- Assign pin locations according to the DE10-Lite board, use (`.qsf`) file.
- Set `top_level` as the top module if not already done under **Assignments → Settings → General**.

### 3.3 Choose or generate test vectors

You can use one of the scripts below to create test sets in `testgen/python_scripts/`. Each script saves its `.sv` file in the same folder.

| Script                        | Test count | When to use                                                        |
| ----------------------------- | ---------- | ------------------------------------------------------------------ |
| `generate_five_sv_files.py`   | 500 × 5    | Edge cases with large numbers, randomized large values, thresholds |
| `generate_unique_sv_files.py` | 500 × 10   | Ensures all test cases are unique (no duplicates)                  |
| `generate_small_sv_files.py`  | 500 × 5    | Small-value test patterns and randomized thresholds                |

After generating a file, move it to `test_environment/` and add rename the file to "on_chip_memory.sv" and replace it with the file in your `test_environment/

### 3.4 Compile in Quartus (GUI)

1. Start **Quartus Prime Lite**.
2. *File → Open Project…* → select `<project_name>.qpf` in `project_files/`.
3. Press **Ctrl + L** (Build → Compile) to run Analysis & Synthesis **and** Fitter in one go.\
   ▹ Wait until every task shows a green check‑mark and **no red errors**.
4. The bit‑stream is written as `output_files/<project_name>.sof`.

### 3.5 Program the board

1. Connect the DE10‑Lite (USB‑Blaster) and power it on.
2. **Tools → Programmer** → *Hardware Setup…* → pick **USB‑Blaster**.
3. *Add File…* → choose `output_files/<project_name>.sof`.
4. Tick *Program/Configure* → **Start**.\
   ▹ Wait until the progress bar reaches **100 %**.

### 3.6 Run the test suite

| Action                  | Board element         | Effect                                                   |
| ----------------------- | --------------------- | -------------------------------------------------------- |
| Start / reset           | **KEY0** (active‑low) | Clears RAM and begins test 0                             |
| Continue after  2 fails | **KEY1** (active‑low) | Resumes vector stream                                    |
| Failing indices         | 7‑seg HEX 5‑0         | Shows first & second failing tests (three‑digit decimal) |

**Result guide**

- **Blank display** – all tests pass.
- **Two three‑digit numbers** – first/second failing indices in on‑chip order.
- **Scrolling numbers** – > 2 fails → note the numbers, press **KEY1** to continue.

---

## 4 Troubleshooting

| Symptom                                | Possible cause / quick fix                                          |
| -------------------------------------- | ------------------------------------------------------------------- |
| Quartus Programmer shows “No hardware” | Re‑install USB‑Blaster driver; reconnect USB.                       |
|                                        |                                                                     |
| Failed to compile                      | Test may use too many memory registers; reduce the number of tests. |

---

## 5 Contact

Questions?  contact:   

Yuval Desalto
*yuval.desalto@gmail.com

Ariel Richter
*arielrichter1@gmail.com
