import numpy as np
import matplotlib.pyplot as plt


def gauss2d(x_grid, y_grid, mu_x, mu_y, sigma_x, sigma_y, offset=0, height=1, theta=0):
    """Make a 2-d gaussian

    Parameters
    ----------
    x_grid : array
        X grid over which to define Gaussian
    y_grid : array
        Y grid over which to define Gaussian
    mu_x : scalar
        X mean of Gaussian
    mu_y : scalar
        Y mean of Gaussian
    offset : scalar
        no idea
    height : scalar
        amplitude of gaussian
    theta : scalar 
        angle of Gaussian

    """
    if height is None:
        height = 1 / (2 * np.pi * sigma_x * sigma_y)
    a = np.cos(np.deg2rad(theta))**2/2/sigma_x**2 + np.sin(np.degrees(theta))**2/2/sigma_y**2
    b = -np.sin(np.degrees(2*theta))/4/sigma_x**2 + np.sin(np.degrees(2*theta))/4/sigma_y**2
    c = np.sin(np.degrees(theta))**2/2/sigma_x**2 + np.cos(np.deg2rad(theta))**2/2/sigma_y**2
    g = offset + height * np.exp( -(a * (x_grid - mu_x)**2 + 2 * b * (x_grid - mu_x) * (y_grid - mu_y)  + c * (y_grid - mu_y)**2))
    return g