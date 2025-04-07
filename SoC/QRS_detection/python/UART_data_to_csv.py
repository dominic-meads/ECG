import serial
import csv
import os

os.chdir('C:/Users/demea/ECG/SoC/QRS_detection/Python')

ser = serial.Serial(port='COM10',baudrate=115200)
sample_number = 0

fieldnames = ["FIR_BP_sample", "Moving_Averaged_sample", "Deriv_sample", "peak", "sample_number"]

with open('ECG_data.csv', 'w') as csv_file:
    csv_writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
    csv_writer.writeheader()

# infinite loop except exits when Ctrl+C entered
try:
  while True:

    with open('ECG_data.csv', 'a') as csv_file:
      csv_writer = csv.DictWriter(csv_file, fieldnames=fieldnames)

      # get data from UART 
      raw_serial_byte = ser.readline() # gets data in byte literal
      raw_serial_byte = raw_serial_byte.replace(b'\n', b'')  # remove newline
      raw_str = str(raw_serial_byte,'UTF-8') # convert to unicode string
      raw_list = raw_str.split(",")
      raw_list = list(map(int, raw_list))
      FIR_BP_sample = raw_list[0]
      Moving_Averaged_sample = raw_list[1]
      Deriv_sample = raw_list[2]
      peak_sample = raw_list[3]
      print(FIR_BP_sample)

      info = {
          "FIR_BP_sample": FIR_BP_sample,
          "Moving_Averaged_sample": Moving_Averaged_sample,
          "Deriv_sample": Deriv_sample,
          "peak" : peak_sample,
          "sample_number": sample_number
      }

      csv_writer.writerow(info)

      sample_number += 1
except KeyboardInterrupt:
  pass

print("Program halted")

