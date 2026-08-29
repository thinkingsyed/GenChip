"""Local simulation runner for ASIC designs."""

import argparse
import os
import shutil
import subprocess
import sys


def run_simulation(design_name: str):
    base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    design_dir = os.path.join(base_dir, "designs", design_name)
    src_file = os.path.join(design_dir, "src", f"{design_name}.v")
    tb_file = os.path.join(design_dir, "tb", f"tb_{design_name}.v")

    if not os.path.exists(src_file):
        print(f"[ERROR] Source file not found: {src_file}")
        sys.exit(1)
    if not os.path.exists(tb_file):
        print(f"[ERROR] Testbench file not found: {tb_file}")
        sys.exit(1)

    iverilog = shutil.which("iverilog")
    vvp = shutil.which("vvp")

    if not iverilog or not vvp:
        print("[INFO] Icarus Verilog ('iverilog' / 'vvp') is not in your system PATH.")
        print("[INFO] To run local simulations, install Icarus Verilog via OSS CAD Suite or Chocolatey (`choco install iverilog`).")
        print("[INFO] Verification of files: Both RTL source and testbench exist and are ready for CI/CD!")
        return

    sim_out = os.path.join(design_dir, f"{design_name}_sim.vvp")
    print(f"[SIM] Compiling {design_name} with Icarus Verilog...")
    compile_cmd = [iverilog, "-o", sim_out, "-s", f"tb_{design_name}", src_file, tb_file]
    res = subprocess.run(compile_cmd)
    if res.returncode != 0:
        print("[ERROR] Compilation failed.")
        sys.exit(res.returncode)

    print(f"[SIM] Running simulation with vvp...")
    sim_cmd = [vvp, sim_out]
    res_sim = subprocess.run(sim_cmd, cwd=design_dir)
    if res_sim.returncode != 0:
        print("[ERROR] Simulation run failed.")
        sys.exit(res_sim.returncode)

    print("[SIM] Simulation completed successfully!")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run local Verilog simulation.")
    parser.add_argument("--design", default="counter", help="Name of design to simulate (default: counter)")
    args = parser.parse_args()
    run_simulation(args.design)
