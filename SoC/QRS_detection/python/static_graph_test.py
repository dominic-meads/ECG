# tests static graph of a 1000 sample window of the ECG signal

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
import os

os.chdir('C:/Users/demea/ECG/SoC/QRS_detection/Python')


plt.style.use('dark_background')

time_window_sec = 3 # length in time of graph window
fs = 500  # sampling frequency
window_samples = time_window_sec * fs

data = pd.read_csv('ECG_data.csv')
x = data["sample_number"][-window_samples:]
y = data["FIR_BP_sample"][-window_samples:]
p = data["peak"][-window_samples:]

# convert data from integer to voltage (result should be in mV)
vref = 3.12                # reference voltage from ADC
v_common_mode = 1.5        # common mode voltage offset from 50-60 Hz
v = (y/4095) * (vref)       
v -= v_common_mode         # remove common mode offset

# convert sample number to time
Ts = 1/fs # sampling period
t = x*Ts  # actual time

# find non-zero elements of peak array
ind = [i for i, val in enumerate(p) if val != 0]  # find non-zero instances
ind_arr_temp = np.array(ind)  # create an array

# REMOVE DOUBLE DETECTED PEAKS (FIX IN SOFTWARE)
temp = ind_arr_temp[::2]

ind_arr = temp - window_samples  # since in the animate function we are looking at the past 1000 samples, subtract 1000 samples
last_index = int(y.index[-1]) # get the current last index in the csv file
ind_arr += last_index # add the last index in the series to get the correct peak indexes

# get real time bpm (averaged over time window)
num_peaks = temp.size
print(temp)
p_to_p_samples_avg = 0
for peak in range(num_peaks-1) :
  p_to_p_samples_avg += temp[peak+1] -  temp[peak]
p_to_p_samples_avg /= (num_peaks-1) # although there are num_peaks, there are num_peaks-1 sum operations in the loop above
bpm_hz = p_to_p_samples_avg / fs # get frequency of peak interval
bpm = 60 * bpm_hz # convert to beats per min
bpm_str = "%0.2f" % (bpm,) + " BPM" # print two decimal places only and convert to string for graph

plt.cla()

plt.scatter(t[ind_arr], v[ind_arr], color='red', marker='s')
plt.plot(t, v, linewidth=1.5, color = "#68F702")  #plot in neon green
plt.xlabel('Time (s)')
plt.ylabel('ECG Amplitude (mV)')
plt.title('ECG (Lead I)')
plt.ylim(-2,2)
plt.autoscale(enable=True, axis='x', tight=True) # make a tight x-axis
plt.figtext(.7, .8, bpm_str, color = "#68F702", size=18, ha="center", va="center",
         bbox=dict(boxstyle="round",
                   ec=(0.5, 0.5, 0.5),
                   fc=(0.5, 0.5, 0.5),
                   )
            ) # add plot text




plt.grid(color="#E8E8E7", linestyle='-', linewidth=0.5)
plt.show()
