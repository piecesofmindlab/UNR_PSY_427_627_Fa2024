# Fourier sound demo
# Sounds can be downloaded from piecesofmind.psyc.unr.edu/data/animal_sounds.tar.gz; they must be unzipped! 
#%% Imports
from psychopy import sound
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import animation 
import os

#%% Load sound
fdir = '/Users/mark/Teaching/PSY427_627/datasets/animal_sounds/'
Snd = sound.Sound(os.path.join(fdir, 'horse.mp3'))

fs = Snd.sampleRate
y = Snd.sndArr.flatten()
t = np.arange(0, Snd.duration, 1/fs)
plt.plot(t, y)