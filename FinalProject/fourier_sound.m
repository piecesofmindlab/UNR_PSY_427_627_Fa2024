% Fourier transform of sound

%% Sound directory
sound_dir = '~/Teaching/PSY427_627/datasets/animal_sounds/';
% This loads two critical things: the sound data, and the sound sampling
% frequency (which will tell us how long the sound is, what frequencies we
% can expect)
[y, fs] = audioread(fullfile(sound_dir, 'horse.mp3'));
% Define time
t = 1/fs:1/fs:length(y)/fs;
% Plot sound
plot(t, y)

%% Compute Fourier transform

% Exercise: Create WINDOWED Fourier transform! 