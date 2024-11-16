import pandas as pd
import os

# current_directory = os.getcwd()
# print("Current Directory:", current_directory)

os.chdir(r'C:\Users\demea\ECG\SoC\IIR_Bandpass_test\MATLAB scripts')  # cd to where the coefficients are

#current_directory = os.getcwd()
#print("changed Directory:", current_directory)

sos_coeff = pd.read_csv('fixed_point_int_coeff_4th_order_bp.csv')  # read in coeffs
print(sos_coeff)

os.chdir(r'C:\Users\demea\ECG\SoC\IIR_Bandpass_test\Python scripts')  # change back to working directory

coeff_list = ["b0", "b1", "b2", "a1", "a2"]

with open('sos_parameters.txt', 'w') as file:
    for i in range(sos_coeff.shape[0]):
      file.write("// sos" + str(i) + " coeffs\n")
      for j in range(5):
         string = "parameter sos" + str(i) + "_" + coeff_list[j] + "_int_ceoff = " + str(sos_coeff.loc[i][j]) + ","
         file.write(string + "\n")
      file.write("\n")
