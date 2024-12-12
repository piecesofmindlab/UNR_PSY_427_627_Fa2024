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
Snd = sound.Sound(os.path.join(fdir, 'horse.wav'))

# Sampling rate
fs = Snd.sampleRate
# Souund wave amplitude 
y = Snd.sndArr.flatten()
# Total time
T = Snd.duration 
# Time (up to )
t = np.arange(0, T, 1/fs)
plt.plot(t, y)

#%% Compute Fourier transform
N = len(y) # number of sample points
T = len(y) / fs # define time of interval
f = np.fft.fft(y) # compute the Fourier transform
mag_orig = np.abs(f) / (N / 2) # take the absolute value of the fft to get the magnitude at each frequency
mag = mag_orig[0:int(np.floor(N/2))] # take the first half of frequencies, since the frequencies repeat!
freq = np.arange(0, (N/2-1)) / T # find the corresponding frequency in Hz 
fig, ax = plt.subplots()
ax.plot(freq[2:], mag[2:], '-')
plt.xlabel("Frequency (Hz)")
plt.ylabel("Magnitude")


## Exercise: Create WINDOWED Fourier transform for a subset of points! 
# We want to take the Fourier transform of e.g. 
window_time = .25; # seconds
window_size_samples = int(np.round(window_time * fs))
Ns = window_size_samples
y_subsample = y[9:window_size_samples]
f_subsample = np.fft.fft(y_subsample) # compute the Fourier transform
mag_subsample_orig = np.abs(f_subsample) / (Ns / 2) # take the absolute value of the fft to get the magnitude at each frequency
mag_subsample = mag_subsample_orig[0:int(np.ceil(Ns/2))] # take the first half of frequencies, since the frequencies repeat!
freq_subsample = np.arange(0, Ns/2) / window_time # find the corresponding frequency in Hz 

fig, ax = plt.subplots()
ax.plot(freq_subsample[2:], mag_subsample[2:], '-')
# Take a different window into the data, from 1 to 1.5 seconds
start_time = 1
start_index = 1 * fs
y_subsample2 = y[start_index:start_index+window_size_samples-1]
f_subsample2 = np.fft.fft(y_subsample2) # compute the Fourier transform
mag_subsample_orig2 = np.abs(f_subsample2) / (Ns / 2) # take the absolute value of the fft to get the magnitude at each frequency
mag_subsample2 = mag_subsample_orig2[0:int(np.ceil(Ns/2))] # take the first half of frequencies, since the frequencies repeat!
ax.plot(freq_subsample[2:], mag_subsample2[2:], '-'); # Index from 2 to skip first frequency (0 Hz); can be problematic
plt.legend(['First 1 s', 'Last 1 s'])
plt.xlabel("Frequency (Hz)")
plt.ylabel("Magnitude")

plt.show()