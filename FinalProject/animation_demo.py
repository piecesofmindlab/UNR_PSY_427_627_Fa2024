#%% imports
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import animation 


#%% Set up plot for image animation 

def grating(size, freq=10, ori=0, phi=0):
    """Make a grating image.

    Parameters
    ----------
    size : scalar or tuple (size)
        Size of grating (in pixels, optionally (x, y) diff sizes)
    freq : scalar
        Frequency of grating in cycles/image
    ori : scalar
        Orientation of grating in degrees
    phi : scalar
        Phase of grating in radians
    """
    if isinstance(size, (list, tuple)):
        xd, yd = size
    else:
        xd = yd = size
    x, y = np.meshgrid(np.linspace(-np.pi, np.pi, xd), np.linspace(-np.pi, np.pi, yd))
    theta = np.radians(ori)
    a = np.cos(theta)
    b = np.sin(theta)
    grat = np.cos(freq * (a * -x + b * y) + phi)
    return grat

#%% Set up plot for grating 
# animation function. This is called sequentially
n_frames = 30
size = 101
fps = 30
spatial_frequencies = np.linspace(1, 10, n_frames)

fig, axs = plt.subplots(figsize=(5,5), )
im = axs.imshow(grating(size, spatial_frequencies[0]))
gg = [grating(size, freq=spatial_frequencies[i]) for i in range(n_frames)]

# Define update function (to change the plot on each frame)
def grating_anim(i):
    im.set_array(gg[i])
    return (im,)

def init_grating():
    # Initial frame
    im.set_array(np.zeros((size,size)))
    return (im,)

# call the animator. blit=True means only re-draw the parts that have changed.
anim_grating = animation.FuncAnimation(fig, grating_anim,
                                       init_func=init_grating, 
                                       frames=n_frames,
                                       interval=1/fps * 1000,
                                       blit=False)
anim_grating.save('grating_sf_0.mp4', writer='ffmpeg')


#%% Set up plot for function animation 

fig, ax = plt.subplots()
res = 101
xx = np.linspace(0, 2 * np.pi, res)
freq = 3
yy = np.sin(freq * xx)

#scat 
scat = ax.scatter(xx[0], yy[0], c="b", s=5, label=f'sin(x)')
ax.set(xlim=[0, 2*np.pi], ylim=[-1.3, 1.3], xlabel='X', ylabel='Y')
ax.legend()

#%% Define update function 
def update(frame):
    # for each frame, update the data stored on each artist.
    x = xx[:frame]
    y = yy[:frame]
    # update the scatter plot:
    data = np.stack([x, y]).T
    scat.set_offsets(data)
    return (scat,)


ani = animation.FuncAnimation(fig=fig, func=update, frames=301, interval=30)
plt.show()
