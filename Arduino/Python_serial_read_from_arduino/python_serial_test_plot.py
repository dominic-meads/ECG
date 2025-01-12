# NOTES: Run program in separate dedicated terminal
# sources: https://www.youtube.com/watch?v=Ercd-Ip5PfQ&t=302s

import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
import os

os.chdir('C:/Users/demea/ECG/Arduino/Python_serial_read_from_arduino')

plt.style.use('fivethirtyeight')


def animate_entire_graph(i):  # plots the entire graph and animates it
    data = pd.read_csv('arduino_data.csv')
    x = data['sample number']
    y = data['value']

    plt.cla()

    plt.plot(x, y, label='Arduino Data')

    plt.legend(loc='upper left')
    plt.tight_layout()

try:
  ani = FuncAnimation(plt.gcf(), animate_entire_graph, interval=10)

  plt.tight_layout()
  plt.show()
except KeyboardInterrupt:
  pass

print("Program halted")