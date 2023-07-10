import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

dataset1 = pd.read_csv('simple_blanket_heat_transfer_out_tritium0_tritium_y_0001.csv')
df1 = pd.DataFrame(dataset1)
cols = [1,3]
df1 = df1[df1.columns[cols]]

d = df1["y"]*100
tritium = df1["tritium"]

fs = 18
lw = 2

plt.figure(figsize = (10,8), dpi =300)
plt.plot(d, tritium, color = 'black', linewidth = lw)
plt.grid()
plt.xticks(fontsize = fs)
plt.yticks(fontsize = fs)
plt.xlabel('Distance from first wall (cm)', fontsize = fs)
plt.ylabel('Tritium Concentration (mols)', fontsize = fs)
plt.tight_layout()
plt.savefig('tritium' + '.png', format = 'png', dpi = 300)