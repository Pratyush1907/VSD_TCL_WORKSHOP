# VSD_TCL_WORKSHOP
TCL COURSE USING OPEN SOURCE SOFTWARES LIKE YOSYS AND OPENTIMER
Workshop Overview
This report documents the 5-day TCL Scripting Workshop organized by VSD (VLSI System Design). The workshop covered practical TCL scripting skills with direct application to VLSI EDA toolflows — from shell scripting basics through synthesis automation, constraint generation, and static timing analysis reporting.
 
Workshop Objectives
•	Understand TCL scripting fundamentals for EDA automation
•	Parse CSV files and construct design constraint matrices
•	Generate SDC (Synopsys Design Constraints) from structured data
•	Automate Yosys synthesis with hierarchy checking and error handling
•	Run Static Timing Analysis using OpenTimer and generate output reports
 
Day-wise Summary
Day	Theme	Key Topics
Day 1	Shell & TCL Basics	File permissions, executable scripts, shell-to-TCL bridge
Day 2	CSV Parsing & Matrices	Variables, argv, CSV matrix, struct::matrix, string operations
Day 3	SDC Generation	Clock constraints, input/output delays, bus handling, Verilog parsing
Day 4	Yosys & Hierarchy Check	Gate-level synthesis, hierarchy verification, error handling, exec
Day 5	STA & Report Generation	OpenTimer, proc, read_sdc, WNS, FEP, instance count reports
 
DAY 1 — Introduction to Shell Scripting & TCL Setup
Day 1 Objective
Get comfortable with the Linux shell environment, understand file permissions, and set up the bridge between shell scripts and TCL scripts for EDA automation.
 
1.1 Making Shell Scripts Executable
Before a script can be run on a Linux/Unix system, it must be given execute permission. This is a fundamental step in any scripting workflow.
 
Command: chmod +x
The chmod command changes file permissions. The +x flag adds the execute permission to the file for all users.
chmod +x filename
 
Once execute permission is granted, the script can be run directly from the terminal using the ./ prefix:
./filename
 
Why ./ is needed
In Linux, the current directory (.) is not included in the PATH by default for security reasons. The ./ prefix tells the shell to look for the script in the current working directory rather than searching the system PATH.
 
1.2 Shell Script Structure & TCL Bridge
In EDA tool flows, shell scripts (Bash) serve as the entry point that validates inputs, sets up the environment, and then invokes a TCL interpreter with the actual logic script. This separation of concerns keeps the code modular and maintainable.
 
Example: vsdsynth.sh calling a TCL script
#!/bin/bash
# vsdsynth — Shell wrapper for the TCL synthesis script
 
if [ "$#" -ne 1 ]; then
    echo "Error: Provide exactly one .csv file as argument."
    exit 1
fi
 
tclsh vsdsynth.tcl $1
 
Here, vsdsynth is the shell script and vsdsynth.tcl is the TCL script that is called inside the shell script. The CSV file path is passed as a command-line argument.
 
1.3 Key Linux Commands Used
Command	Description
chmod +x file	Grants execute permission to the script
./filename	Executes a script in the current directory
tclsh script.tcl	Invokes the TCL interpreter on a script
$1, $2 ...	Positional arguments passed to a shell script
#!/bin/bash	Shebang line — specifies the interpreter
<img width="1093" height="456" alt="image" src="https://github.com/user-attachments/assets/e6cb1c39-6e53-4603-8648-642cf708634c" />

