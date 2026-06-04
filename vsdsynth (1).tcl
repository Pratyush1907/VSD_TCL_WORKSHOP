set enable_prelayout_timing 1
set working_dir [pwd]
set filename [lindex $argv 0]
package require csv
package require struct::matrix
struct::matrix m
set f [open $filename]
csv::read2matrix $f m , auto
close $f

set columns [m columns]

#n add columns $columns
m link my_arr

set num_of_rows [m rows]
set i 0

while { $i < $num_of_rows } {
        puts "\nInfo: Setting $my_arr(0,$i) as '$my_arr(1,$i)'"

        if { $i == 0 } {
                set [string map {" " ""} $my_arr(0,$i)] $my_arr(1,$i)
        } else {
                set [string map {" " ""} $my_arr(0,$i)] [file normalize $my_arr(1,$i)]
        }

        set i [expr {$i+1}]
}

puts "\nInfo: Below are the list of initial variables and their values. User can use these variables for further debug. Use 'puts <variable name>' command to query value of below variables"

puts "DesignName = $DesignName"
puts "OutputDirectory = $OutputDirectory"
puts "NetlistDirectory = $NetlistDirectory"
puts "EarlyLibraryPath = $EarlyLibraryPath"
puts "LateLibraryPath = $LateLibraryPath"
puts "ConstraintsFile = $ConstraintsFile"
if {![file exists $EarlyLibraryPath]} {
    puts "\nError: Cannot find early cell library in path $EarlyLibraryPath. Exiting..."
    exit
} else {
    puts "\nInfo: Early cell library found in path $EarlyLibraryPath"
}

if {![file exists $LateLibraryPath]} {
    puts "\nError: Cannot find late cell library in path $LateLibraryPath. Exiting..."
    exit
} else {
    puts "\nInfo: Late cell library found in path $LateLibraryPath"
}

if {![file isdirectory $OutputDirectory]} {
    puts "\nInfo: Cannot find output directory $OutputDirectory. Creating $OutputDirectory"
    file mkdir $OutputDirectory
} else {
    puts "\nInfo: Output directory found in path $OutputDirectory"
}

if {![file isdirectory $NetlistDirectory]} {
    puts "\nError: Cannot find RTL netlist directory in path $NetlistDirectory. Exiting..."
    exit
} else {
    puts "\nInfo: RTL netlist directory found in path $NetlistDirectory"
}

if {![file exists $ConstraintsFile]} {
    puts "\nError: Cannot find constraints file in path $ConstraintsFile. Exiting..."
    exit
} else {
    puts "\nInfo: Constraints file found in path $ConstraintsFile"

    puts "\nInfo: Dumping SDC constraints for $DesignName"
}
::struct::matrix constraints
set chan [open $ConstraintsFile]
csv::read2matrix $chan constraints , auto
close $chan

set number_of_rows [constraints rows]
puts "number_of_rows = $number_of_rows"

set number_of_columns [constraints columns]
puts "number_of_columns = $number_of_columns"
set clock_start [lindex [lindex [constraints search all CLOCKS] 0] 1]
set clock_start_column [lindex [lindex [constraints search all CLOCKS] 0] 0]
puts "Pratyush clock_start $clock_start $clock_start_column"

#--check row number for "inputs" section in constraints.csv--#
set input_ports_start [lindex [lindex [constraints search all INPUTS] 0] 1]
puts "input ports start = $input_ports_start"

#--check row number for "outputs" section in constraints.csv--#
set output_ports_start [lindex [lindex [constraints search all OUTPUTS] 0] 1]
puts "output ports start = $output_ports_start"

set clock_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] early_rise_delay] 0] 0]

set clock_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] early_fall_delay] 0] 0]

set clock_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] late_rise_delay] 0] 0]

set clock_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] late_fall_delay] 0] 0]

#--------------------clock transition constraints--------------------#

set clock_early_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] early_rise_slew] 0] 0]

set clock_early_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] early_fall_slew] 0] 0]

set clock_late_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] late_rise_slew] 0] 0]

set clock_late_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] late_fall_slew] 0] 0]

set sdc_file [open $OutputDirectory/$DesignName.sdc w]
set i [expr {$clock_start+1}]
set end_of_ports [expr {$input_ports_start-1}]
puts "\nInfo-SDC: Working on clock constraints....."


set sdc_file [open $OutputDirectory/$DesignName.sdc w]
set i [expr {$clock_start+1}]
set end_of_ports [expr {$input_ports_start-1}]
puts "\nInfo-SDC: Working on clock constraints....."
puts "\nInfo: Creating hierarchy check script to be used by Yosys"

set data "read_liberty -lib -ignore_miss_dir -setattr blackbox ${LateLibraryPath}"
puts "data is \"$data\" "

set filename "$DesignName.hier.ys"
puts "filename is \"$filename\""

set fileId [open $OutputDirectory/$filename "w"]
puts "open \"$OutputDirectory/$filename\" in write mode"

puts -nonewline $fileId $data

set netlist [glob -dir $NetlistDirectory *.v]
puts "netlist is \"$netlist\" "

foreach f $netlist {
    set data $f
    puts "data is \"$f\" "

    #puts "\nread_verilog $f"

    puts -nonewline $fileId "\nread_verilog $f"
}

puts -nonewline $fileId "\nhierarchy -check"

close $fileId

puts "\nclose \"\OutputDirectory/$filename\"\n"
puts "\nChecking hierarchy....."
set my_err [catch { exec yosys -s $OutputDirectory/$DesignName.hier.ys >& $OutputDirectory/$DesignName.hierarchy_check.log} msg]
puts "err flag is $my_err"
if { $my_err } {
    set filename "$OutputDirectory/$DesignName.hierarchy_check.log"
    puts "log file name is $filename"
    set pattern {referenced in module}
    puts "pattern is $pattern"
    set count 0
    set fid [open $filename r]
    while {[gets $fid line] != -1} {
        incr count [regexp -all -- $pattern $line]
        if {[regexp -all -- $pattern $line]} {
            puts "\nError: module [lindex $line 2] is not part of design $DesignName. Please correct RTL in the path '$NetlistDirectory'"
            puts "\nInfo: Hierarchy check FAIL"
        }
    }
    close $fid
} else {
    puts "\nInfo: Hierarchy check PASS"
}

puts "\nInfo: Please find hierarchy check details in [file normalize $OutputDirectory/$DesignName.hierarchy_check.log] for more info"
cd $working_dir
puts "\nInfo: Creating main synthesis script to be used by Yosys"
set data "read_liberty -lib  -ignore_miss_dir -setattr blackbox ${LateLibraryPath}"
set filename "$DesignName.ys"
set fileId [open $OutputDirectory/$filename "w"]
puts -nonewline $fileId $data

set netlist [glob -dir $NetlistDirectory *.v]
foreach f $netlist {
    set data $f
    puts -nonewline $fileId "\nread_verilog $f"
}

puts -nonewline $fileId "\nhierarchy -top $DesignName"
puts -nonewline $fileId "\nsynth -top $DesignName"
puts -nonewline $fileId "\nsplitnets -ports -format __\ndfflibmap -liberty ${LateLibraryPath}\nopt"
puts -nonewline $fileId "\nabc -liberty ${LateLibraryPath}"
puts -nonewline $fileId "\nflatten"
puts -nonewline $fileId "\nclean -purge\niopadmap -outpad BUFX2 A:Y -bits\nopt\nclean"
puts -nonewline $fileId "\nwrite_verilog $OutputDirectory/$DesignName.synth.v"
close $fileId
puts "\nInfo: Synthesis script created and can be accessed from path $OutputDirectory/$DesignName.ys"

puts "\nInfo: Running synthesis........"


#-------------------------------------------------------------#
#----------------- Run synthesis script using yosys ----------#
#-------------------------------------------------------------#

if {[catch { exec yosys -s $OutputDirectory/$DesignName.ys >& $OutputDirectory/$DesignName.synthesis.log} msg]} {
        puts "\nError: Synthesis failed due to errors. Please refer to log $OutputDirectory/$DesignName.synthesis.log for errors"
        exit
} else {
        puts "\nInfo: Synthesis finished successfully"
}
puts "\nInfo: Please refer to log $OutputDirectory/$DesignName.synthesis.log"
#-------------------------------------------------------------#
#                 Edit synth.v to be usable by Optimter       #
#-------------------------------------------------------------#

set fileId [open /tmp/1 "w"]
puts -nonewline $fileId [exec grep -v -w "*" $OutputDirectory/$DesignName.synth.v]
close $fileId

set output [open $OutputDirectory/$DesignName.final.synth.v "w"]

set filename "/tmp/1"
set fid [open $filename r]
    while {[gets $fid line] != -1} {
        puts -nonewline $output [string map { "\\" "" } $line]
        puts -nonewline $output "\n"
    }

close $fid
close $output

puts "\nInfo: Please find the synthesized netlist for $DesignName at below path. You can use this netlist for STA or PNR"
puts "\n$OutputDirectory/$DesignName.final.synth.v"


puts "\nInfo: Timing Analysis Started................................."
puts "\nInfo: Initializing number of threads, libraries, sdc, verilog netlist path..."
source procs/reopenStdout.proc
source procs/set_num_threads.proc
reopenStdout $OutputDirectory/$DesignName.conf
set_multi_cpu_usage -localCpu 4

source procs/read_lib.proc

read_lib -early osu019_stdcells.lib

read_lib -late osu018_stdcells.lib

if {$enable_prelayout_timing == 1} {
    puts "\nInfo: enable_prelayout_timing is $enable_prelayout_timing. Enabling zero-wire load parasitics"
    set spef_file [open $OutputDirectory/$DesignName.spef w]

    puts $spef_file "*SPEF \"IEEE 1481-1998\" "
    puts $spef_file "*DESIGN \"$DesignName\" "
    puts $spef_file "*DATE \"Tue Sep 25 11:51:50 2012\" "
    puts $spef_file "*VENDOR \"TAU 2015 Contest\" "
    puts $spef_file "*PROGRAM \"Benchmark Parasitic Generator\" "
    puts $spef_file "*VERSION \"0.0\" "
    puts $spef_file "*DESIGN_FLOW \"NETLIST_TYPE_VERILOG\" "
    puts $spef_file "*DIVIDER / "
    puts $spef_file "*DELIMITER : "
    puts $spef_file "*BUS_DELIMITER [ ] "
    puts $spef_file "*T_UNIT 1 PS "
    puts $spef_file "*C_UNIT 1 FF "
    puts $spef_file "*R_UNIT 1 KOHM "
    puts $spef_file "*L_UNIT 1 UH "
}

close $spef_file

set conf_file [open $OutputDirectory/$DesignName.conf a]
puts $conf_file "set_spef_fpath $OutputDirectory/$DesignName.spef"
puts $conf_file "init_timer "
puts $conf_file "report_timer "
puts $conf_file "report_wns "
puts $conf_file "report_worst_paths -numPaths 10000 "
close $conf_file

set tcl_precision 3
set time_elapsed_in_us [time {exec /workspaces/vsd-tcl/.devcontainer/OpenTimer < $OutputDirectory/$DesignName.conf >& $OutputDirectory/$DesignName.results}]
puts "time elapsed in us is $time_elapsed_in_us"
set time_elapsed_in_sec [expr {[lindex $time_elapsed_in_us 0]/1000000}]sec
puts "time elapsed in sec is $time_elapsed_in_sec"
puts "\nInfo: STA finished in $time_elapsed_in_sec seconds"
puts "\nInfo: Refer to $OutputDirectory/$DesignName.results for warnings and errors"
#set tcl_precision 3
puts "tcl_precision is $tcl_precision"

#-----find worst output violation-----#
set worst_RAT_slack ""
set report_file [open $OutputDirectory/$DesignName.results r]
puts "report_file is $OutputDirectory/$DesignName.results"
set pattern {RAT}
puts "pattern is $pattern"
while {[gets $report_file line] != -1} {
    if {[regexp $pattern $line]} {
        puts "pattern \"$pattern\" found in \"$line\""
        puts "old worst_RAT_slack is $worst_RAT_slack"
        set worst_RAT_slack "[expr {[lindex $line 3]/1000}]ns"
        puts "part1 is [lindex $line 3]"
        puts "new worst_RAT_slack is $worst_RAT_slack"
        puts "breaking"
        break
    } else {
        continue
    }
}
close $report_file

#-----find number of output violation-----#
set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
puts "initial count is $count"
puts "being count"
while {[gets $report_file line] != -1} {
    incr count [regexp -all -- $pattern $line]
}
set Number_output_violations $count
puts "Number_output_violations is $Number_output_violations"
close $report_file

#-----find worst setup violation-----#
set worst_negative_setup_slack ""
set report_file [open $OutputDirectory/$DesignName.results r]
set pattern {Setup}
while {[gets $report_file line] != -1} {
    if {[regexp $pattern $line]} {
        set worst_negative_setup_slack "[expr {[lindex $line 3]/1000}]ns"
        break
    } else {
        continue
    }
}
close $report_file

#-----find number of setup violation-----#
set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while {[gets $report_file line] != -1} {
    incr count [regexp -all -- $pattern $line]
}
set Number_of_setup_violations $count
close $report_file

#-----find worst hold violation-----#
set worst_negative_hold_slack ""
set report_file [open $OutputDirectory/$DesignName.results r]
set pattern {Hold}
while {[gets $report_file line] != -1} {
    if {[regexp $pattern $line]} {
        set worst_negative_hold_slack "[expr {[lindex $line 3]/1000}]ns"
        break
    } else {
        continue
    }
}
close $report_file

#-----find number of hold violation-----#
set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while {[gets $report_file line] != -1} {
    incr count [regexp -all -- $pattern $line]
}
set Number_of_hold_violations $count
close $report_file

#-----find number of instance-----#
set pattern {Num of gates}
set report_file [open $OutputDirectory/$DesignName.results r]
while {[gets $report_file line] != -1} {
    if {[regexp -all -- $pattern $line]} {
        set Instance_count [lindex [join $line " "] 4]
        puts "pattern \"$pattern\" found at line \"$line\""
        break
    } else {
        continue
    }
}
close $report_file

puts "DesignName is \{$DesignName\}"
puts "time elapsed in sec is \{$time_elapsed_in_sec\}"
puts "Instance_count is \{$Instance_count\}"
puts "worst_negative_setup_slack is \{$worst_negative_setup_slack\}"
puts "Number_of_setup_violations is \{$Number_of_setup_violations\}"
puts "worst_negative_hold_slack is \{$worst_negative_hold_slack\}"
puts "Number_of_hold_violations is \{$Number_of_hold_violations\}"
puts "worst_RAT_slack is \{$worst_RAT_slack\}"
puts "Number_output_violations is \{$Number_output_violations\}"
