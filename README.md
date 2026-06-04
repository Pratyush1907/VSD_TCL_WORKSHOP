# VSD_TCL_WORKSHOP
🛠️ TCL Scripting Workshop — VSD VLSI System Design
<div align="center">
![TCL](https://img.shields.io/badge/Language-TCL%2FTk-blue?style=for-the-badge&logo=tcl&logoColor=white)
![Yosys](https://img.shields.io/badge/Tool-Yosys-orange?style=for-the-badge)
![OpenTimer](https://img.shields.io/badge/STA-OpenTimer-green?style=for-the-badge)
![Shell](https://img.shields.io/badge/Shell-Bash-black?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Status](https://img.shields.io/badge/Workshop-Completed-brightgreen?style=for-the-badge)
A 5-Day Hands-On Workshop on TCL Scripting for VLSI EDA Automation
Covering CSV parsing → SDC generation → Yosys synthesis → OpenTimer STA → Report generation
</div>
---
📋 Table of Contents
Overview
Flow Diagram
Day 1 — Shell Scripting & TCL Setup
Day 2 — CSV Parsing & Matrix Operations
Day 3 — SDC Constraint Generation
Day 4 — Yosys Synthesis & Hierarchy Checking
Day 5 — OpenTimer STA & Report Generation
Tools & Technologies
Key Learnings
---
🔍 Overview
This repository documents the 5-Day TCL Scripting Workshop by VSD (VLSI System Design). The workshop builds a complete, automated EDA flow from scratch — taking a design CSV as input and producing timing analysis reports as output, entirely driven by TCL scripts.
Day	Theme	Core Topics
Day 1	Shell & TCL Basics	`chmod`, file execution, shell→TCL bridge
Day 2	CSV Parsing & Matrices	`argv`, `struct::matrix`, string operations
Day 3	SDC Generation	Clock/IO constraints, bus detection, Verilog parsing
Day 4	Yosys & Hierarchy Check	Gate-level synthesis, error handling, `exec`
Day 5	STA & Report Generation	OpenTimer, `proc`, WNS, FEP, instance count
---
🔄 Flow Diagram
```
  ┌─────────────────────────────────────────────────────────────────┐
  │                      AUTOMATION FLOW                           │
  │                                                                 │
  │  [design.csv]  ──►  vsdsynth.sh  ──►  vsdsynth.tcl            │
  │       │                                     │                  │
  │       │                          ┌──────────▼───────────┐      │
  │       │                          │   Parse CSV Matrix   │      │
  │       │                          │  (struct::matrix)    │      │
  │       │                          └──────────┬───────────┘      │
  │       │                                     │                  │
  │       ▼                          ┌──────────▼───────────┐      │
  │  [constraints.csv]  ──────────►  │  Generate .sdc file  │      │
  │                                  │  (clocks, I/O delays)│      │
  │                                  └──────────┬───────────┘      │
  │                                             │                  │
  │  [netlist/*.v]  ──────────────►  ┌──────────▼───────────┐      │
  │                                  │  Hierarchy Check +   │      │
  │                                  │  Yosys Synthesis     │      │
  │                                  └──────────┬───────────┘      │
  │                                             │                  │
  │  [.lib, .spef]  ──────────────►  ┌──────────▼───────────┐      │
  │                                  │  OpenTimer STA       │      │
  │                                  │  (.conf generation)  │      │
  │                                  └──────────┬───────────┘      │
  │                                             │                  │
  │                                  ┌──────────▼───────────┐      │
  │                                  │  Final Report        │      │
  │                                  │  WNS | FEP | Area   │      │
  │                                  └──────────────────────┘      │
  └─────────────────────────────────────────────────────────────────┘
```
---
📅 Day 1 — Shell Scripting & TCL Setup
Objective
Get comfortable with the Linux shell environment, understand file permissions, and set up the bridge between shell scripts and TCL scripts for EDA automation.
---
1.1 Making Scripts Executable
Before a script can be run, it must be given execute permission using `chmod`:
```bash
chmod +x filename    # grant execute permission
./filename           # run the script
```
> **Why `./`?**  
> In Linux, the current directory is not in `PATH` by default (for security). The `./` prefix explicitly tells the shell to look in the current directory.
---
1.2 Shell → TCL Bridge
In EDA flows, a Bash script acts as the entry point: it validates inputs and then calls the TCL interpreter with the actual logic script.
`vsdsynth` (shell script):
```bash
#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: ./vsdsynth <design.csv>"
    exit 1
fi

tclsh vsdsynth.tcl $1
```
`vsdsynth.tcl` is invoked with the CSV filename as its first argument.
> Here `vsdsynth` is the shell script and `vsdsynth.tcl` is the TCL script called inside it.  
> `$argv[1]` corresponds to the only/first file argument.  
> If a secondary file is passed, it would be `$argv[2]`.
---
1.3 Key Commands
Command	Description
`chmod +x file`	Grant execute permission
`./filename`	Execute script in current directory
`tclsh script.tcl`	Invoke TCL interpreter
`$1`, `$2`	Positional arguments in shell
`#!/bin/bash`	Shebang — specifies the interpreter
---
📸 Screenshots — Day 1
> *Screenshot 1: `chmod +x vsdsynth` — terminal showing `-rwxr-xr-x` permission after the command*
> *Screenshot 2: `./vsdsynth openmsv.csv` — shell script invoking the TCL interpreter*
> *Screenshot 3: Contents of `vsdsynth` — shebang, argument validation, and `tclsh` call*
---
📅 Day 2 — CSV Parsing & Matrix Operations
Objective
Learn how to declare TCL variables, read command-line arguments, open and parse CSV files, build matrix data structures, and perform string transformations.
---
2.1 Variables & Command-Line Arguments
TCL uses `set` to create variables. Arguments passed from the shell are available via the `argv` list.
```tcl
# lindex $argv 0  →  first argument (like $1 in bash)
set filename [lindex $argv 0]

# For a second file:
# set filename2 [lindex $argv 1]
```
> `Set variable [lindex $argv 0]` — sets a variable to the value at index 0 of `$argv`, i.e., `$argv[1]` in shell terms.
---
2.2 Opening & Parsing a CSV File
```tcl
package require csv
package require struct::matrix

# Declare the CSV file as a variable
set filename "openmsv.csv"

# Open the file in read mode
set f [open $filename r]

# Create a matrix named 'm'
struct::matrix m

# Read CSV content into matrix; 'auto' detects rows/columns
csv::read2matrix $f m , auto

# Convert matrix into array format for easy access
m link m_arr
```
> **Matrix convention:** TCL matrices use `(column, row)` — not `(row, column)`.  
> A **2,6 matrix** means **2 columns and 6 rows**.
---
2.3 Extracting Values from the Matrix
```tcl
set i 0

# m_arr(column, row) — column 0, row 0 gives design name
set DesignName [m_arr(0,$i)]

# Print to screen
puts "Design Name: $DesignName"
# → Design Name: openMSP430
```
> Taking an incremental variable `$i` as 0 — `my_arr(0,1)` becomes `my_arr(1)`.  
> After this, `puts` prints the values to screen.
---
2.4 String Operations
`string map` — character/substring replacement:
```tcl
# Replace _ghosh with _vsd
set new_name [string map {_ghosh _vsd} $original_name]
# kunal_ghosh  →  kunal_vsd

# Remove spaces to make a valid variable name
set CleanName [string map {" " ""} "Design Name"]
# "Design Name"  →  "DesignName"
```
> `string map` is used to convert a given name to another name.  
> In code, `set string map` removes the space — `"  " ""` — doing concatenation.  
> So `Design Name` becomes `DesignName`, which can then be used as a variable.
Using the cleaned name as a variable:
```tcl
# Set the variable dynamically
set $DesignName "openMSP430"

# Access it:
puts $$DesignName
# → openMSP430
```
> Anything inside `[ ]` is a TCL command that gets executed.  
> To use literal square brackets in output, escape them as `\[` and `\]`.
---
2.5 Verifying File & Directory Existence
```tcl
# Check directories and files mentioned in the .csv exist
if {![file isdirectory $NetlistDirectory]} {
    puts "Error: $NetlistDirectory does not exist."
    exit 1
}
if {![file exists $ConstraintsFile]} {
    puts "Error: Constraints file not found."
    exit 1
}
```
---
📸 Screenshots — Day 2
> *Screenshot 1: `openmsv.csv` — design parameters matrix (design name, netlist dir, constraints file path, etc.)*
> *Screenshot 2: Terminal showing TCL script reading CSV and printing `DesignName = openMSP430`*
> *Screenshot 3: `string map` before/after — `Design Name` → `DesignName`*
> *Screenshot 4: `puts` output of all extracted design parameters from matrix array*
---
📅 Day 3 — SDC Constraint Generation
Objective
Parse the constraints CSV, extract clock/input/output timing parameters, handle multi-bit buses, and write a properly formatted SDC file for synthesis and STA tools.
---
3.1 What is an SDC File?
An SDC (Synopsys Design Constraints) file defines timing requirements. Key commands:
SDC Command	Purpose
`create_clock`	Define clock signal, period, waveform
`set_input_delay`	Input signal arrival time relative to clock
`set_output_delay`	Required output timing
`set_load`	Capacitive load on output ports
---
3.2 Reading the Constraints Matrix
```tcl
struct::matrix constraints
set Chan [open $ConstraintsFile r]

# Used to detect rows and columns automatically
csv::read2matrix $Chan constraints , auto

# Find where each section starts
# e.g., clock is at row 0, input port at row 4, output at row 27
set clock_start  [lindex [constraints search all "clock"]  1]
set input_start  [lindex [constraints search all "input"]  1]
set output_start [lindex [constraints search all "output"] 1]
```
> This constraint search searches between `(0,0)` and `(10,3)` (column, row).  
> Returns `{3 0}` — meaning `early_rise_delay` is at column 3, row 0.  
> Hence `clock_early_rise_delay_start` is set to **3**.
---
3.3 Generating Clock Constraints
```tcl
# Open SDC file in write mode ("w")
set sdc_file [open $OutputDir/$DesignName.sdc w]

set i $clock_start
while {$i < $input_start} {
    set clock_name   [constraints get cell 0 $i]
    set clock_period [constraints get cell $clock_period_start $i]
    set duty_cycle   [constraints get cell $clock_duty_cycle_start $i]

    # Calculate high time for waveform
    set high_time [expr {$clock_period * $duty_cycle / 100.0}]

    # constraint get cell $variable $i → value at (column, row)
    # e.g., cell (3, 1) = 150
    puts $sdc_file "create_clock -name $clock_name -period $clock_period \\"
    puts $sdc_file "    -waveform \[list 0 $high_time\] \[get_ports $clock_name\]"
    incr i
}
```
> `period {0 750}` → clock is HIGH from 0 to 750 ps, LOW from 750 to 1500 ps = **50% duty cycle**.  
> `\[` and `\]` are used for literal brackets in SDC output — TCL would otherwise try to evaluate `[...]` as a command.
---
3.4 Processing Input Constraints & Bus Detection
```tcl
# For n-bit buses, append '*'
set i $input_start
while {$i < $output_start} {
    set port_name [constraints get cell 0 $i]

    # Remove spaces, count elements
    set count [llength [split [regsub -all {\s+} $port_name ""] ""]]

    if {$count > 2} {
        # Declare as bus with wildcard: dbg_i2c_adr*
        append port_name "*"
    }
    # else keep as-is: cpu_en

    puts $sdc_file "set_input_delay ... \[get_ports $port_name\]"
    incr i
}
```
> First remove spaces, then take the count of elements.  
> If `$count > 2` → declare it as a bus and put `*` → `dbg_i2c_adr*`  
> Else keep the port as-is → `cpu_en`
---
3.5 Globbing & Verilog Netlist Parsing
> **Globbing** is the process of identifying wildcards/patterns in a directory.
```tcl
# Find all .v files in $NetlistDirectory
set netlist_files [glob -dir $NetlistDirectory *.v]
# $netlist_files now contains all .v files present

# Parse Verilog files to extract input port names
set tmp_file [open /tmp/1 w]   # create temp file in write mode

foreach file $netlist_files {
    set fh [open $file r]
    while {[gets $fh line] != -1} {
        if {[regexp {^\s*input\s+(.*)} $line match portdecl]} {
            # regsub -all {\s+} $s1 "" → replace all whitespace with nothing
            set clean [regsub -all {\s+} $portdecl ""]
            puts $tmp_file $clean
        }
    }
    close $fh
}
close $tmp_file
```
> This TCL snippet **parses Verilog netlist files** and extracts **input port names** into a temporary file.  
> `[regsub -all {\s+} $s1 ""]` — replaces all empty white spaces with nothing (string cleanup).
---
📸 Screenshots — Day 3
> *Screenshot 1: Constraints CSV — clock at row 0, input at row 4, output at row 27, with delay columns*
> *Screenshot 2: Generated `.sdc` file — `create_clock` with `waveform {0 750}`, `set_input_delay` entries*
> *Screenshot 3: Bus detection output — `dbg_i2c_adr*` vs single-bit `cpu_en`*
> *Screenshot 4: `/tmp/1` temp file — extracted and cleaned input port names from Verilog*
---
📅 Day 4 — Yosys Synthesis & Hierarchy Checking
Objective
Automate Yosys synthesis runs via TCL, understand gate-level netlist generation, implement hierarchy checking to validate all sub-modules exist, and build robust error handling.
---
4.1 Yosys Gate-Level Synthesis
Running the `memory.ys` file in Yosys converts the Verilog file `memory.v` into a gate-level netlist.
```bash
# memory.ys synthesis script
read_verilog memory.v
synth -top memory
write_verilog memory_synth.v
```
The resulting netlist contains primitives such as:
`INV` — Inverters
`NAND` — NAND gates
`NOR` — NOR gates
`OAI` — Or-And-Inverter
`AOI` — And-Or-Inverter
---
4.2 Why Hierarchy Checking?
In Verilog, a top module often instantiates lower-level modules:
```verilog
module top();
  alu    u1();    // needs alu.v
  memory u2();    // needs memory.v
endmodule
```
Yosys must confirm all sub-modules exist before synthesis begins. Hierarchy check catches:
❌ Missing module files
❌ Typos in module names
❌ Incomplete design hand-off
> **Fail fast:** Why run optimization/mapping if hierarchy is already broken? Prevent wasting synthesis time.
---
4.3 Hierarchy Check Implementation
```tcl
set my_err 0
set hier_log [open $OutputDir/$DesignName.hierarchy_check.log w]

foreach module_name $module_list {
    # file normalize → converts path to full absolute standard form
    # Expands ~, resolves ./ and ../, gives exact file location
    set vfile [file normalize $NetlistDirectory/$module_name.v]

    if {![file exists $vfile]} {
        puts $hier_log "Error: Module '$module_name' not found at $vfile"
        set my_err 1
    } else {
        puts $hier_log "OK: $module_name"
    }
}
close $hier_log

# Loop begins if (my_err) — only goes to else if no errors
if {$my_err} {
    puts "ERROR: Hierarchy check FAILED. See $DesignName.hierarchy_check.log"
    exit 1
} else {
    puts "Hierarchy check PASSED."
}
```
To inspect the log:
```bash
vim outdir_openMSP430/openMSP430.hierarchy_check.log
```
> In the given error detection script — `if` loop shows presence of any errors.  
> Only if there are **no errors** does it go to the `else` which puts "hierarchy check pass".  
> `lindex 0` = error type, `lindex 2` = error module name.
---
4.4 Running Yosys via `exec`
```tcl
# exec → run Unix shell commands from TCL script
# >& → redirect stdout AND stderr to log file
exec yosys $OutputDir/$DesignName.ys >& $OutputDir/$DesignName.synthesis.log
```
> `exec` is used to run Unix shell commands from the TCL script.  
> `>&` redirects output to `$outputdir`.  
> If `err_flag` is zero → all modules found → in the log all files are executing correctly.
---
4.5 Error Handling Flow
```
  ┌─────────────────────────┐
  │   Start Synthesis Flow  │
  └────────────┬────────────┘
               │
  ┌────────────▼────────────┐
  │   Hierarchy Check       │
  │   (check all .v exist)  │
  └────────────┬────────────┘
               │
       ┌───────┴────────┐
    FAIL                PASS
       │                │
  ┌────▼────┐    ┌───────▼──────────┐
  │ Print   │    │ Create .ys script│
  │ Error   │    │ Run Yosys (exec) │
  │ exit 1  │    └───────┬──────────┘
  └─────────┘            │
               ┌─────────▼──────────┐
               │  Check synth log   │
               └─────────┬──────────┘
                         │
                ┌────────┴─────────┐
              ERROR             SUCCESS
                │                 │
          Print error        Proceed to
          exit 1             post-processing
```
---
📸 Screenshots — Day 4
> *Screenshot 1: Yosys gate-level netlist output — showing INV, NAND, NOR, OAI, AOI cell instances*
> *Screenshot 2: Hierarchy check log (pass) — all modules found, final "PASSED" message*
> *Screenshot 3: Hierarchy check log (error) — missing module with full normalized path*
> *Screenshot 4: TCL script with `if {$my_err}` error handling block and `exec yosys` command*
---
📅 Day 5 — OpenTimer STA & Report Generation
Objective
Complete the full automation flow by invoking OpenTimer for STA, using `proc` for reusable code, reading SDC/SPEF into the timing tool, and generating a formatted summary report with WNS, FEP, and instance count metrics.
---
5.1 Yosys Netlist Post-Processing
Before feeding the netlist to a timing tool, clean up special characters from Yosys output (`/`, `$`):
```tcl
# Script to edit Yosys output netlist — remove extra / and $ characters
set fh [open $OutputDir/$DesignName.synth.v r]
set content [read $fh]
close $fh

set cleaned [regsub -all {/}    $content ""]
set cleaned [regsub -all {\\\$} $cleaned ""]

set out [open $OutputDir/$DesignName.final.v w]
puts $out $cleaned
close $out
```
> Here we have: hierarchy check → main synthesis script (`.ys`) → log file → final `synth.v`.  
> Script works and has removed all the `/` characters.
---
5.2 TCL `proc` — Reusable Procedures
> In TCL, `proc` is used to **define a procedure (function)**. It groups commands together and allows calling them whenever needed.
```tcl
# Define in external procs.tcl file
proc read_lib {args} {
    # Supports three switches: -late, -early, -help
    array set opts {-late "" -early "" -help 0}
    array set opts $args

    if {$opts(-help)} {
        puts "Usage: read_lib -late <lib> or -early <lib>"
        return
    }
    if {$opts(-late)  ne ""} { puts "set_late_celllib  $opts(-late)"  }
    if {$opts(-early) ne ""} { puts "set_early_celllib $opts(-early)" }
}
```
> Pass arguments in main TCL file → sends to external TCL file → does computation → returns outputs.  
> **Write once, call multiple times.**  
> All data gets dumped in the `.conf` file because of the `puts` command.
---
5.3 OpenTimer — STA Tool
> **OpenTimer** is an open-source STA (Static Timing Analysis) tool used to perform setup and hold violation checks.
Generated `.conf` file:
```
read_netlist   openMSP430.final.v
read_celllib   -late  sky130_fd_sc_hd__tt_025C_1v80.lib
read_celllib   -early sky130_fd_sc_hd__ff_100C_1v65.lib
read_spef      openMSP430.spef
read_sdc       openMSP430.sdc
report_timing
exit
```
Opening `outdir_openMSP430/openMSP430.spef` and `.conf` confirms all files are linked correctly.
---
5.4 `read_sdc` proc — SDC to OpenTimer Format
```tcl
# TASK — read_sdc proc
# Take the SDC file and convert it into OpenTimer format
proc read_sdc {sdc_file} {
    set fh [open $sdc_file r]
    set conf ""

    while {[gets $fh line] != -1} {
        # Convert create_clock
        if {[regexp {create_clock.*-period\s+(\S+).*get_ports\s+(\S+)} $line -> period port]} {
            append conf "clock $port $period\n"
        }
        # Convert set_input_delay
        if {[regexp {set_input_delay\s+(\S+).*get_ports\s+(\S+)} $line -> delay port]} {
            append conf "at $port $delay\n"
        }
    }
    close $fh
    return $conf
}
```
---
5.5 Common EDA Multi-Threading Commands
> These are common commands available in most EDA tools for multi-threading, multi-CPU options, analysing distributed timing, routing etc.  
> Internally they are converted into commands understood by the OpenTimer tool.
```tcl
set_num_threads 4
set_num_cpus    2
analyze_distributed_timing
```
These get dumped to the `.conf` file via:
```tcl
# Dumping code in test.tcl — all data goes to .conf
puts $conf_file "set_num_threads $num_threads"
```
---
5.6 Generating the Output Report
> Generation of the output report is very important for STA.  
> Done by placing values in the right format by `grep`ing details from the existing result files.
Key metrics extracted:
Metric	Full Form	How Extracted
`WNS`	Worst Negative Slack	Grep for keyword `RAT` in `.results`, pick the worst (most negative) value
`FEP`	Failing End Points	Total count of `RAT` entries in the results file
`WNS setup`	Worst setup violation	`grep` with `set pattern {setup}`
`FEP setup`	Setup failing endpoints	Count of setup RAT entries
`WNS hold`	Worst hold violation	`grep` with `set pattern {hold}`
`FEP hold`	Hold failing endpoints	Count of hold RAT entries
Instance Count	Total std-cell instances	More instances = larger area
Runtime	Execution time (sec)	`[clock seconds]` divide to get seconds
---
WNS Extraction:
```tcl
# WNS = worst negative slack
# Found by grepping for keyword RAT in .results
# Out of many RATs, we print the worst (highest negative) value
set result_fh [open $OutputDir/$DesignName.results r]
set wns 0

while {[gets $result_fh line] != -1} {
    if {[regexp {RAT\s+(\S+)} $line -> slack]} {
        if {$slack < $wns} { set wns $slack }
    }
}
puts "WNS = $wns"
```
FEP Extraction:
```tcl
# FEP = Failing End Points
# There are multiple RATs — total number of RATs is the FEP
set fep [regexp -all {RAT} [read $result_fh]]
puts "FEP = $fep"
```
For setup and hold — same script, only pattern changes:
```tcl
# FEP setup, WNS setup
set pattern {setup}

# FEP hold, WNS hold
set pattern {hold}
```
Runtime:
```tcl
set start_time [clock seconds]
# ... entire flow ...
set end_time [clock seconds]
# Divide to get value in seconds
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

