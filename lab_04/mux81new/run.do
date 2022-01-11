#
# Copyright 1991-2015 Mentor Graphics Corporation
#
# All Rights Reserved.
#
# THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION
# WHICH IS THE PROPERTY OF MENTOR GRAPHICS CORPORATION
# OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
#
# To run this example, bring up the simulator and type the following at the prompt:
#     do run.do
# or, to run from a shell, type the following at the shell prompt:
#     vsim -c -do run.do
# (omit the "-c" to see the GUI while running from the shell)
#

onerror {resume}
# Create the library.
if [file exists work] {
    vdel -all
}
vlib work

# Compile the HDL source(s)
vlog -sv -dpiheader grey.h grey.v grey.c

# Simulate the design
onerror {quit -sim}
vsim -c -voptargs="+acc=rn" top
onbreak {resume}

# log signals in database
log -r *
add wave -divider "INPUTS"
add wave /top/enable_b
add wave /top/select(0)
add wave /top/select(1)
add wave /top/select(2)
add wave -divider "OUTPUTS"
add wave /top/y_l

# run simulation
run -all
#quit -f
