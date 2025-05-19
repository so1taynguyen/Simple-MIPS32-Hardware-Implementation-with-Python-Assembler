import os

register_map = {f"r{i}": i for i in range(32)}

instruction_map = {
    "add": {"opcode": "000000", "funct": "000000", "type": "R"},
    "sub": {"opcode": "000000", "funct": "000001", "type": "R"},
    "inc": {"opcode": "000000", "funct": "000010", "type": "R"},
    "dec": {"opcode": "000000", "funct": "000011", "type": "R"},
    "and": {"opcode": "000000", "funct": "000100", "type": "R"},
    "or": {"opcode": "000000", "funct": "001000", "type": "R"},
    "xor": {"opcode": "000000", "funct": "010000", "type": "R"},
    "not": {"opcode": "000000", "funct": "100000", "type": "R"},
    "sll": {"opcode": "000001", "funct": "000000", "type": "R"},
    "srl": {"opcode": "000001", "funct": "000001", "type": "R"},
    "sra": {"opcode": "000001", "funct": "000010", "type": "R"},
    "slt": {"opcode": "000010", "funct": "000000", "type": "R"},
    "sltu": {"opcode": "000010", "funct": "000001", "type": "R"},
    "seq": {"opcode": "000010", "funct": "000010", "type": "R"},
    "addi": {"opcode": "100000", "type": "I"},
    "subi": {"opcode": "100001", "type": "I"},
    "andi": {"opcode": "100010", "type": "I"},
    "ori": {"opcode": "100011", "type": "I"},
    "xori": {"opcode": "100100", "type": "I"},
    "slti": {"opcode": "100101", "type": "I"},
    "sltiu": {"opcode": "100110", "type": "I"},
    "seqi": {"opcode": "100111", "type": "I"},
    "lw": {"opcode": "101000", "type": "I"},
    "sw": {"opcode": "101001", "type": "I"},
    "beq": {"opcode": "110000", "type": "I"},
    "bne": {"opcode": "110001", "type": "I"},
    "j": {"opcode": "111000", "type": "J"},
}

# Mapping of pseudo-instructions to basic instructions
pseudo_instruction_map = {
    "blt": lambda tokens: [
        f"slt r31, {tokens[1]}, {tokens[2]}",
        f"bne r31, r0, {tokens[3]}"
    ],
    "bgt": lambda tokens: [
        f"slt r31, {tokens[1]}, {tokens[2]}",
        f"seq r30, {tokens[1]}, {tokens[2]}",
        f"or r31, r30, r31",
        f"beq r31, r0, {tokens[3]}"
    ],
    "ble": lambda tokens: [
        f"slt r31, {tokens[1]}, {tokens[2]}",
        f"seq r30, {tokens[1]}, {tokens[2]}",
        f"or r31, r30, r31",
        f"bne r31, r0, {tokens[3]}"
    ],
    "bge": lambda tokens: [
        f"slt r31, {tokens[1]}, {tokens[2]}",
        f"beq r31, r0, {tokens[3]}"
    ],
    "beqz": lambda tokens: [
        f"beq {tokens[1]}, r0, {tokens[2]}"
    ],
    "bnez": lambda tokens: [
        f"bne {tokens[1]}, r0, {tokens[2]}"
    ],
    "abs": lambda tokens: [
        f"sra r31, {tokens[2]}, 31",
        f"xor {tokens[1]}, r31, {tokens[2]}",
        f"sub {tokens[1]}, {tokens[1]}, r31"
    ],
    "neg": lambda tokens: [
        f"sub {tokens[1]}, r0, {tokens[2]}"
    ],
    "li": lambda tokens: [
        f"addi {tokens[1]}, r0, {tokens[2]}"
    ],
}

def to_bin(val, bits):
    """Convert an integer to a binary string with the specified number of bits."""
    if val < 0:
        val = (1 << bits) + val  # Handle negative values with two's complement
    return format(val, f"0{bits}b")

def to_hex(binstr):
    """Convert a binary string to a 32-bit hexadecimal representation."""
    return f"{int(binstr, 2):08x}"

def encode_instruction(instr, current_idx, label_map):
    tokens = instr.replace(",", "").split()
    mnemonic = tokens[0].lower()
    if mnemonic not in instruction_map:
        raise ValueError(f"Unknown instruction: {mnemonic}")
    spec = instruction_map[mnemonic]

    if spec["type"] == "R":
        if mnemonic in ["inc", "dec", "not"]:
            rd = register_map[tokens[1]]
            rs1 = register_map[tokens[2]]
            rs2 = 0
            shamt = 0
        elif mnemonic in ["sll", "srl", "sra"]:
            rd = register_map[tokens[1]]
            rs1 = register_map[tokens[2]]
            shamt = int(tokens[3])
            rs2 = 0
        else:
            rd = register_map[tokens[1]]
            rs1 = register_map[tokens[2]]
            rs2 = register_map[tokens[3]]
            shamt = 0
        opcode = spec["opcode"]
        funct = spec["funct"]
        machine_code = (
            opcode +
            to_bin(rs1, 5) +
            to_bin(rs2, 5) +
            to_bin(rd, 5) +
            to_bin(shamt, 5) +
            funct
        )
    elif spec["type"] == "I":
        if mnemonic in ["lw", "sw"]:
            if mnemonic == "lw":
                rd = register_map[tokens[1]]
                offset_str, rs_str = tokens[2].split("(")
                offset = int(offset_str)
                rs = register_map[rs_str.rstrip(")")]
                imm = offset
            else:
                rs2 = register_map[tokens[1]]
                offset_str, rs1_str = tokens[2].split("(")
                offset = int(offset_str)
                rs1 = register_map[rs1_str.rstrip(")")]
                rd = rs2
                rs = rs1
                imm = offset
        elif mnemonic in ["beq", "bne"]:
            rs = register_map[tokens[1]]
            rt = register_map[tokens[2]]
            label = tokens[3]
            if label not in label_map:
                raise ValueError(f"Label '{label}' not found.")
            offset = label_map[label] - (current_idx + 2)
            imm = offset
            opcode = spec["opcode"]
            machine_code = (
                opcode +
                to_bin(rs, 5) +
                to_bin(rt, 5) +
                to_bin(imm, 16)
            )
            return to_hex(machine_code)
        else:
            rd = register_map[tokens[1]]
            rs = register_map[tokens[2]]
            imm = int(tokens[3])
        opcode = spec["opcode"]
        machine_code = (
            opcode +
            to_bin(rs, 5) +
            to_bin(rd, 5) +
            to_bin(imm, 16)
        )
    elif spec["type"] == "J":
        label = tokens[1]
        if label not in label_map:
            raise ValueError(f"Label '{label}' not found.")
        offset = label_map[label] - (current_idx + 2)
        opcode = spec["opcode"]
        machine_code = (
            opcode +
            to_bin(offset, 26)
        )
        return to_hex(machine_code)
    else:
        raise ValueError(f"Unsupported instruction type for {mnemonic}")

    return to_hex(machine_code)

def read_instructions_from_file(filename):
    """Read assembly instructions from a file, return instructions with original line numbers."""
    with open(filename, "r") as f:
        lines = []
        for line_num, line in enumerate(f, 1):
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            if "#" in line:
                line = line.split("#")[0].strip()
            if line:
                lines.append((line, line_num))
        return lines

def write_hex_to_file(hex_list, filename):
    """Write hexadecimal machine codes to a file."""
    with open(filename, "w") as f:
        for h in hex_list:
            f.write(h + "\n")

def preprocess_labels(instructions):
    """Preprocess labels, track original line numbers, and validate label names."""
    label_map = {}
    cleaned_instructions = []
    line_numbers = []
    valid_mnemonics = set(instruction_map.keys()).union(pseudo_instruction_map.keys())

    for instr, line_num in instructions:
        instr = instr.strip()
        if ':' in instr:
            label = instr.split(':')[0].strip()
            if label in label_map:
                raise ValueError(f"Line {line_num}: Duplicate label '{label}'")
            if label.lower() in valid_mnemonics:
                raise ValueError(f"Line {line_num}: Label '{label}' conflicts with instruction mnemonic")
            if not label:
                raise ValueError(f"Line {line_num}: Empty label name")
            label_map[label] = len(cleaned_instructions)
            if instr.endswith(':'):
                continue
            else:
                instruction = instr.split(':')[1].strip()
                if instruction:
                    cleaned_instructions.append(instruction)
                    line_numbers.append(line_num)
        else:
            cleaned_instructions.append(instr)
            line_numbers.append(line_num)

    return label_map, cleaned_instructions, line_numbers

def check_input_syntax(raw_instructions):
    """Check syntax of input instructions for invalid rd usage (r0, r30, r31)."""
    errors = []
    valid_mnemonics = set(instruction_map.keys()).union(pseudo_instruction_map.keys())
    r_type_3regs = {"add", "sub", "and", "or", "xor", "slt", "sltu", "seq"}
    r_type_2regs = {"inc", "dec", "not"}
    shift_instructions = {"sll", "srl", "sra"}
    i_type = {"addi", "subi", "andi", "ori", "xori", "slti", "sltiu", "seqi"}
    load_store = {"lw", "sw"}
    pseudo_instructions = set(pseudo_instruction_map.keys()) - {"beqz", "bnez", "bgt", "bge", "ble", "blt"}  # Exclude branch pseudo-instructions

    for line, line_num in raw_instructions:
        line = line.strip()
        if ':' in line:
            instruction = line.split(':')[1].strip() if not line.endswith(':') else ''
            if not instruction:
                continue
        else:
            instruction = line

        tokens = instruction.replace(",", "").split()
        if not tokens:
            continue
        mnemonic = tokens[0].lower()

        if mnemonic not in valid_mnemonics:
            errors.append(f"Line {line_num}: Invalid instruction '{mnemonic}'")
            continue

        def validate_register(token, field):
            if not token.startswith("r"):
                return f"Invalid register format '{token}' in {field}"
            try:
                reg_num = int(token[1:])
                if reg_num > 31:
                    return f"Register '{token}' exceeds r31 in {field}"
                if reg_num in {0, 30, 31}:
                    return f"Cannot use r0, r30, or r31 as destination register in {field}"
                if token not in register_map:
                    return f"Invalid register '{token}' in {field}"
            except ValueError:
                return f"Invalid register format '{token}' in {field}"
            return None

        if mnemonic in r_type_3regs or mnemonic in r_type_2regs or mnemonic in shift_instructions or mnemonic in i_type:
            if len(tokens) < 2:
                errors.append(f"Line {line_num}: Too few operands for '{mnemonic}'")
                continue
            rd_error = validate_register(tokens[1], "rd")
            if rd_error:
                errors.append(f"Line {line_num}: {rd_error}")
        elif mnemonic == "lw":
            if len(tokens) < 2:
                errors.append(f"Line {line_num}: Too few operands for 'lw'")
                continue
            rd_error = validate_register(tokens[1], "rd")
            if rd_error:
                errors.append(f"Line {line_num}: {rd_error}")
        elif mnemonic in pseudo_instructions:  # abs, neg, li
            if len(tokens) < 2:
                errors.append(f"Line {line_num}: Too few operands for '{mnemonic}'")
                continue
            rd_error = validate_register(tokens[1], "rd")
            if rd_error:
                errors.append(f"Line {line_num}: {rd_error}")

    return errors

def check_syntax(instructions, line_numbers, label_map):
    """Check syntax of instructions and return list of errors with line numbers."""
    errors = []
    valid_mnemonics = set(instruction_map.keys())
    r_type_3regs = {"add", "sub", "and", "or", "xor", "slt", "sltu", "seq"}
    r_type_2regs = {"inc", "dec", "not"}
    shift_instructions = {"sll", "srl", "sra"}
    i_type = {"addi", "subi", "andi", "ori", "xori", "slti", "sltiu", "seqi"}
    branch_instructions = {"beq", "bne"}
    load_store = {"lw", "sw"}

    for idx, (instr, line_num) in enumerate(zip(instructions, line_numbers)):
        tokens = instr.replace(",", "").split()
        if not tokens:
            errors.append(f"Line {line_num}: Empty instruction")
            continue
        mnemonic = tokens[0].lower()

        if mnemonic not in valid_mnemonics:
            errors.append(f"Line {line_num}: Invalid instruction '{mnemonic}'")
            continue

        # Validate register format and range
        def validate_register(token, field, allow_r0_r30_r31=True):
            if not token.startswith("r"):
                return f"Invalid register format '{token}' in {field}"
            try:
                reg_num = int(token[1:])
                if reg_num > 31:
                    return f"Register '{token}' exceeds r31 in {field}"
                if token not in register_map:
                    return f"Invalid register '{token}' in {field}"
            except ValueError:
                return f"Invalid register format '{token}' in {field}"
            return None

        # Check operand count and format
        if mnemonic in r_type_3regs:
            if len(tokens) != 4:
                errors.append(f"Line {line_num}: Expected 3 registers for '{mnemonic}', got {len(tokens)-1}")
                continue
            rd_error = validate_register(tokens[1], "rd")
            rs1_error = validate_register(tokens[2], "rs1")
            rs2_error = validate_register(tokens[3], "rs2")
            for error in (rd_error, rs1_error, rs2_error):
                if error:
                    errors.append(f"Line {line_num}: {error}")

        elif mnemonic in r_type_2regs:
            if len(tokens) != 3:
                errors.append(f"Line {line_num}: Expected 2 registers for '{mnemonic}', got {len(tokens)-1}")
                continue
            rd_error = validate_register(tokens[1], "rd")
            rs1_error = validate_register(tokens[2], "rs1")
            for error in (rd_error, rs1_error):
                if error:
                    errors.append(f"Line {line_num}: {error}")

        elif mnemonic in shift_instructions:
            if len(tokens) != 4:
                errors.append(f"Line {line_num}: Expected 2 registers and shamt for '{mnemonic}', got {len(tokens)-1}")
                continue
            rd_error = validate_register(tokens[1], "rd")
            rs1_error = validate_register(tokens[2], "rs1")
            try:
                shamt = int(tokens[3])
                if shamt < 0 or shamt > 31:
                    errors.append(f"Line {line_num}: Shift amount '{tokens[3]}' must be 0–31")
            except ValueError:
                errors.append(f"Line {line_num}: Invalid shift amount '{tokens[3]}'")
            if rd_error:
                errors.append(f"Line {line_num}: {rd_error}")
            if rs1_error:
                errors.append(f"Line {line_num}: {rs1_error}")

        elif mnemonic in i_type:
            if len(tokens) != 4:
                errors.append(f"Line {line_num}: Expected 2 registers and immediate for '{mnemonic}', got {len(tokens)-1}")
                continue
            rd_error = validate_register(tokens[1], "rd")
            rs_error = validate_register(tokens[2], "rs")
            try:
                imm = int(tokens[3])
                if imm < -32768 or imm > 32767:
                    errors.append(f"Line {line_num}: Immediate '{tokens[3]}' out of 16-bit range (-32768 to 32767)")
            except ValueError:
                errors.append(f"Line {line_num}: Invalid immediate value '{tokens[3]}'")
            for error in (rd_error, rs_error):
                if error:
                    errors.append(f"Line {line_num}: {error}")

        elif mnemonic in load_store:
            if len(tokens) != 3:
                errors.append(f"Line {line_num}: Expected register and offset(base) for '{mnemonic}', got {len(tokens)-1}")
                continue
            reg = tokens[1]
            mem_ref = tokens[2]
            if not (mem_ref.startswith("-") or mem_ref[0].isdigit()) or "(" not in mem_ref or not mem_ref.endswith(")"):
                errors.append(f"Line {line_num}: Invalid memory reference '{mem_ref}', expected offset(base)")
                continue
            try:
                offset_str, base_str = mem_ref.split("(")
                offset = int(offset_str) if offset_str else 0
                base_reg = base_str.rstrip(")")
                if offset < -32768 or offset > 32767:
                    errors.append(f"Line {line_num}: Offset '{offset_str}' out of 16-bit range (-32768 to 32767)")
            except ValueError:
                errors.append(f"Line {line_num}: Invalid offset '{offset_str}'")
                continue
            reg_error = validate_register(reg, "rd" if mnemonic == "lw" else "rs2")
            base_error = validate_register(base_reg, "base")
            for error in (reg_error, base_error):
                if error:
                    errors.append(f"Line {line_num}: {error}")

        elif mnemonic in branch_instructions:
            if len(tokens) != 4:
                errors.append(f"Line {line_num}: Expected 2 registers and label for '{mnemonic}', got {len(tokens)-1}")
                continue
            rs_error = validate_register(tokens[1], "rs")
            rt_error = validate_register(tokens[2], "rt")
            label = tokens[3]
            if label not in label_map:
                errors.append(f"Line {line_num}: Label '{label}' not found")
            for error in (rs_error, rt_error):
                if error:
                    errors.append(f"Line {line_num}: {error}")

        elif mnemonic == "j":
            if len(tokens) != 2:
                errors.append(f"Line {line_num}: Expected label for 'j', got {len(tokens)-1} operands")
                continue
            label = tokens[1]
            if label not in label_map:
                errors.append(f"Line {line_num}: Label '{label}' not found")

    return errors

def preprocess_pseudo_instructions(raw_instructions, temp_file):
    """Expand pseudo-instructions into basic instructions and write to temp file."""
    expanded_instructions = []
    for line, line_num in raw_instructions:
        line = line.strip()
        if ':' in line:
            label = line.split(':')[0]
            instruction = line.split(':')[1].strip() if not line.endswith(':') else ''
            if instruction:
                tokens = instruction.replace(",", "").split()
                mnemonic = tokens[0].lower()
                if mnemonic in pseudo_instruction_map:
                    expanded = pseudo_instruction_map[mnemonic](tokens)
                    expanded_instructions.extend((instr, line_num) for instr in expanded)
                else:
                    expanded_instructions.append((instruction, line_num))
            if line.endswith(':'):
                expanded_instructions.append((line, line_num))  # Preserve label
        else:
            tokens = line.replace(",", "").split()
            mnemonic = tokens[0].lower()
            if mnemonic in pseudo_instruction_map:
                expanded = pseudo_instruction_map[mnemonic](tokens)
                expanded_instructions.extend((instr, line_num) for instr in expanded)
            else:
                expanded_instructions.append((line, line_num))
    
    # Write expanded instructions to temp file
    with open(temp_file, "w") as f:
        for instr, _ in expanded_instructions:
            f.write(instr + "\n")
    
    return expanded_instructions
    
if __name__ == "__main__":
    input_file = "./input_instr.txt"
    temp_file = "./temp.txt"
    output_file = "../include/imem_data.mem"
    
    try:
        # Read raw instructions with line numbers
        raw_instructions = read_instructions_from_file(input_file)
        # Check syntax of input file for r0, r30, r31 in rd
        input_errors = check_input_syntax(raw_instructions)
        # Preprocess pseudo-instructions and write to temp file
        expanded_instructions = preprocess_pseudo_instructions(raw_instructions, temp_file)
        # Read from temp file for conversion
        raw_instructions = read_instructions_from_file(temp_file)
        # Preprocess labels and get line numbers
        label_map, instructions, line_numbers = preprocess_labels(expanded_instructions)
        # Check syntax of expanded instructions
        syntax_errors = check_syntax(instructions, line_numbers, label_map)
        # Combine errors
        errors = input_errors + syntax_errors
        if errors:
            print("❌ Syntax errors found:")
            for error in errors:
                print(error)
            open(output_file, "w").close()  # Clear output file if errors found
            os.remove(temp_file)
            exit(1)
        # Encode instructions
        hex_codes = [encode_instruction(instr, idx, label_map) for idx, instr in enumerate(instructions)]
        write_hex_to_file(hex_codes, output_file)
        os.remove(temp_file)
        print(f"✅ Successfully converted {len(hex_codes)} instructions to machine code (HEX format) → {output_file}")
    except Exception as e:
        print(f"❌ Error: {e}")
        if os.path.exists(temp_file):
            os.remove(temp_file)
        open(output_file, "w").close()  # Clear output file on any exception