# NOTES: Run program in separate dedicated terminal
# sources: https://www.youtube.com/watch?v=Ercd-Ip5PfQ&t=302s

import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
import os

os.chdir('C:/Users/demea/ECG/SoC/Microblaze_AXIS_ECG_to_UART/Microblaze_AXIS_ECG_to_UART/Python')

plt.style.use('fivethirtyeight')


def animate_entire_graph(i):  # plots the entire graph and animates it
    data = pd.read_csv('ECG_data.csv')
    x = data['sample number']
    y = data['value']

    plt.cla()

    plt.plot(x, y, label='ECG Data')

    plt.legend(loc='upper left')
    plt.tight_layout()

try:
  ani = FuncAnimation(plt.gcf(), animate_entire_graph, interval=10)

  plt.tight_layout()
  plt.show()
except KeyboardInterrupt:
  pass

print("Program halted")