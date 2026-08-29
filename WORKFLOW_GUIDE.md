# 🚀 Antigravity ASIC Design Playbook: Natural Language to GDSII

This guide explains how anyone can use **Antigravity** paired with **OpenLane 2 (LibreLane)** and **GitHub Actions** on their own PC to design custom silicon chips from plain English prompts—without installing bulky local EDA tools.

---

## ⚡ The 3-Step Hardware Creation Loop

```mermaid
flowchart LR
    A["💬 1. Prompt Antigravity"] --> B["🧪 2. Quick Local Simulation"]
    B --> C["☁️ 3. Push to GitHub Actions"]
    C --> D["💎 4. Download Silicon GDSII"]
```

1. **Prompt Antigravity**: Describe the circuit behavior, interface ports, and target clock frequency. Antigravity creates synthesizable Verilog RTL, SDC constraints, a self-checking testbench, and the OpenLane configuration.
2. **Local Functional Verification**: Run `python scripts/run_sim.py --design <name>` to verify that all functional assertions pass.
3. **Push to GitHub**: OpenLane 2 container in GitHub Actions runs automated Synthesis, Floorplanning, Placement, Clock Tree Synthesis, Routing, and Signoff to generate the final `.gds` layout file.

---

## 💬 Ready-to-Use Antigravity Prompts

Copy and paste these prompt templates directly into Antigravity to create new chip designs:

### 1. 8-Bit Arithmetic Logic Unit (ALU)
> *"Antigravity, please create a new design `alu8` under `designs/alu8/`. It should support ADD, SUB, AND, OR, XOR, NOT, Left Shift, and Right Shift operations on 8-bit inputs `a` and `b`, controlled by a 4-bit `opcode` with zero and carry flags. Create synthesizable Verilog in `src/alu8.v`, 50 MHz SDC constraints in `src/constraints.sdc`, a self-checking testbench in `tb/tb_alu8.v`, and an OpenLane 2 `config.json` with 35% core utilization."*

### 2. Configurable UART Transmitter & Receiver
> *"Antigravity, please design a complete UART transceiver `uart_core` under `designs/uart_core/` with configurable baud rate generator (default 115200 baud at 50 MHz system clock), 8 data bits, 1 stop bit, no parity, and TX/RX FIFO buffers. Generate the RTL, testbench with loopback testing, SDC constraints, and OpenLane 2 config."*

### 3. SPI Master Controller
> *"Antigravity, create an SPI Master block `spi_master` under `designs/spi_master/` supporting SPI modes 0, 1, 2, and 3 with an 8-bit transmit/receive shift register, slave select output, and busy flag. Include full testbench, SDC timing constraints at 100 MHz, and OpenLane 2 config."*

### 4. Neural Network MAC (Multiply-Accumulate) Unit
> *"Antigravity, design a signed 8-bit Multiply-Accumulate (`mac_unit`) module with 16-bit accumulator, saturation logic, synchronous reset, and valid in/out handshake signals under `designs/mac_unit/`. Provide RTL, self-checking testbench, 100 MHz SDC constraints, and OpenLane 2 configuration."*

---

## 📂 Standard Design File Template

When adding a new design `designs/<design_name>/`, ensure these 4 files are present:

```
designs/<design_name>/
├── config.json          # OpenLane 2 layout parameters
└── src/
    ├── <design_name>.v  # Synthesizable RTL
    └── constraints.sdc  # Timing constraints (SDC)
└── tb/
    └── tb_<design_name>.v # Self-checking testbench
```

### 1. `config.json` (OpenLane 2 Parameters)
```json
{
    "DESIGN_NAME": "<design_name>",
    "VERILOG_FILES": [
        "dir::src/<design_name>.v"
    ],
    "CLOCK_PORT": "clk",
    "CLOCK_PERIOD": 10.0,
    "PNR_SDC_FILE": "dir::src/constraints.sdc",
    "SIGNOFF_SDC_FILE": "dir::src/constraints.sdc",
    "FP_CORE_UTIL": 35,
    "FP_ASPECT_RATIO": 1.0,
    "PL_TARGET_DENSITY_PCT": 55,
    "GRT_ALLOW_CONGESTION": false
}
```

> [!IMPORTANT]
> **Golden P&R Rule of Thumb**:
> Always keep `PL_TARGET_DENSITY_PCT` at least **15–20% higher** than `FP_CORE_UTIL` (e.g. `FP_CORE_UTIL: 35`, `PL_TARGET_DENSITY_PCT: 55`). This prevents placement overflow (`[GPL-0302]`) and allows the global placer adequate room for routing buffer insertion.

### 2. `src/constraints.sdc` (Timing Constraints)
```tcl
set_units -time ns -resistance kOhm -capacitance pF -voltage V -current mA

# 100 MHz Clock (10.0 ns period)
create_clock [get_ports clk] -name core_clk -period 10.0 -waveform {0.0 5.0}

set_clock_uncertainty 0.25 [get_clocks core_clk]
set_clock_transition  0.15 [get_clocks core_clk]

set_input_delay  2.0 -clock core_clk [all_inputs -no_clocks]
set_output_delay 2.0 -clock core_clk [all_outputs]

set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 [all_inputs -no_clocks]
set_load 0.035 [all_outputs]
```

---

## 🧪 Testing Locally

Run the simulation script to test any design before pushing:

```powershell
# Test counter
python scripts/run_sim.py --design counter

# Test your newly created design
python scripts/run_sim.py --design alu8
```

*(If Icarus Verilog is installed via `choco install iverilog` or OSS CAD Suite, it runs the full waveform simulation. If not, it checks syntax and structure).*

---

## ☁️ Hardening to Silicon Layout via GitHub Actions

1. Commit and push:
   ```powershell
   git add .
   git commit -m "feat: add alu8 ASIC design"
   git push origin main
   ```
2. Or trigger a manual build for any specific design via **Run workflow** under the Actions tab in GitHub:
   - Design: `alu8`
   - Target PDK: `sky130A` (or `gf180mcuC`)
3. Download the generated ZIP deliverables:
   - **`layout-artifacts-<design>`**: Contains `<design>.gds` (GDSII tapeout layout), `<design>.def`, and `<design>.lef`.
   - **`signoff-reports-<design>`**: Contains Static Timing Analysis (STA) setup/hold slacks, DRC clean verification, and LVS reports.

---

## 🔍 Inspecting the Layout

1. Download **[KLayout](https://www.klayout.de/)** (free for Windows, macOS, and Linux).
2. Open `<design>.gds` in KLayout.
3. Inspect the transistor gates, power rails (VPWR/VGND), and multi-layer metal routing (`met1` to `met5`).
