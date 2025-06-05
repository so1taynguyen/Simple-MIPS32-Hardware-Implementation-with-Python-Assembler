<a id="readme-top"></a>
<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![Unlicense License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]


<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
	  <ul>
        <li><a href="#key-features">Key Features</a></li>
		<li><a href="#project-components">Project Components</a></li>
		<li><a href="#project-architecture">Project Architecture</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#how-to-run">How to run</a></li>
    <li><a href="#achievement">Achievement</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

This project features a synthesizable 32-bit MIPS processor core (MIPS32) implemented in Verilog, supporting a subset of the MIPS ISA with basic and pseudo-instructions for arithmetic, logical, shift, comparison, memory access, and control flow operations. It includes a Python assembler that converts assembly code into machine code, generating instruction (`imem_data.mem`) and data (`dmem_data.mem`) memory files for simulation and verification.

<p align="right">(<a href="#readme-top">Back to top</a>)</p>



### Key Features

* __MIPS32 Core__: A single-cycle processor implementing a custom MIPS32 ISA with R-type, I-type, and J-type instructions, including arithmetic (e.g., add, sub), logical (e.g., and, or, xor), shift (e.g., sll, srl, sra), comparison (e.g., slt, seq), memory access (lw, sw), and branching/jump instructions (beq, bne, j).
* __Pseudo-Instruction Support__: The assembler supports pseudo-instructions like blt, bgt, ble, bge, beqz, bnez, abs, neg, and li, which are expanded into basic instructions for compatibility with the core.
* __Python Assembler__: A Python script ([instr_converter.py](https://github.com/so1taynguyen/Simple-MIPS32-Hardware-Implementation-with-Python-Assembler/blob/main/include/instr_converter.py)) that parses assembly code, handles labels, validates syntax, and generates 32-bit hexadecimal machine code. It also supports error checking for invalid register usage and instruction formats.
* __Memory Initialization__: Random data memory initialization is provided via [mem_gen.py](https://github.com/so1taynguyen/Simple-MIPS32-Hardware-Implementation-with-Python-Assembler/blob/main/include/mem_gen.py), which generates 1024 random 32-bit values for the data memory file.
* __Verification Framework__: A Verilog testbench ([testbench.v](https://github.com/so1taynguyen/Simple-MIPS32-Hardware-Implementation-with-Python-Assembler/blob/main/verify/testbench.v)) with a reference model and scoreboard compares the processor's output against expected results, ensuring correct execution of instructions.
* __Simulation Support__: The project includes a script ([run.sh](https://github.com/so1taynguyen/Simple-MIPS32-Hardware-Implementation-with-Python-Assembler/blob/main/run/run.sh)) for running simulations using a tool like Cadence Xcelium, Siemens Questa, Synopsys VCS, Icarus Verilog, etc. with automated error checking for compilation and runtime issues.


<p align="right">(<a href="#readme-top">Back to top</a>)</p>

### Project Components

#### Verilog Modules:
* [processor.v](https://github.com/so1taynguyen/Simple-MIPS32-Hardware-Implementation-with-Python-Assembler/blob/main/src/processor.v): Top-level module integrating the control unit and datapath.
* [datapath.v](https://github.com/so1taynguyen/Simple-MIPS32-Hardware-Implementation-with-Python-Assembler/blob/main/src/datapath.v): Handles data flow, including register file, ALU, and memory operations.
* [control_unit.v](https://github.com/so1taynguyen/Simple-MIPS32-Hardware-Implementation-with-Python-Assembler/blob/main/src/control_unit.v): Generates control signals based on instruction opcodes and function codes.
* [ALU.v](https://github.com/so1taynguyen/Simple-MIPS32-Hardware-Implementation-with-Python-Assembler/blob/main/src/ALU.v): Implements arithmetic, logical, shift, and comparison operations with overflow detection.
* [reg_file.v](https://github.com/so1taynguyen/Simple-MIPS32-Hardware-Implementation-with-Python-Assembler/blob/main/src/reg_file.v): A 32-register file with read/write capabilities, ensuring r0 is read-only.
* [mem.v](https://github.com/so1taynguyen/Simple-MIPS32-Hardware-Implementation-with-Python-Assembler/blob/main/src/mem.v): Memory module for instruction (imem) and data (dmem) with block RAM style.
* [adder.v](https://github.com/so1taynguyen/Simple-MIPS32-Hardware-Implementation-with-Python-Assembler/blob/main/src/adder.v), [mux2_1.v](https://github.com/so1taynguyen/Simple-MIPS32-Hardware-Implementation-with-Python-Assembler/blob/main/src/mux2_1.v), [sign_ext.v](https://github.com/so1taynguyen/Simple-MIPS32-Hardware-Implementation-with-Python-Assembler/blob/main/src/sign_ext.v), [jump_sign_ext.v](https://github.com/so1taynguyen/Simple-MIPS32-Hardware-Implementation-with-Python-Assembler/blob/main/src/jump_sign_ext.v), [pc_counter.v](https://github.com/so1taynguyen/Simple-MIPS32-Hardware-Implementation-with-Python-Assembler/blob/main/src/pc_counter.v): Supporting modules for arithmetic, multiplexing, sign extension, and program counter management.

#### Python Scripts:
* [instr_converter.py](https://github.com/so1taynguyen/Simple-MIPS32-Hardware-Implementation-with-Python-Assembler/blob/main/include/instr_converter.py): Converts MIPS assembly code from [input_instr.txt](https://github.com/so1taynguyen/Simple-MIPS32-Hardware-Implementation-with-Python-Assembler/blob/main/run/input_instr.txt) to machine code, with support for pseudo-instructions and label resolution.
* [mem_gen.py](https://github.com/so1taynguyen/Simple-MIPS32-Hardware-Implementation-with-Python-Assembler/blob/main/include/mem_gen.py): Generates random data for dmem_data.mem.

#### Testbench and Simulation:
* [testbench.v](https://github.com/so1taynguyen/Simple-MIPS32-Hardware-Implementation-with-Python-Assembler/blob/main/verify/testbench.v): Verifies processor functionality by comparing hardware outputs with a reference model.
* [run.sh](https://github.com/so1taynguyen/Simple-MIPS32-Hardware-Implementation-with-Python-Assembler/blob/main/run/run.sh): Automates simulation and error reporting.


#### Instruction Set:
* Defined in [ISA.xlsx](https://github.com/so1taynguyen/Simple-MIPS32-Hardware-Implementation-with-Python-Assembler/blob/main/include/ISA.xlsx), detailing basic and pseudo-instructions with their opcodes, formats, and examples.


#### Sample Programs:
* [input_instr.txt](https://github.com/so1taynguyen/Simple-MIPS32-Hardware-Implementation-with-Python-Assembler/blob/main/run/input_instr.txt): Contains MIPS assembly programs for computing GCD (using basic and pseudo-instructions), summation, multiplication via addition, Fibonacci numbers, and factorial.

<p align="right">(<a href="#readme-top">Back to top</a>)</p>

### Project Architecture

![Top_architect](https://github.com/so1taynguyen/Simple-MIPS32-Hardware-Implementation-with-Python-Assembler/blob/main/images/FPU%20co-processor.png) 

<p align="right">(<a href="#readme-top">Back to top</a>)</p>

<!-- GETTING STARTED -->
## Getting Started

To set up and run the Simple-MIPS32 project locally, you need to install the required tools and follow the installation steps below.

### Prerequisites

The following tools are required to run the assembler, simulate the processor, and view simulation results:
* __Python3__: Used to run the assembler (instr_converter.py) and memory generator (mem_gen.py)
    ```sh
    # Linux (Ubuntu/Debian):
        sudo apt update
        sudo apt install python3 python3-pip
    ```
* __Verilog Simulation Tool__: At least one of the following tools is required to Verilog simulator to compile and simulate the processor:
    * Cadence Xcelium Logic Simulator: Commercial tool, requires a license. Contact Cadence for installation details.
    * Siemens QuestaSim: Commercial tool, requires a license. Refer to Siemens documentation for setup.
    * Synopsys VCS: Commercial tool, requires a license. Refer to Synopsys documentation for setup.
    * Icarus Verilog: Free, open-source Verilog simulator.
        ```sh
        # Linux (Ubuntu/Debian):
            sudo apt update
            sudo apt install iverilog gtkwave
        ```

### Installation

1. Clone the repo
   ```sh
   git clone https://github.com/so1taynguyen/Simple-MIPS32-Hardware-Implementation-with-Python-Assembler.git
   cd Simple-MIPS32-Hardware-Implementation-with-Python-Assembler
   ```
2. Verify Python scripts
   ```sh
   python3 include/instr_converter.py --help
   python3 include/mem_gen.py --help
   ```
3. Ensure the Verilog simulation tool and waveform viewer are installed and in your PATH
4. Change the Git remote URL to avoid accidental pushes to the original repository
    ```sh
    git remote set-url origin https://github.com/your_username/your_repo.git
    git remote -v # Confirm the changes
    ```
5. Change git remote url to avoid accidental pushes to base project
   ```sh
   git remote set-url origin github_username/repo_name
   git remote -v # confirm the changes
   ```

<p align="right">(<a href="#readme-top">Back to top</a>)</p>



<!-- USAGE EXAMPLES -->
## How to run

Follow these steps to run the MIPS32 processor simulation:
1. Write or edit MIPS assembly code in run/input_instr.txt
    * Example:
        ```assembly
        main:
            addi $t0, $0, 5
            addi $t1, $0, 3
            add $t2, $t0, $t1 
        ```
2. Edit run/run.sh to select your simulation tool and scoreboard option (`+define+RTL_VERIFY`)
    * Example with scoreboard:
        ```sh
        xrun -work WORK -access +r ../verify/testbench.v -l ./my_work_dir/xrun.log -xmlibdirpath ./my_work_dir +define+RTL_VERIFY > ./my_work_dir/run.log
        ```
    * Example without scoreboard:
        ```sh
        xrun -work WORK -access +r ../verify/testbench.v -l ./my_work_dir/xrun.log -xmlibdirpath ./my_work_dir > ./my_work_dir/run.log
        ```
3. Run the simulation using the provided script
    ```sh
    cd ./run
    chmod 777 run.sh
    ./run.sh
    ```
4. Check simulation results
    * View pass/fail results and errors in run.log
    * Open the waveform file (e.g., dump.vcd) in a viewer like GTKWave or SimVision:
        ```sh
        gtkwave dump.vcd
        ```
For detailed examples, see refer to the sample programs in input_instr.txt for algorithms like GCD, summation, and Fibonacci.

<p align="right">(<a href="#readme-top">Back to top</a>)</p>

<!-- ROADMAP -->
## Achievement

This section highlights the successful verification of the MIPS32 processor for various algorithms, demonstrating its functionality with and without the scoreboard.

* The testbench uses a scoreboard to compare the processor's outputs (register file, memory, and program counter) against a reference model.
The scoreboard reports pass/fail results in `run.log`, confirming correct execution for all test cases.

![With_scb](https://github.com/so1taynguyen/Simple-MIPS32-Hardware-Implementation-with-Python-Assembler/blob/main/images/Result_with_scb.png)

* The processor's behavior can be manually verified by inspecting the waveform (dump.vcd) in GTKWave or SimVision. The same programs were tested, and register/memory outputs were checked against expected values to ensure correct operation.

![Without_scb](https://github.com/so1taynguyen/Simple-MIPS32-Hardware-Implementation-with-Python-Assembler/blob/main/images/Result_waveform.png)

<p align="right">(<a href="#readme-top">Back to top</a>)</p>



<!-- CONTRIBUTING -->
## Contributing

Contributions are welcome to enhance the project. Suggestions include optimizing the assembler, adding new instructions, or improving simulation scripts.

1. Fork the project
2. Create a feature branch
    ```sh
    git checkout -b feature/YourFeatureName
    ```
3. Commit your changes
    ```sh
    git commit -m "Add YourFeatureName"
    ```
4. Push to the branch
    ```sh
    git push origin feature/YourFeatureName
    ```
4. Open a pull request

<p align="right">(<a href="#readme-top">Back to top</a>)</p>



<!-- CONTACT -->
## Contact

[![Instagram](https://img.shields.io/badge/Instagram-%23E4405F.svg?logo=Instagram&logoColor=white)](https://www.instagram.com/_2imlinkk/) [![LinkedIn](https://img.shields.io/badge/LinkedIn-%230077B5.svg?logo=linkedin&logoColor=white)](https://www.linkedin.com/in/linkk-isme/) [![email](https://img.shields.io/badge/Email-D14836?logo=gmail&logoColor=white)](mailto:nguyenvanlinh0702.1922@gmail.com) 

<p align="right">(<a href="#readme-top">Back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/othneildrew/Best-README-Template.svg?style=for-the-badge
[contributors-url]: https://github.com/so1taynguyen/Simple-MIPS32-Hardware-Implementation-with-Python-Assembler/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/so1taynguyen/Simple-MIPS32-Hardware-Implementation-with-Python-Assembler.svg?style=for-the-badge
[forks-url]: https://github.com/so1taynguyen/Simple-MIPS32-Hardware-Implementation-with-Python-Assembler/network/members
[stars-shield]: https://img.shields.io/github/stars/so1taynguyen/Simple-MIPS32-Hardware-Implementation-with-Python-Assembler.svg?style=for-the-badge
[stars-url]: https://github.com/so1taynguyen/Simple-MIPS32-Hardware-Implementation-with-Python-Assembler/stargazers
[issues-shield]: https://img.shields.io/github/issues/so1taynguyen/Simple-MIPS32-Hardware-Implementation-with-Python-Assembler.svg?style=for-the-badge
[issues-url]: https://github.com/so1taynguyen/Simple-MIPS32-Hardware-Implementation-with-Python-Assembler/issues
[license-shield]: https://img.shields.io/github/license/so1taynguyen/Simple-MIPS32-Hardware-Implementation-with-Python-Assembler.svg?style=for-the-badge
[license-url]: https://github.com/so1taynguyen/Simple-MIPS32-Hardware-Implementation-with-Python-Assembler/blob/main/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://www.linkedin.com/in/linkk-isme/