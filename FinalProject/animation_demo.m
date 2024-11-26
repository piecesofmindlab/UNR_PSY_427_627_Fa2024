%animation demo matlab 

%% Set up grating animation
% Parameters
n_frames = 30;
spatial_frequencies = linspace(1, 10, n_frames);

% Set up video object
obj = VideoWriter('grating_sf_0_matlab','MPEG-4');
open(obj)
% Run loop
for freq = spatial_frequencies
    g = grating(freq, 0);
    imagesc(g, [-1, 1]);
    writeVideo(obj, getframe);
end
% Wrap it up
close(obj)

%% Plot function
close all
n_frames = 60;
x = linspace(0, 2 * pi, n_frames);
freq = 3;
y = sin(freq * x);
% Set up video object
%obj = VideoWriter('grating_sf_0_matlab','MPEG-4');
%open(obj)
plot(x(1), y(1),'.-')
xlim([0, 2*pi]);
ylim([-1,1]);
% Run loop
for frame = 1:n_frames
    h = plot(x(1:frame), y(1:frame), '.-');
    h.LineWidth=3;
    xlim([0, 2*pi]);
    ylim([-1, 1]);
    %writeVideo(obj, getframe);
    pause(.1)
end
% Wrap it up
%close(obj)
