import serial
import csv
import os

os.chdir('C:/Users/demea/ECG/Arduino/Python_serial_read_from_arduino')

ser = serial.Serial(port='COM8',baudrate=9600)
sample_number = 0

fieldnames = ["value", "sample number"]

with open('arduino_data.csv', 'w') as csv_file:
    csv_writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
    csv_writer.writeheader()

# infinite loop except exits when Ctrl+C entered
try:
  while True:

    with open('arduino_data.csv', 'a') as csv_file:
      csv_writer = csv.DictWriter(csv_file, fieldnames=fieldnames)

      # get data from UART 
      raw_serial_byte = ser.readline() # gets data in byte literal
      value_byte_literal = raw_serial_byte.replace(b'\n', b'')  # remove newline
      value_str = str(value_byte_literal,'UTF-8') # convert to string
      value_int = int(value_str) # convert to int
      print(value_int)

      info = {
          "value": value_int,
          "sample number": sample_number
      }

      csv_writer.writerow(info)

      sample_number += 1
except KeyboardInterrupt:
  pass

print("Program halted")

