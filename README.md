# Filament Evaluation

Evaluation artifact for Filament HDL presented in the paper "Modular Hardware Design with Timeline Types". To clone:

```
git clone https://github.com/cucapra/filament-evaluation.git
cd filament-evaluation
git submodule init
git submodule update
```

## Kick-the-Tires Phase (2-4 hours)

For the kick-the-tires phase we will:
- Install the Filament compiler toolchain
- Install external dependencies that cannot be packaged due to licensing requirements

The second step requires the reviewer to [create a Xilinx account][xilinx-account] in order to download Xilinx's hardware synthesis tools.

### Using the VM

The artifact is available in two formats: A virtual machine image and through code repositories hosted on Github.

**Using the VM**.
The VM is packaged as an OVA file. Our instructions assume you're using [VirtualBox][]. Import the appliance into VirtualBox by double-clicking it or selecting the OVA file when using the [import wizard][appliance-import].

**Login Information**: The username and password are `filament`.
- Minimum host disk space required to install external tools: 65 GB
- Increase number of cores and RAM
  - Select the VM and click "Settings".
  - Select "System" > "Motherboard" and increase the "Base Memory" to 8 GB.
  - Select "System" > "Processor" and select at least 4 cores.

**SSH Configuration**: We've configured the VM to accept SSH connections at port 3022. If you prefer using a command line, connect to the VM by running the following command after starting it up:
```
ssh -p 3022 filament@127.0.0.1
```

### Installing from Source

> **NOTE**: If you're using the VM, skip to the next section.

**Prerequisites**:
- Clone this repository
- Initialize submodules: `git submodule init && git submodule update`
- Install [Rust][rust-install]
- Install [z3][]
- Install [Icarus Verilog][iverilog] (version >= 11.0)
- Ensure your python version is >= 3.9

Run the following command to build and configure tools.
**NOTE**: Make sure you're in the root of this repository before running the command! Otherwise, the installation **will fail** completely and misconfigure the tools:
```
cd <filament-evaluation> && ./scripts/configure-fud.sh
```

The final line should say exactly:
```
interpreter, dahlia, verilog, vcd, synth-verilog, vivado-hls were not installed correctly.
```

If any other tools were reported, then something went wrong during installation.
Run the command `fud check` to see which tool was not installed correctly.

### Sanity Check: Base Installation

If you're using the VM, change directory to the evaluation repository:
```
cd ~/git/filament-evaluation && ./scripts/configure-fud.sh
```

At this point, you should have the Filament compiler fully set up.
Run Filament's test suite by typing the following command:
```
cd filament && runt -j 1 && cd ..
```

This should not report any errors but may say that certain tests were skipped. This is expected.

### Installing External Tools (Estimated time: 2-4 hours)
Our evaluation uses Xilinx's Vivado tool to generate area and resource estimates.
Unfortunately due to licensing restrictions, we can't distribute the VM with these tools installed.
However, the tools are freely available and below are instructions on how to install them.

Our evaluation requires **Vivado WebPACK v.2020.2**.
Due to the [instability of synthesis tools][verismith], we cannot guarantee our evaluation works with a newer or older version of the Vivado tools.

If you're installing the tools on your own machine instead the VM, you can [download the installer][vivado-webpack].

The following instructions assume you're using the VM. These instructions **require** a GUI for the installer to work.
- Log in to the VM with the username `filament` and the password `filament`.
- Open the terminal and run `cd ~/Desktop && ./Xilinx_Unified_2020.2_1118_1232_Lin64.bin`
- If a box pops up asking you for a new version, ignore it and click `Continue`.
- Enter your Xilinx credentials. If you don't have them, [create a Xilinx account][xilinx-account].
  - **Note** When you create an account, you need to fill out all the required information on [your profile][xilinx-profile]. Otherwise the Xilinx installer will reject your login.
  - The "User ID" is the email address of the Xilinx account you created.
- Agree to the contract and press `Next`.
- Choose `Vivado` and click `Next`.
- Choose `Vivado HL WebPACK` and click `Next`.
- Leave the defaults for selecting devices and click `Next`.
- **Important!** Change the install path from `/tools/Xilinx` to `/home/filament/Xilinx`.
- Confirm that you want to create the directory.
- Click Install. Depending on the speed of your connection, the whole process should take about 2-4 hrs.
- To ensure that the tool was installed correctly, do the following:
  - Close the terminal and restart it. This should source the `vivado`'s initialization script: `source /home/filament/Xilinx/Vivado/2020.2/settings64.sh`
  - Run `vivado -help` to make Vivado print out it version information


<details>
<summary><b>Troubleshooting common VM problems</b> [click to expand]</summary>
 - **Running out of disk space while installing Vivado tools**. The Vivado installer will sometimes
 crash or not start if there is not enough disk space. The Virtual Machine is configured to use
 a dynamically sized disk, so to solve this problem, simply clear space on the host machine. You need about 65 GBs of free space.
 - **Running out of memory**. Vivado uses a fair amount of memory. If there is not enough memory available to the VM, they will crash and data won't be generated. If something fails you can increase the RAM and rerun the script that had a failure.
</details>

### Sanity Check: External Tools

We've provided a script that synthesizes a Filament design and reports the final numbers:
```
./script/synth.sh
```

## Step-by-step Instructions

The artifact reproduces the following claims:
1. Latency information generated by Aetherling (Table 1)
2. Incorrect interface for Aetherling modules (Section 7.1, Figure after "Underutilized Designs" paragraph)
3. Resource number for Filament and Aetherling designs

The evaluation uses hardware designs generated by [Aetherling][] and [Reticle][]. The artifact already contains the Verilog generated by the tools.
Verilog files can be regenerated by following the instructions of the artifacts provided for the corresponding papers.

### Table 1: Aetherling Latencies

Table 1 compares the latencies reported by the Aetherling compiler with the latency that works with Filament's timing-accurate test harness.

**TLDR**: Run the following command and note that 4 designs generate incorrect outputs:
```
runt -j 1 -i table-1/
```

The expected output looks like:
```
✗ aetherling latencies:table-1/aetherling/conv2d_48.fil
✗ aetherling latencies:table-1/aetherling/conv2d_144.fil
✗ aetherling latencies:table-1/aetherling/sharpen48.fil
✗ aetherling latencies:table-1/aetherling/sharpen144.fil
```
Run the following command to get a CSV with all the latencies:
```
./scripts/extract-latencies.py table-1/**/*.fil
```
The generated CSV file corresponds to table 1.

> **NOTE**: Table 1 reports that there are *5* incorrect designs, but we discovered that `conv2d_1` works correctly and therefore only *4* designs have incorrect latencies. We've updated the camera-ready version of the paper to reflect this.

**Explanation.**
Our evaluation demonstrates that running Aetherling designs with latency reported by the compiler generates incorrect results.
We do this by providing two harnesses: one that runs the design the Aetherling latency and another one that runs it with Filament's latency that we found through trial and error.
The `table-1` folder contains the experiment data in the following folders:
1. `verilog`: Aetherling generated Verilog modules
2. `data`: Aetherling test harness data for each module
3. `golden`: Expected "golden" output for each test validated using the Aetherling test harness.
4. `filament`: Harnesses to run modules with Filament latencies
5. `aetherling`: Harnesses to run modules with Aetherling latencies.

The above commands runs each module with the corresponding data and the filament and Aetherling harnesses and compares the generated output with the golden output.

*Optional*: To investigate how the inputs differ from expected ones, run the following command.
```
runt -j 1 -d -i table-1/
```

<details>
<summary><b>Regenerating Aetherling Latency Data</b> [click to expand]</summary>

Our harness files hardcode the latencies information.
Generating latency information requires the [Aetherling artifact][aeth-artifact].
Our provided instructions work when using the Aetherling artifact VM:

- Download and configure the Aetherling VM
- Start the VM and switch to the Aetherling compiler's directory: `/home/pldi/pldi/embeddedHaskellAetherling`
- Start the REPL: `stack ghci --test`
- In the command line REPL, run:
```
map compute_latency conv_2d_ppar
map compute_latency sharpen_ppar
```
- The above commands will cause the run the Aetherling compiler on all the `conv_2d` and `sharpen` designs and report the results in the form of a 7-element array which tracks the latencies for designs with the following throughputs: `[16, 8, 4, 2, 1, 1/3, 1/9]`.

</details>

### Mismatched Interface

Section 7.1, Paragraph "Underutilized designs" claims that Aetherling-generated designs violate the interface implied by Aetherling's type system.
We use a test harness similar to one from the previous section to demonstrate that the expected interface is incorrect.

**TLDR**: Run the following command and to note that using Aetherling's interface generated the wrong output:
```
runt -i mismatched-interface -j 1 -v
```

**Explanation.** The resulting output shows that the Aetherling-based harness produces the wrong answer.
Like the previous experiment, we use the same underlying Verilog module and build harnesses corresponding to Aetherling's type and the corrected Filament type (which we found using trial and error).
Hold times for the two harnesses can be extracted by running the command:
```
./scripts/extract-latencies.py mismatched-interface/**/*.fil
```

### Table 2: Quantitative Comparison

Table 2 reports the resource usage of designs generated by Filament to ones generated by Aetherling and Reticle.
This evaluation **requires** Vivado synthesis toolchains to be installed.
As a sanity check, run `fud check` and ensure that the `synth-verilog` stage is correctly installed and the `vivado` binary is available.

**TLDR**: Run the following command to generate synthesis results for each design mentioned in table 2:
```
rm -f table-2.csv && ./scripts/synth.sh
```
The generated file `table-2.csv` corresponds to the data presented in Table 2.

**Explanation.** The `table-2` folder contains several implementations of the `conv2d` kernel: Aetherling-generated, pure Filament implementation, and Filament implementation that uses Reticle-generated dot product. The directory structure is:
- `chisel-conv-16`: Verilog generated from Aetherling
- `filament-base`: Code common to Filament implementations
- `filament`: Pure Filament implementation
- `filament-reticle`: Filament implementation that uses Reticle-based dot product.

Each folder, except `filament-base` contains a `device.xdc` which defines the target period for the design and `synth.tcl` which configures the Vivado synthesis toolchain.

Our script uses `fud` to orchestrate the execution.
For Filament files, `fud` compiles them to Verilog and runs the synthesis toolchain while for the Aetherling benchmark, it just runs the synthesis toolchain directly.

[virtualbox]: https://www.virtualbox.org/
[aeth-artifact]: https://dl.acm.org/do/10.1145/3395633/full/
[xilinx-account]: https://login.xilinx.com
[rust-install]: https://www.rust-lang.org/tools/install
[z3]: https://github.com/Z3Prover/z3
[iverilog]: https://iverilog.fandom.com/wiki/Installation_Guide
[vivado-webpack]: https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/archive.html
[xilinx-account]: https://www.xilinx.com/registration/create-account.html
[xilinx-profile]: https://www.xilinx.com/myprofile/edit-profile.html
[verismith]: https://yannherklotz.com/docs/fpga2020/verismith_paper.pdf
[appliance-import]: https://docs.oracle.com/en/virtualization/virtualbox/6.0/user/ovf.html
[reticle]: https://dl.acm.org/doi/abs/10.1145/3453483.3454075
[aetherling]: https://aetherling.org/