# ECG offset notes (pg.2) https://www.ti.com/lit/an/sbaa160a/sbaa160a.pdf
# prototyping script fto test formatting before implementing real-time graphing

import os
import pandas as pd
import matplotlib.pyplot as plt

os.chdir('C:/Users/demea/ECG/Python Graphing')

data = pd.read_csv('ECG_segment.csv')
x = data['Sample']
y = data['Data']

# convert data from integer to voltage (result should be in mV)
vref = 3.12                # reference voltage from ADC
v_common_mode = 1.5        # common mode voltage offset from 50-60 Hz
gain = 950                 # ECG gain from analog front-end
v = (y/4095) * (vref)       
v -= v_common_mode         # remove common mode offset
v /= gain                  # remove gain of opamp stage in front-end

# convert sample number to time
fs = 500  # sampling frequency
Ts = 1/fs # sampling period
t = x*Ts  # actual time

# plot
plt.plot(t, v*1000, linewidth=1.0)
plt.xlabel('Time (s)')
plt.ylabel('ECG Amplitude (mV)')
plt.title('ECG (Lead I)')
plt.minorticks_on()
plt.grid()
plt.show()