import random

# Generate 1000 random hex values in the range 0 to 0xFFFF
hex_values = [f"{random.randint(0, 0xFFFFFFFF):08x}" for _ in range(1024)]

# Write the values to a file, 10 per line for readability
with open("../include/dmem_data.mem", "w") as file:
    file.write("\n".join(hex_values))

print("✅ Generated 1024 random hex values and saved to dmem_data.mem")
