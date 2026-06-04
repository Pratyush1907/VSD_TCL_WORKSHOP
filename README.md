# VSD_TCL_WORKSHOP
# TCL Scripting for VSD Synthesis Flow

## Overview

This repository documents my **5-day TCL Scripting for VLSI System Design (VSD)** learning journey. During this workshop, I learned how TCL scripting can be used to automate synthesis flows, process CSV constraint files, generate SDC constraints, perform hierarchy checking, handle errors, and automate Yosys-based RTL synthesis.

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

### Tool Initialization

![Day1-Tool Initialization](images/day1_tool_initialization.png)

### Missing CSV File Detection

![Day1-CSV Error](images/day1_csv_error.png)

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

### CSV File Parsing

![Day2-CSV Parsing](images/day2_csv_parsing.png)

### Matrix Creation and Array Linking

![Day2-Matrix](images/day2_matrix_creation.png)

### Directory Validation

![Day2-Directory Check](images/day2_directory_validation.png)

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

### Constraint Matrix Search

![Day3-Constraint Search](images/day3_constraint_search.png)

### Generated SDC Constraints

![Day3-SDC](images/day3_sdc_generation.png)

### Processing Input Ports

![Day3-Input Constraints](images/day3_input_constraints.png)

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

### Memory Module

![Day4-Memory Module](images/day4_memory_module.png)

### Yosys Script

![Day4-Yosys Script](images/day4_yosys_script.png)

### Synthesis Log

![Day4-Synthesis Log](images/day4_synthesis_log.png)

### Gate-Level Netlist

![Day4-Gate-Level Netlist](images/day4_gate_level_netlist.png)

---

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

### Hierarchy Check Concept

![Day5-Hierarchy Check](images/day5_hierarchy_check.png)

### Error Flag Detection

![Day5-Error Handling](images/day5_error_handling.png)

### Successful Hierarchy Verification

![Day5-Hierarchy Pass](images/day5_hierarchy_pass.png)

---

# Conclusion

Over these five days, I developed a strong understanding of **TCL scripting for EDA automation**, including:

✅ TCL fundamentals and scripting
✅ CSV parsing and matrix handling
✅ Automatic SDC generation
✅ Verilog netlist parsing
✅ Yosys synthesis automation
✅ Gate-level netlist generation
✅ Hierarchy verification and error handling

This project demonstrates how TCL can be used to build a complete automation flow for RTL synthesis and timing constraint generation in VLSI design environments.

---

## Acknowledgements

* VLSI System Design (VSD)
* Yosys Open Source Synthesis Suite
* TCL/Tk Community
* OpenMSP430 Design Example

*Based on notes and exercises completed during the TCL Scripting VSD workshop.* 







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

