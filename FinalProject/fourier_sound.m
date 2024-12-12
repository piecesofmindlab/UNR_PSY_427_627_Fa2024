% Fourier transform of sound
% Sounds can be downloaded from piecesofmind.psyc.unr.edu/data/animal_sounds.tar.gz; they must be unzipped! 
% NOTE sounds in .wav format have been added, those should be the easiest
% to load
%% Sound directory
sound_dir = '~/Teaching/PSY427_627/datasets/animal_sounds/';
% This loads two critical things: the sound data, and the sound sampling
% frequency (which will tell us how long the sound is, what frequencies we
% can expect)
[y, fs] = audioread(fullfile(sound_dir, 'pig.wav'));
% Define time
t = 1/fs:1/fs:length(y)/fs;
% Plot sound
plot(t, y)
xlabel("Time (s)")
ylabel("Sound amplitude")


%% Compute Fourier transform
N = length(y); % number of sample points
T = length(y) / fs; % define time of interval
f = fft(y); % compute the Fourier transform
mag_orig = abs(f) / (N / 2); % take the absolute value of the fft to get the magnitude at each frequency
mag = mag_orig(1:floor(N/2)); % take the first half of frequencies, since the frequencies repeat!
freq = (0:(N/2-1)) / T; % find the corresponding frequency in Hz 
figure;
plot(freq(2:end), mag(2:end), '-');
xlabel("Frequency (Hz)")
ylabel("Magnitude")


%% Exercise: Create WINDOWED Fourier transform for a subset of points! 
% We want to take the Fourier transform of e.g. 
window_time = .25; % seconds
window_size_samples = round(window_time * fs);
Ns = window_size_samples;
y_subsample = y(1:window_size_samples);
f_subsample = fft(y_subsample); % compute the Fourier transform
mag_subsample_orig = abs(f_subsample) / (Ns / 2); % take the absolute value of the fft to get the magnitude at each frequency
mag_subsample = mag_subsample_orig(1:ceil(Ns/2)); % take the first half of frequencies, since the frequencies repeat!
freq_subsample = (0:(Ns/2-1)) / window_time; % find the corresponding frequency in Hz 
figure;
plot(freq_subsample(2:end), mag_subsample(2:end), '-');
% Take a different window into the data, from 1 to 1.5 seconds
start_time = 1;
start_index = 1 * fs;
y_subsample2 = y(start_index:start_index+window_size_samples-1);
f_subsample2 = fft(y_subsample2); % compute the Fourier transform
mag_subsample_orig2 = abs(f_subsample2) / (Ns / 2); % take the absolute value of the fft to get the magnitude at each frequency
mag_subsample2 = mag_subsample_orig2(1:ceil(Ns/2)); % take the first half of frequencies, since the frequencies repeat!
hold on;
plot(freq_subsample(2:end), mag_subsample2(2:end), '-'); % Index from 2 to skip first frequency (0 Hz); can be problematic
hold off;
legend({'First 1 s', 'Last 1 s'})
xlabel("Frequency (Hz)")
ylabel("Magnitude")
