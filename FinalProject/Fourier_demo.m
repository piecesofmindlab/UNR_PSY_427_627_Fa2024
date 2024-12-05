% Fourier demo

%% Summing sine waves
% Combinations of sine and cosine waves can model arbitrary signals (the more frequencies considered, the more 
% accurate the approximation of the signal)
n = 100;
x = linspace(0, 1, n);

% Define squarewave
y = ones(1, n) * 0.5;
y(2:50) = 1;
y(50:end) = 0;

disp('Approximating a square wave');
figure;
n_ = 6;
Ns = round(logspace(log10(2), log10(64), 6));
for idx = 1:n_
    N = Ns(idx)
    f = ones(1, 100) * 0.5;
    for i = 1:2:N
        a = 2 / pi / i;
        f = f + a * sin(2 * pi * i * x);
    end
    
    subplot(2, 3, idx);
    plot(x, y, 'Color', [1, 0.647, 0]); % orange
    hold on;
    plot(x, f, '--', 'Color', 'k');
    title(sprintf('%0.0f sine waves', N));
end
tight_layout();

%% Taking Fourier transform 
figure;

% Generate and plot simple frequency signal
T = 1.0; % define time of interval, for simplicity 1 second, but this will work with other (integer) durations
fs = 1000; % Sampling frequency
N = fs * T; % number of points (frequency * time)

signal_freq = [6, 28];
values = [2, 6.2];
t = linspace(0, 1, N) * T;
f = zeros(1, length(t));
for k = 1:length(signal_freq)
    f = f + sin(2 * pi * signal_freq(k) * t) * values(k);
end
% Add noise
f = f + randn(size(f));
subplot(2, 1, 1);
plot(t, f);
xlabel('Time (s)');

% Show Fourier transform
p_orig = abs(fft(f)) / (N / 2); % absolute value of the fft 
p = p_orig(1:ceil(N/2)); % take the power of positive freq. half 
freq = (0:(N/2-1)) / T; % find the corresponding frequency in Hz 
subplot(2, 1, 2);
plot(freq, p, '.-');
xlim([0 30]);
xticks(0:30);
grid on;
xlabel('Frequency (cycles / second)');
tight_layout();

%% Many shapes of signals for one-dimensional Fourier transforms
max_freq = 20; % For fft frequency plots

N = 500; % samples in signal
T = 2.0; % seconds
t = linspace(0, 1, N) * T; % define time in seconds 
signals = cell(1, 5);

% Simple frequency
tmp = sin(2 * pi * 10 * t) + 2.3 * sin(2 * pi * 2 * t);
signals{1} = tmp;

% Simple frequency + noise
noise_std = 1.5;
signals{2} = signals{1} + randn(size(signals{1})) * noise_std;

% Square wave
tmp = zeros(size(signals{1}));
st = floor(N * 0.333) + 1;
fin = ceil(N * 0.666);
middle_third_n = fin - st + 1;
tmp(st:fin) = 1;
signals{3} = tmp;

% Ramp
tmp = zeros(size(signals{1}));
tmp(st:fin) = linspace(0, 1, middle_third_n);
signals{4} = tmp;

% Triangle
tmp = zeros(size(signals{1}));
tmp(st:fin) = [linspace(0, 1, floor(middle_third_n/2)), linspace(1, 0, ceil(middle_third_n/2))];
signals{5} = tmp;

ylims = {[-5, 5], [-5, 5], [-1, 2], [-1, 2], [-1, 2]}; % y limits for the signals
figure;
sgtitle('1-D Fourier Transforms', 'FontSize', 16);
do_title = true;
tick_ct = 0;

for idx = 1:length(signals)
    signal = signals{idx};
    ff = abs(fft(signal)) / (N / 2); % absolute value of the fft 
    p = ff(1:ceil(N/2)).^2; % take the power of positive freq. half 
    freq = (0:ceil(N/2)-1) / T; % find the corresponding frequency in Hz 
    
    subplot(5, 2, (idx-1)*2 + 1);
    plot(t, signal);
    ylim(ylims{idx});
    if do_title
        title('Original signal');
        do_title = false;
    end
    
    % Fourier transform
    subplot(5, 2, (idx-1)*2 + 2);
    frequency_cutoff = sum(freq <= max_freq);
    plot(freq(1:frequency_cutoff), ff(1:frequency_cutoff), '.-');
    grid on;
    xlabel('Frequency (Hz)');
    if tick_ct < 5
        set(gca, 'XTickLabel', []);
    else
        xlabel('Frequency (Hz)');
    end
    tick_ct = tick_ct + 1;
end
