% Fourier transform of sound
% Sounds can be downloaded from piecesofmind.psyc.unr.edu/data/animal_sounds.tar.gz; they must be unzipped! 
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