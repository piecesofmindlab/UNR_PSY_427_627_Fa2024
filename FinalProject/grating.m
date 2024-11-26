function g = grating(f, orientation, phi, size)
%% Make a grating
%f = 1/Sz; %0.01; (at 100) - % normalized frequency (1=Nyquest)
if ~exist('orientation','var')
    orientation = 30;
end
if ~exist('size','var')
    size = 101;
end
if ~exist('phi','var')
    phi = 0;
end
t = linspace(-pi, pi, size);
[x, y] = meshgrid(t, t);

theta = deg2rad(orientation); % orientation / 180 * pi
a = cos(theta);	
b = sin(theta);	
g = cos(f * (b * x + a * y) + phi);

%sigma = Sz /2 ; %50
%Gauss1 = 1/pi/sigma^2*exp(-(x.^2+y.^2)/sigma^2);
%Gabor = Gauss1.*Sine1;
