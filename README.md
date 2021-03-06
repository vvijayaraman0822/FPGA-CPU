Pipelined CPU w/ ARM Thumb Instruction Set
=======================================
A 4-stage pipeline, Harvard architecture, Thumb CPU implemented on an Altera DE1 FPGA.

Block Diagram
-------------
<img src="http://jdemps.com/wp-content/uploads/2015/12/cpu-bd.png">

### Fetch ###
* Program Counter (PC) is updated with current branch value.
* Instruction Memory (ROM) reads PC value and outputs new opcode.

### Decode ###
* Interprets ROM Opcode.
* Determines which registers must be read from.
* Stalls pipeline if necessary.

### Execute ###
* Performs operation based on opcode.
* Flags may be set.
* Data Memory (RAM) may be written to.
* If no Stall, will return to Fetch stage.

### Store ###
* RAM performs write into Register File.
* Returns to Fetch stage.

## Stalling ##

A Stall will occur if a Load (LDR) opcode is read. This is necessary to guarantee the registers are loaded with the correct memory before the next instruction performed.

Description
-----------
*IN PROGRESS*

* Harvard Architecture.
* Implements ARM Thumb (16-bit) instruction set.

* 1024, 16-bit, ROM locations.
* 512, 32-bit, RAM locations.

* The pipeline currently meets all timing constraints under a 50 MHz clock. More work will be done to increase this number.

Going Forward
-------------
* Finish instruction set implementation.
* Mitigate Stalls by recording necessary data from Load instruction, and feed to requesting instruction.
