import os
import pandas as pd

os.chdir(r'C:\Users\demea\ECG\SoC\FIR_bp_test\MATLAB')

file1 = open("coeff.txt","r")
coeffs = file1.readlines()

# strip newline characters
j=0
for i in coeffs:
    coeffs[j]=i.rstrip("\n")
    j+=1

with open('coeff_parameters.txt', 'w') as file:
  file.write("--------------VERILOG CODE GENERATION--------------\n")

  file.write("\n\n\n--------------parameters for module--------------\n")
  for i in range(len(coeffs)):
    string = "parameter b" + str(i) + "_coeff = " + coeffs[i] + ','
    file.write(string + '\n')

  file.write("\n\n\n--------------localparams for module instantiation--------------\n")
  for i in range(len(coeffs)):
    string = "localparam b" + str(i) + "_coeff = " + coeffs[i] + ';'
    file.write(string + '\n')

  file.write("\n\n\n--------------Registers within module--------------\n")
  for i in range(len(coeffs)):
    string = "reg signed [coeff_width-1:0] r_b" + str(i) + "_coeff = b" + str(i) + "_coeff;"
    file.write(string + '\n')

  file.write("\n\n\n--------------module instantiation template for parameters--------------\n")
  for i in range(len(coeffs)):
    string = ".b" + str(i) + "_coeff(" + "b" + str(i) + "_coeff" + "),"
    file.write(string + "\n")

  file.write("\n\n\n--------------register updates--------------\n")
  for i in range(len(coeffs)):
    string = "r_x_z" + str(i+1) + " <= r_x_z" + str(i) + ';'
    file.write(string + "\n")
  file.write("\n")
  for i in range(len(coeffs)):
    string = "r_x_z" + str(i+1) + " <= 0;"
    file.write(string + "\n")

  file.write("\n\n\n--------------multiplication assignments--------------\n")
  for i in range(len(coeffs)):
    string = "assign w_prod_b" + str(i) + " = r_x_z" + str(i) + " * b" + str(i) + "_coeff;"
    file.write(string + "\n")

  file.write("\n\n\n--------------summation --------------\n")
  for i in range(len(coeffs)):
    string = "w_prod_b" + str(i) + " + "
    file.write(string)

  file.write("\n\n\n-------------- COE vector --------------\n")
  for i in range(len(coeffs)):
    string = coeffs[i] + ", "
    file.write(string)