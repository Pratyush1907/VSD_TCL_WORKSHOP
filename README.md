# VSD_TCL_WORKSHOP
# TCL Scripting for VSD Synthesis Flow

## Overview

This repository documents my  TCL Scripting for VLSI System Design (VSD) learning journey. During this workshop, I learned how TCL scripting can be used to automate synthesis flows, process CSV constraint files, generate SDC constraints, perform hierarchy checking, handle errors, and automate Yosys-based RTL synthesis.

The project culminates in building a TCL-based synthesis framework (**vsdsynth**) that:

* Reads RTL netlists and design constraints.
* Validates design files and directories.
* Converts CSV constraints into SDC format.
* Generates Yosys synthesis scripts automatically.
* Performs hierarchy checking and error handling.
* Produces synthesized gate-level netlists and reports.

*Source: TCL SCRIPTING VSD workshop notes* 

---

# Day 1 – Introduction to TCL-Based Synthesis Flow

## Objectives

* Understanding the VSD synthesis framework.
* Running executable shell scripts.
* Understanding the overall synthesis flow.

## Topics Covered

### Making Scripts Executable

```bash
chmod +x vsdsynth
```

This command grants execution permission to the script.

### Running the Script

```bash
./vsdsynth
```

The script launches the TCL-based synthesis environment.

### Understanding the Tool Flow

The synthesis tool:

1. Accepts RTL netlists and SDC constraints.
2. Uses Yosys as the synthesis engine.
3. Generates:

   * Synthesized netlists
   * Timing reports
   * Output directories

### Error Handling for Missing Input Files

The script checks whether the required CSV file exists before continuing execution.

## Key Learnings

* Linux execution permissions.
* Shell script invocation.
* Introduction to automation of synthesis flows.
* Importance of validating user inputs.

## Screenshots

<img width="1093" height="456" alt="image" src="https://github.com/user-attachments/assets/9257908c-ab96-48cc-b103-0d6eebd159fd" />
<img width="1093" height="516" alt="image" src="https://github.com/user-attachments/assets/0da63f09-bfb9-41b2-8bda-0e075076a8b7" />
<img width="1093" height="500" alt="image" src="https://github.com/user-attachments/assets/5c48d637-93e2-449f-ada1-c31a41473cfc" />
<img width="1014" height="513" alt="image" src="https://github.com/user-attachments/assets/b696728d-16d3-4a2a-977f-3d703ba59440" />
<img width="1093" height="491" alt="image" src="https://github.com/user-attachments/assets/5fb8f8bc-ebaf-456d-abc1-0b3a2512ca84" />



---

# Day 2 – Working with TCL Variables, Arrays and CSV Parsing

## Objectives

* Understanding TCL variables.
* Reading command-line arguments.
* Parsing CSV files.
* Creating matrices and arrays.

## Topics Covered

### Command Line Arguments

```tcl
set filename [lindex $argv 0]
```

TCL stores command-line arguments in `$argv`.

| Index   | Meaning     |
| ------- | ----------- |
| argv[0] | First file  |
| argv[1] | Second file |
| argv[2] | Third file  |

### Reading CSV Files

```tcl
package require csv
package require struct::matrix

struct::matrix m

set f [open $filename]
csv::read2matrix $f m auto
close $f
```

This loads CSV data into a matrix structure.

### Converting Matrix to Array

```tcl
m link my_arr
```

Allows matrix data to be accessed like an array.

### String Manipulation

#### Removing Spaces

```tcl
string map {" " ""} $value
```

#### Replacing Strings

```tcl
string map {_ghosh _vsd} kunal_ghosh
```

Output:

```text
kunal_vsd
```

### Creating Variables Dynamically

```tcl
set DesignName $my_arr(1,0)
```

Now:

```tcl
puts $DesignName
```

returns:

```text
openMSP430
```

### File and Directory Validation

The script verifies:

* Output directory
* RTL netlist directory
* Library files
* Constraint files

before synthesis begins.

## Key Learnings

* TCL variable declaration.
* Matrix and array operations.
* CSV parsing techniques.
* Dynamic variable creation.
* Path validation.

## Screenshots

<img width="1093" height="497" alt="image" src="https://github.com/user-attachments/assets/7c3bb53d-4d02-4180-b685-d0362cef1a80" />
<img width="1093" height="564" alt="image" src="https://github.com/user-attachments/assets/6a4e545e-5a68-4e20-9f12-e02daa5fad9e" />
<img width="1070" height="56" alt="image" src="https://github.com/user-attachments/assets/067c734c-2856-48ba-989f-3a3e57f63fef" />
<img width="1093" height="190" alt="image" src="https://github.com/user-attachments/assets/667bff1a-7765-4d77-9629-f5d2c991324e" />
<img width="1093" height="330" alt="image" src="https://github.com/user-attachments/assets/5b954e43-fade-43ec-ad61-e4d49040e789" />
<img width="866" height="338" alt="image" src="https://github.com/user-attachments/assets/6a04f409-4bcc-4af8-8c6c-244c85e6ea10" />


---

# Day 3 – Constraint Processing and SDC Generation

## Objectives

* Converting CSV constraints into SDC.
* Understanding matrix search operations.
* Generating timing constraints automatically.

## Topics Covered

### Creating Constraint Matrix

```tcl
struct::matrix constraints

set chan [open $ConstraintsFile]
csv::read2matrix $chan constraints auto
close $chan
```

### Locating Constraint Parameters

Example:

```tcl
constraints search rect 0 0 10 3 early_rise_delay
```

Searches the specified matrix region and returns the location of:

```text
early_rise_delay
```

### Reading Cell Values

```tcl
constraints get cell $clock_early_rise_delay_start $i
```

Used to extract timing parameters from CSV.

### Generating SDC Constraints

Example generated output:

```tcl
set_clock_latency -source -early -rise 150 [get_clocks dco_clk]

set_clock_latency -source -late -fall 153 [get_clocks dco_clk]
```

### Clock Creation

```tcl
create_clock \
-name dco_clk \
-period 1500 \
-waveform {0 750} \
[get_ports dco_clk]
```

### Duty Cycle Calculation

For:

```text
Period = 1500ps
Duty Cycle = 50%
```

Waveform becomes:

```text
{0 750}
```

### Processing Input Ports

The script automatically detects:

* Scalar inputs
* Bus inputs

Example:

```verilog
input [6:0] dbg_i2c_addr;
```

Converted to:

```tcl
dbg_i2c_addr*
```

for wildcard matching.

### Verilog Parsing

Using:

```tcl
glob -dir $NetlistDirectory *.v
```

The script:

* Finds all Verilog files.
* Reads line-by-line.
* Extracts input declarations.
* Generates SDC constraints.

### Cleaning Strings

```tcl
regsub -all {\s+} $s1 ""
```

Removes all whitespace characters.

## Key Learnings

* Constraint matrix searching.
* Automatic SDC generation.
* Clock modeling.
* Bus handling.
* Verilog parsing using TCL.

## Screenshots

<img width="1093" height="771" alt="image" src="https://github.com/user-attachments/assets/e3565306-3847-4f22-8f73-c0f9283760f9" />
<img width="1093" height="857" alt="image" src="https://github.com/user-attachments/assets/df935c00-64e4-4dc8-a5f6-f9aa48fa964e" />

---

# Day 4 – RTL Synthesis Using Yosys

## Objectives

* Synthesizing Verilog designs.
* Generating gate-level netlists.
* Understanding logic optimization.

## Topics Covered

### Example Design

```verilog
module memory(
    CLK,
    ADDR,
    DIN,
    DOUT
);
```

### Yosys Synthesis Script

```yosys
read_liberty osu018_stdcells.lib

read_verilog memory.v

synth -top memory

dfflibmap -liberty osu018_stdcells.lib

abc -liberty osu018_stdcells.lib

flatten

clean

write_verilog memory_synth.v
```

### Running Yosys

```bash
yosys memory.ys
```

### Generated Output

The RTL design is transformed into:

* NAND gates
* NOR gates
* AOI gates
* OAI gates
* Flip-flops

### Logic Optimization

Yosys performs:

* Constant propagation
* Dead code removal
* Logic simplification
* Technology mapping

## Key Learnings

* RTL synthesis flow.
* Standard cell mapping.
* Gate-level netlist generation.
* Optimization passes in Yosys.

## Screenshots

<img width="895" height="644" alt="image" src="https://github.com/user-attachments/assets/3dd472fa-f5cd-4d04-9324-a49cc6476185" />
<img width="1093" height="478" alt="image" src="https://github.com/user-attachments/assets/0f1a7837-364a-47dc-97a8-79ef542070d2" />
<img width="1006" height="1170" alt="image" src="https://github.com/user-attachments/assets/8797b328-1f96-48b1-b8a4-2b9f5e00aebe" />
<img width="1093" height="509" alt="image" src="https://github.com/user-attachments/assets/baaa597f-1752-4a8a-a4b8-c5f3f12cafd2" />
<img width="1080" height="1147" alt="image" src="https://github.com/user-attachments/assets/6798d1e8-03e7-4a55-8f9e-8595f4775482" />
<img width="1093" height="479" alt="image" src="https://github.com/user-attachments/assets/5d166eae-8753-4f2a-82c2-998c73a1e2e6" />
<img width="974" height="606" alt="image" src="https://github.com/user-attachments/assets/1f5fbdae-66c2-4b98-b717-c57bbc9dbd4b" />
<img width="1093" height="590" alt="image" src="https://github.com/user-attachments/assets/a444dce8-933f-45fd-bce4-9f07d5eff74c" />
<img width="1006" height="202" alt="image" src="https://github.com/user-attachments/assets/e2a904df-ddbe-451e-8db2-4496683d39a0" />
<img width="1093" height="173" alt="image" src="https://github.com/user-attachments/assets/4915b6ac-0060-4387-a1c5-ce7620b52883" />
<img width="1093" height="221" alt="image" src="https://github.com/user-attachments/assets/21c0b6d9-e946-4da4-a253-d383a7aec429" />
<img width="1093" height="44" alt="image" src="https://github.com/user-attachments/assets/8644e3a3-28da-4406-9cd3-f081c327cd36" />


# Day 5 – Hierarchy Checking and Error Handling

## Objectives

* Detecting missing modules.
* Performing hierarchy verification.
* Improving synthesis robustness.

## Topics Covered

### Why Hierarchy Checking?

Consider:

```verilog
module top();

alu u1();

memory u2();

endmodule
```

Before synthesis, Yosys must verify:

* Does `alu` exist?
* Does `memory` exist?
* Are all modules available?
* Is hierarchy complete?

### Error Handling

Without error handling:

* Scripts may crash.
* Logs become difficult to debug.
* Partial outputs may be generated.

### Running Shell Commands from TCL

```tcl
exec yosys $OutputDirectory/$DesignName.hier.ys
```

### Redirecting Logs

```tcl
>&
```

Used to redirect output into log files.

### Hierarchy Status

#### PASS

```text
err flag = 0
```

All modules found successfully.

#### FAIL

```text
err flag = 1
```

Missing module detected.

### Advantages

* Faster debugging.
* Early failure detection.
* Cleaner synthesis flow.
* Improved automation.

## Key Learnings

* Hierarchy validation.
* Error handling in TCL.
* TCL `exec` command.
* Log generation and parsing.
* Building reliable synthesis scripts.

## Screenshots

<img width="1093" height="311" alt="image" src="https://github.com/user-attachments/assets/10a6b8cf-6a28-42b5-85d5-a7b76c639f99" />
<img width="1093" height="653" alt="image" src="https://github.com/user-attachments/assets/54d71dbb-df98-4572-b6d3-1d7b576102ce" />
<img width="1093" height="378" alt="image" src="https://github.com/user-attachments/assets/152af1be-da44-492d-9224-f12b6a68dae6" />
<img width="874" height="120" alt="image" src="https://github.com/user-attachments/assets/97f1f04f-8e2d-4903-a281-ecba9d769d62" />
<img width="831" height="358" alt="image" src="https://github.com/user-attachments/assets/e2716d56-243c-4957-b581-c0ba042654ca" />
<img width="1093" height="319" alt="image" src="https://github.com/user-attachments/assets/615d55b1-dd6a-49da-922d-fba1c251fb08" />
<img width="1093" height="204" alt="image" src="https://github.com/user-attachments/assets/59ea3564-b551-4eb4-b3d4-817673a368ba" />
<img width="919" height="311" alt="image" src="https://github.com/user-attachments/assets/37868b12-7763-414c-b2f1-ab0de9a22500" />
<img width="1093" height="133" alt="image" src="https://github.com/user-attachments/assets/53a22e4a-0c92-49db-8640-1f1dc12eb744" />
<img width="949" height="1117" alt="image" src="https://github.com/user-attachments/assets/c1c5910f-3455-40da-9812-48dee1be63c8" />
<img width="1093" height="389" alt="image" src="https://github.com/user-attachments/assets/9a0eaa68-5ab6-45ee-8e0f-b631b3e92deb" />

# Conclusion

Over these five days, I developed a strong understanding of **TCL scripting for EDA automation**, including:

 TCL fundamentals and scripting
 CSV parsing and matrix handling
 Automatic SDC generation
 Verilog netlist parsing
 Yosys synthesis automation
 Gate-level netlist generation
 Hierarchy verification and error handling

This project demonstrates how TCL can be used to build a complete automation flow for RTL synthesis and timing constraint generation in VLSI design environments.



## Acknowledgements

* VLSI System Design (VSD)
* Yosys Open Source Synthesis Suite
* TCL/Tk Community
* OpenMSP430 Design Example








set runtime  [expr {($end_time - $start_time) / 1.0}]
puts "Runtime: $runtime sec"
```
---
5.7 Final Report Format
```
*****************************************************
*        TCL Workshop — Timing Summary Report       *
*****************************************************

Design Name    : openMSP430
Runtime        : 143 sec

------------- Setup Timing --------------------------
WNS (setup)    : -0.32 ns
FEP (setup)    : 14

------------- Hold Timing ---------------------------
WNS (hold)     : -0.08 ns
FEP (hold)     : 3

------------- Area ----------------------------------
Instance Count : 2847
(More instances = larger area)

*****************************************************
```
> This is one of the commonly used formats for STA reports.
---
📸 Screenshots — Day 5
> *Screenshot 1: Netlist before/after cleanup — Yosys output with `/` characters removed*
> *Screenshot 2: `openMSP430.conf` — all `read_*` commands and `report_timing`*
> *Screenshot 3: `openMSP430.spef` — first few lines of the parasitic file*
> *Screenshot 4: `procs.tcl` — `read_lib` and `read_sdc` procedure definitions with switch handling*
> *Screenshot 5: Final terminal output showing the formatted timing summary report*
---
🛠️ Tools & Technologies
Tool / Technology	Role
Bash / Shell	Entry point, environment setup, argument validation
TCL (Tool Command Language)	Core automation scripting
Yosys	Open-source RTL synthesis framework
OpenTimer	Open-source Static Timing Analysis (STA) tool
SDC format	Synopsys Design Constraints — timing definition
SPEF format	Standard Parasitic Exchange Format — RC parasitics
struct::matrix	TCL package for 2D matrix data structures
csv	TCL package for CSV file parsing
---
💡 Key Learnings
`chmod +x` + `./` — the entry point to any Linux script automation flow
`lindex $argv 0` — the standard way to receive file paths from shell into TCL
`struct::matrix` + `csv::read2matrix` — clean pattern for reading design data from CSVs
`string map` — essential for sanitizing names before using them as variable identifiers
`constraints search rect` — powerful for locating section boundaries in a constraint matrix
`\[` and `\]` — must escape TCL's special `[]` when writing SDC/conf output files
`file normalize` — always use for error messages so users see the full expected path
`exec ... >& logfile` — the standard TCL pattern for running EDA tools and capturing all output
`proc` — write once, call many times; essential for scalable automation scripts
WNS is found from RAT — grep keyword in timing results, pick the most negative value
FEP = count of RAT entries — total failing endpoints is simply the total number of RAT lines
Instance count ∝ area — more standard cell instances in the netlist = larger chip area
---
<div align="center">
Workshop by VSD — VLSI System Design
</div>

