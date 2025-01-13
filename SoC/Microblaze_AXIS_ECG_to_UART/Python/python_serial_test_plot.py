# NOTES: Run program in separate dedicated terminal
# sources: https://www.youtube.com/watch?v=Ercd-Ip5PfQ&t=302s

import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
import os

os.chdir('C:/Users/demea/ECG/SoC/Microblaze_AXIS_ECG_to_UART/Python')

plt.style.use('fivethirtyeight')

def animate_entire_graph(i):  # plots the entire graph and animates it
    data = pd.read_csv('ECG_data.csv')
    x = data['sample number']
    y = data['value']

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

    plt.cla()

    plt.plot(t, v*1000, linewidth=1.0)
    plt.xlabel('Time (s)')
    plt.ylabel('ECG Amplitude (mV)')
    plt.title('ECG (Lead I)')
    plt.ylim(-2,2)
    plt.legend(loc='upper left')

try:
  ani = FuncAnimation(plt.gcf(), animate_entire_graph, interval=10)

  plt.grid()
  plt.show()
except KeyboardInterrupt:
  pass

print("Program halted")