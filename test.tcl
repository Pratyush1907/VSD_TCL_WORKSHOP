

proc read_sdc {arg1} {
set sdc_dirname [file dirname $arg1]
set sdc_filename [lindex [split [file tail $arg1] .] 0 ]
set sdc [open $arg1 r]
set tmp_file [open /tmp/1 w]
puts "sdc dirname is $sdc_dirname"
puts "arg1 is $arg1"
puts "part1 is [file tail $arg1]"
puts "part2 is [split [file tail $arg1] .]"
puts "part3 is [lindex [split [file tail $arg1] .] 0 ]"
puts "sdc filename is $sdc_filename"

puts -nonewline $tmp_file [string map {\\\[ "" \\\] "" } [read $sdc]]
close $tmp_file

#--------------------------------------------------------------------------#
#------------------converting create_clock constraints---------------------#
#--------------------------------------------------------------------------#

set tmp_file [open /tmp/1 r]
set timing_file [open /tmp/3 w]
set lines [split [read $tmp_file] "\n"]
puts $lines
set find_clocks [lsearch -all -inline $lines "create_clock*"]
puts $find_clocks
foreach elem $find_clocks {
        set clock_port_name [lindex $elem [expr {[lsearch $elem "get_ports"]+1}]]
        puts "part1 is [lsearch $elem "get_ports"]"
        puts "part2 is [expr {[lsearch $elem "get_ports"]+1}]"
        puts "part3 is $clock_port_name"
        puts "clock_port_name is $clock_port_name"
        set clock_period [lindex $elem [expr {[lsearch $elem "-period"]+1}]]
        puts "cp_part1 is [lsearch $elem "-period"]"
        puts "cp_part2 is [expr {[lsearch $elem "-period"]+1}]"
        puts "cp_part3 is $clock_period"
        puts "clock period is $clock_period"
        set duty_cycle [expr {100 - [expr {([lindex [lindex $elem [expr {[lsearch $elem "-waveform"]+1}]] 1]*100/$clock_period)}]}]
        puts "dc_part1 is [lsearch $elem "-waveform"]"
        puts "dc_part2 is [expr {[lsearch $elem "-waveform"]+1}]"
        puts "dc_part3 is [lindex $elem [expr {[lsearch $elem "-waveform"]+1}]]"
        puts "dc_part4 is [lindex [lindex $elem [expr {[lsearch $elem "-waveform"]+1}]] 1]"
        puts "dc_part5 is [expr {([lindex [lindex $elem [expr {[lsearch $elem "-waveform"]+1}]] 1]*100/$clock_period)}]"
        puts "dc part6 is $duty_cycle"
        puts "duty cycle is $duty_cycle"
        puts $timing_file "clock $clock_port_name $clock_period $duty_cycle"
        puts "clock $clock_port_name $clock_period $duty_cycle\n"
}
close $tmp_file

read_sdc outdir_openMSP430/openMSP430.sdc
}

