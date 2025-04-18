# tests static graph of a 1000 sample window of the ECG signal

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
import os

os.chdir('C:/Users/demea/ECG/SoC/QRS_detection/Python')


#plt.style.use('fivethirtyeight')

data = pd.read_csv('ECG_data.csv')
x = data["sample_number"][-1000:]
y = data["FIR_BP_sample"][-1000:]
p = data["peak"][-1000:]

# convert data from integer to voltage (result should be in mV)
vref = 3.12                # reference voltage from ADC
v_common_mode = 1.5        # common mode voltage offset from 50-60 Hz
v = (y/4095) * (vref)       
v -= v_common_mode         # remove common mode offset

# convert sample number to time
fs = 500  # sampling frequency
Ts = 1/fs # sampling period
t = x*Ts  # actual time

# find non-zero elements of peak array
ind = [i for i, val in enumerate(p) if val != 0]  # find non-zero instances
ind_arr = np.array(ind)  # create an array
ind_arr -= 1000  # since in the animate function we are looking at the past 1000 samples, subtract 1000 samples
last_index = int(y.index[-1]) # get the current last index in the csv file
ind_arr += last_index # add the last index in the series to get the correct peak indexes
print(ind_arr) 

plt.cla()

plt.scatter(t[ind_arr], v[ind_arr], color='red', marker='o')
plt.plot(t, v, linewidth=1.0)
plt.xlabel('Time (s)')
plt.ylabel('ECG Amplitude (mV)')
plt.title('ECG (Lead I)')
plt.ylim(-2,2)
#plt.legend(loc='upper left')



plt.grid()
plt.show()
