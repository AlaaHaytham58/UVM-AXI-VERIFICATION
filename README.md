1.0 Project Overview
This project constitutes a comprehensive verification environment for an AXI4-Compliant Memory-Mapped Slave design. The environment is constructed using the Universal Verification Methodology (UVM) 1.2 standard library. The primary objective is to validate the functional correctness of the Design Under Test (DUT) for core read and write operations, achieve rigorous coverage closure, and demonstrate proficiency in advanced UVM concepts.

2.0 Specifications and Requirements
The verification effort was conducted against the design specifications detailed in the provided AXI4 documentation. The implementation fulfills the following mandatory requirements:

Full UVM Testbench: Development of a complete UVM environment incorporating all essential verification components.

Core Functionality Verification: Thorough testing of basic read and write operations.

Coverage Closure: Target of 100% functional and code coverage. All coverage exceptions are analyzed and justified.

Assertion-Based Verification: Integration of SystemVerilog Assertions (SVA) to monitor protocol compliance and temporal behavior inline with the UVM environment.

UVM Phasing and Reporting: Strict adherence to the UVM phasing mechanism and implementation of a hierarchical reporting strategy for effective debug.

2.1 UVM Testbench Architecture
The implemented testbench follows a standard UVM layered architecture. The high-level structural diagram is as follows:
 <img width="876" height="472" alt="image" src="https://github.com/user-attachments/assets/17efa09b-9f6b-4fd0-aa18-a3a1af102427" />



    +-----------------------+
    |       axi_test        |  (Base Test)
    +-----------------------+
               |
               | (UVM Configuration)
               v
    +-----------------------+
    |   axi_environment     |  (Test Environment)
    +-----------------------+
               |
               |-----------------------------|
               |                             |
     +-------------------+         +---------------------+
     |  axi_coverage     |         |   axi_scoreboard   |
     |  Collector        |         |   (with Golden     |
     +-------------------+         |    Reference Model)|
               ^                   |                    |
               |                   |                    |
            (analysis port)    (analysis port)     (analysis port)
               |                   ^                    ^
               |                   |                    |
    +----------------------+  +-----------------------------------+
    | Passive Agent (IN)   |  |          Active Agent (OUT)       |
    | - axi_input_monitor  |  | - axi_sequencer                  |
    +----------------------+  | - axi_driver                     |
                              | - axi_output_monitor             |
                              +-----------------------------------+
                                          |
                                  (Virtual Interface)
                                          |
                                  +----------------+
                                  |     DUT        |
                                  | (AXI4 Slave)   |
                                  +----------------+



