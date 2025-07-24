# 🧠 SPEAR: Single Neuron Hardware Accelerator Engine (CHIP Branch)

Welcome to the `main.rtl_block_design` branch of the SPEAR project - an undergraduate VLSI design initiative carried out at Tel Aviv University.

> 🏆 **1st Place Winner** - Faculty of Engineering Final Projects Competition, Tel Aviv University

This repository documents the complete RTL-to-GDSII flow of a custom ASIC designed to accelerate the computation of a single perceptron neuron, implemented using TSMC 28nm technology.

---

## 🔍 Overview

This branch contains the full RTL-to-GDSII flow of a perceptron-like neuron implemented as a standalone ASIC.  
The chip performs binary classification over 64-pixel grayscale vectors using multiply–accumulate (MAC), thresholding, and activation.

💡 **What is a perceptron?**  
A perceptron is the fundamental building block of neural networks. It performs a weighted sum of its inputs and applies an activation function (typically a step or sigmoid).  
Our chip accelerates a **single binary neuron** with 64 bit inputs and a 1-bit output:

<img width="856" height="359" alt="image" src="https://github.com/user-attachments/assets/5a96910a-fb1d-4aaf-9e11-f584621e9ce4" />

---

## 🧱 Block Diagram

Below is the top-level architecture of the design:  
- Central units: MAC, Input & Weight Memories, Activation Function, Output Register  
- I/O Interface via shared 16-bit Bus  
- Controlled by a dedicated FSM unit

<img width="712" height="549" alt="image" src="https://github.com/user-attachments/assets/36cbbd8f-722c-4149-bbdf-9cce69ca092f" />


---

## 📁 Repository Structure

The branch includes all physical design components for the chip:

```
CHIP/
├── rtl/                    # All RTL modules (SystemVerilog)
├── synthesis/              # Physical design scripts (Tcl for Fusion Compiler)
├── verification/           # Testbenches and simulation files
├── reports_no_sram/        # Timing, area, power, congestion reports for final signoff
└── neuron_top_no_sram.dlib # Design Library with all saved blocks (final block: top_final_signoff)
```

---

## 🔧 Tools & Flow

- **Technology**: TSMC 28nm
- **Toolchain**: Euclide, SystemVerilog, ModelSim/QuestaSim, Synopsys Fusion Compiler, Calibre
- **Design Flow**:
  1. Architecture design and planning
  2. RTL implementation (SystemVerilog)
  3. Functional verification (custom testbench developed in SystemVerilog, run in parallel to design)
  4. Logic synthesis and STA
  5. Floorplanning with aspect ratio and core definition
  6. Power Planning — including PG rings and straps
  7. Placement and legalization
  8. Clock Tree Synthesis (CTS)
  9. Routing and congestion analysis
  10. DRC & LVS checks (using integrated tools in Fusion Compiler)
  11. Timing and PPA signoff
- **Automation**: 
  - Full Physical Design (PD) scripted end-to-end using Tcl (from synthesis to signoff)
  - Automated regression testing for verification flows

---

## 📊 Design Summary - Core

| Metric                  | Value                  |
|-------------------------|------------------------|
| Target Frequency        | 1 GHz                  |
| Total Latency           | 71 clock cycles        | 
| Worst Slack             | +0.19 ns               |
| Core Area               | ~0.0043 mm²            |
| Total Dynamic Power     | 4.91 mW                |
| Leakage Power           | 2.75 µW                |
| Core Utilization        | 70.2%                  |
| DRC & Hold Violations   | 0 (clean signoff)      |

The following diagram presents the final layout of the synthesized and routed core, after full signoff:

<img width="481" height="433" alt="Screenshot 2025-07-24 at 9 57 53" src="https://github.com/user-attachments/assets/48f62bb9-2609-412b-b45d-2956854886ee" />

And the same diagream witout routing: 

<img width="448" height="433" alt="Screenshot 2025-07-24 at 9 57 36" src="https://github.com/user-attachments/assets/331f5b35-05d4-47ee-9875-4eabbb5a77b1" />

---

## ⏱ Timing Diagram

The following timing diagram illustrates the behavior of all key modules over a single compute cycle-
from input loading, through MAC operation, activation, and output readiness:

<img width="865" height="294" alt="image" src="https://github.com/user-attachments/assets/c4cb3c26-198e-4c26-9605-b53cc528dc9c" />

This trace shows the system performing inference in exactly **71 clock cycles**,  
validating the correct orchestration of the MAC, memories, control FSM, and output interface.

---

## 🤝 FPGA Co-Development

A parallel team developed a post-silicon validation platform on the DE10-Lite board.  
See [`FPGA` branch](https://github.com/BinatM/Neural-Engine/tree/FPGA) for RTL wrapper, test vector generation, and on-board integration.

---

## 📄 Additional Documentation

- Project Poster
- Project Book
- Architectural Document

---

## 👥 Authors

- Binat Makhlin : makhlin.binat@gmail.com
- Jonathan Peled : jonathanp61@gmail.com
- Advisor: Yaakov Milstain
