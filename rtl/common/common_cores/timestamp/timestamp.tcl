# Simple script that generates a timestamp for inclusion in HDL from the date and time.

# Generates a package file for inclusion in the project. 
# This package contains the constant TIMESTAMP with the timestamp stored as a 32 bit std_logic_vector
proc generate_vhdl {fname timestamp_hex} {
    if { [catch {
        set fh [open ${fname} w ]
        puts $fh "library ieee;"
        puts $fh "use ieee.std_logic_1164.all;"
        puts $fh "package pkg_timestamp is"
        puts $fh "  -- Constants"
        puts $fh [format "  constant TIMESTAMP : std_logic_vector(31 downto 0) := x\"%X\";" $timestamp_hex]
        puts $fh "end pkg_timestamp;"
        puts $fh "package body pkg_timestamp is"
        puts $fh "end pkg_timestamp;"
        close $fh
    } res ] } {
        return -code error $res
    } else {
        return 1
    }
}

# Generates a text file that contains the timestamp with it's date and time for easy reference
proc write_timestamp {fname timestamp timestamp_formatted} {
    if { [catch {
        set fh [open ${fname} w ]
        puts $fh "Timestamp ${timestamp}"
        puts $fh [format "Hex Timestamp %X" $timestamp]
        puts $fh "${timestamp_formatted}"
        close $fh
    } res ] } {
        return -code error $res
    } else {
        return 1
    }
}


# Time used as the timestamp from the clock command in various formats
set time [clock seconds]
set time_formatted [clock format $time -format {%Y/%m/%d %H:%M:%S}]
set time_hex [format $time x]

# filename of the HDL to be included in the project
set fname_hdl "pkg_timestamp.vhd"
# filename of the txt file that contains the timetamp with it's date and time for reference
set fname_tstamp_ref "hdl_timestamp.txt"

# # Old timestamp code from the R-MX
# set y [expr [scan [clock format $time -format {%y}] %d] & 63]
# set year [expr $y<<27]
# set mth [expr [scan [clock format $time -format {%m}] %d] & 15]
# set mon [expr $mth<<23]
# set d [expr [scan [clock format $time -format {%d}] %d] & 31]
# set day [expr $d <<17]
# set h [expr [scan [clock format $time -format {%H}] %d] & 31]
# set hour [expr $h<<12]
# set mn [expr [scan [clock format $time -format {%M}] %d] & 63]
# set min [expr $mn<<6]
# set sec [expr [scan [clock format $time -format {%S}] %d] & 63]
# set timestamp [expr {$sec + $min + $hour + $day + $mon + $year}]

set build_dir [pwd]
cd ../ip/common_cores/timestamp/rtl/
# Create the reference txt file
if { [catch { write_timestamp $fname_tstamp_ref $time $time_formatted} res] } {
    post_message -type critical_warning \
    "Couldn't write timestamp text file. $res"
# Create the HDl pkg file containing the timestamp
} elseif { [catch { generate_vhdl $fname_hdl $time_hex} res] } {
    post_message -type critical_warning \
    "Couldn't generate timestamp VHDL file. $res"
} else {
    # Save both the hld file and the reference txt file in output_files
    file mkdir $build_dir/output_files
    file copy -force ${fname_tstamp_ref} $build_dir/output_files/.
    file copy -force ${fname_hdl} $build_dir/output_files/.
    post_message "Timestamp updated to [format "0x%X" $time_hex]: $time_formatted"
}
cd $build_dir
