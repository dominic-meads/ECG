# uses the data from the Analog front end and converts it to a txt file that the waveforms software can read. 
# numbers must be between -1 and 1 (result in ECG_normalized.txt)
# generates 500 samples that the waveform generator can use to create a test ECG waveform of 60 bpm

import os

os.chdir('C:/Users/demea/ECG/Waveforms')

def remove_every_other_line(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        for index, line in enumerate(infile):
            if index % 2 == 0:
                outfile.write(line)

remove_every_other_line('ECG_data.txt', 'ECG.txt')

# Open the input file in read mode
with open('ECG.txt', 'r') as input_file:
    # Read all lines from the file
    lines = input_file.readlines()

# Create a list to store the divided numbers
divided_numbers = []

# Iterate through each line
for line in lines:
    try:
        # Convert line to a number and divide by 4096
        number = float(line.strip())  # Remove leading/trailing spaces and convert to float
        divided_numbers.append(number / 4096)
    except ValueError:
        # Skip lines that cannot be converted to a number
        print(f"Skipping invalid line: {line.strip()}")

# Open the output file in write mode
with open('ECG_normalized.txt', 'w') as output_file:
    # Write each divided number to the file
    for number in divided_numbers[0:500]:
        output_file.write(f"{number}\n")