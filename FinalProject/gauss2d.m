function g = gauss2d(x_grid, y_grid, mu_x, mu_y, sigma_x, sigma_y, offset, height, theta)
% Usage: g = gauss2d(x_grid, y_grid [, mu_x] [, mu_y] [, sigma_x] [, sigma_y] [, offset] [, height] [, theta])
% 
% Parameters
% ----------
% x_grid : array
%     X grid over which to define Gaussian
% y_grid : array
%     Y grid over which to define Gaussian
% mu_x : scalar
%     X mean of Gaussian
% mu_y : scalar
%     Y mean of Gaussian
% offset : scalar
%     no idea
% height : scalar
%     amplitude of gaussian
% theta : scalar 
%     angle of Gaussian

if ~exist('mu_x', 'var')
    mu_x = 0;
end
if ~exist('mu_y', 'var')
    mu_y = 0;
end
if ~exist('sigma_x', 'var')
    sigma_x = 1;
end
if ~exist('sigma_y', 'var')
    sigma_y = 1;
end
if ~exist('offset', 'var')
    offset = 0;
end
if ~exist('theta','var')
    theta = 0;
end
if ~exist('height', 'var')
    height = 1;
end

if isnan(height)
    height = 1 / (2 * pi * sigma_x * sigma_y);
end

a = cos(deg2rad(theta)).^2/2/sigma_x.^2 + sin(deg2rad(theta)).^2/2/sigma_y.^2;
b = -sin(deg2rad(2*theta))/4/sigma_x.^2 + sin(deg2rad(2*theta))/4/sigma_y.^2;
c = sin(deg2rad(theta)).^2/2/sigma_x.^2 + cos(deg2rad(theta)).^2/2/sigma_y.^2;
g = offset + height * exp( -(a * (x_grid - mu_x).^2 + 2 * b * (x_grid - mu_x) * (y_grid - mu_y)  + c * (y_grid - mu_y).^2));
