# Run experiment

from psychopy import visual, core, event
import matplotlib.pyplot as plt
import numpy as np
import pathlib
import datetime

def plot_timing(timing, hist_bounds=.1, hist_bins=15):
    image_time = np.array([x['image_shown'] for x in timing])
    print("Mean and std of image time:")
    print(f'{np.mean(image_time):0.5f}, {np.std(image_time):0.5f}')
    fig, axs = plt.subplots()
    mm = np.mean(image_time)
    bins = np.linspace(mm-hist_bounds, mm+hist_bounds, hist_bins)
    axs.hist(np.array(image_time), bins=bins)

def get_response(deadline, key_list, responses, quit_keys=['escape','q'], delta=0.001):
    """Get response to any key in `key_list` and return control by `deadline`
    
    Parameters
    ----------
    deadline : scaler
        clock time by which to stop checking for responses
    key_list : list of strings
        list of keys for which to check for responses (note that 
        `quit_keys` are added to this list)
    responses : dict
        dict of params to record per response
    quit_keys : list of stirngs
        list of keys allowable for quit (which raises an error)
    delta : scalar float
        time before deadline to stop checking for responses (allows a small
        increment of time BEFORE `deadline`, such that control is definitely
        relinquished by `deadline`)
    """
    keys_out = []
    while core.getTime() < (deadline-delta):
        max_wait_time = (deadline-delta) - core.getTime()
        key_out = event.waitKeys(keyList=key_list, maxWait=max_wait_time, timeStamped=True)
        if key_out is not None:
            print('')
            print(key_out)
            print('')
            if any([k[0] in quit_keys for k in key_out]):
                raise Exception('Manual quit!')
            else:
                keys_out.extend(key_out)
                pressed, key_time = key_out[0]
                print(f'pressed {pressed}, at {key_time})')
    for resp in keys_out:
        pressed, key_time = resp
        this_response = dict(rt=key_time-time_from,
                                rt_absolute=key_time-t0,
                                trial=itrial,
                                block_number=block_number,
                                key_pressed=pressed,
                                )
        for key, value in this_response.items():
            responses[key].append(value)
    return responses

# Subject specific
subject_number = 1
fullscreen = False # false for debugging, True to run if not on Mac
fullscreen_size = [600,600] # [1440, 900] # For mac retina 12" laptop,  may need to change for you! 
# Parameters
screenFps = 60
ifi = 1 / screenFps
deadline_pct = 0.1 # percent of a screen refresh interval by which 
while_loop_delta = 0.001 # 1 ms, time ahead of flip deadline by which to return control in response collection
image_size = [500,500]
text_color = [255, 255, 255]
fixation_color = [255, 235, 0] # a nice yellow
fixation_size = 12 # pixels
screen_color = [128,128,128]
if fullscreen:
    screen_size = []
else:
    screen_size = fullscreen_size
# Instructions
instructions_choice = 'Please press the button you want to use to respond'
quit_keys = ['escape', 'q']
instructions = '\n'.join([
                'In this experiment, you will see images of',
                'faces, places, bodies, objects, and text,',
                'along with scrambled images.'
                '',
                'As you watch the images go by, please press',
                'the response key as fast as you can if you see',
                'a repeated image.',
                '',
                '(Press any key to continue)'])
# File to save
date = datetime.datetime.now()
datestr = date.strftime('%Y_%m_%d_%H_%M')
sfile = f'subject{subject_number:02d}_{datestr}.npz'
# Load `trials` variable
trial_plan_file = pathlib.Path(f'subject{subject_number:02d}_plan.npz')
if not trial_plan_file.exists():
    raise ValueError('Trial plan file does not exist! Please run ')
trial_plan = np.load(trial_plan_file)
trials = trial_plan['trials']
nTrials = len(trials)
# image_folder = pathlib.Path('~/Teaching/PSY427_627/datasets/fLoc_stimuli_resized/').expanduser()
if 'image_folder' in trial_plan:
    image_folder = pathlib.Path(str(trial_plan['image_folder']))
else:
    image_folder = pathlib.Path('~/Teaching/PSY427_627/datasets/fLoc_stimuli_resized/').expanduser()
    print(f'No image_folder specified in trial file, choosing default image folder:\n{str(image_folder)})')
if not image_folder.exists():
    raise ValueError((f'image folder {image_folder} does not exist!\n'
                       'please update code or set FLOC_FOLDER environment variable'))
# preallocate responses
fields = ['key_pressed', 'rt', 'rt_absolute', 'block_number', 'trial']
responses = dict((f, []) for f in fields)
timing = []
# try / catch around opening screen
try:
    # Open window with default settings:
    win = visual.Window(size=screen_size, 
                        color=(0.5,0.5,0.5),
                        fullscr=fullscreen, 
                        units='pix')
    # Choose response key
    button_choice_message = visual.TextStim(win, text=instructions_choice, color=text_color)
    button_choice_message.draw()
    win.flip()
    core.wait(.2)
    resp_key = 'escape'
    while resp_key in quit_keys:
        key_out = event.waitKeys(maxWait=20)
        if key_out is None:
            raise ValueError('Timed out waiting for response!')
        if len(key_out) >= 0:
            resp_key = key_out[0]
    button_chosen_message = visual.TextStim(win, text=f'You chose "{resp_key}" - moving on!', color=text_color)
    key_list = quit_keys + [resp_key]
    button_chosen_message.draw()
    win.flip()
    core.wait(1)
    # Draw instructions 
    instruction_message = visual.TextStim(win, text=instructions, color=text_color)
    instruction_message.draw()
    win.flip()
    _ = event.waitKeys(maxWait=20)
    # Set up fixation 
    fixation = visual.Circle(win, radius=fixation_size,
                          units='pix',
                          fillColor=fixation_color,
                          pos=(0,0))
    fixation.draw()
    # Start timing 
    t0x = win.flip()
    t0 = core.getTime()
    time_from = t0
    # Load first image
    next_img_name, _, _, _, _ = trials[0]
    image_file = str(image_folder / next_img_name)
    img = visual.ImageStim(win, image=image_file, units='pix', size=image_size)
    for itrial, trial in enumerate(trials): 
        img_name, onset_time, offset_time, is_target, block_number = trial
        draw_start = core.getTime()
        # Draw image texture
        img.draw()
        # Draw fixation
        fixation.draw()
        draw_done = core.getTime()
        # Use any remaining time before presentation deadline to check for response keys
        deadline_onset = (t0 + float(onset_time) - deadline_pct * ifi)
        responses = get_response(deadline_onset, key_list, responses, quit_keys=quit_keys, delta=while_loop_delta)        
        first_resp_loop_done = core.getTime()
        flip_onset_flip = win.flip()
        flip_onset = core.getTime() # Don't trust flip timing (?)
        if is_target=='True':
            time_from = flip_onset
        # Load next image in sequence
        if itrial < (len(trials)-1):
            load_start = core.getTime()
            next_img_name, _, _, _, _ = trials[itrial+1]        
            image_file = str(image_folder / next_img_name)
            img = visual.ImageStim(win, image=image_file, units='pix', size=image_size)
            load_done = core.getTime()
        # Draw next fixation
        fixation.draw()
        # New deadline for image down
        deadline_offset = (t0 + float(offset_time) - deadline_pct * ifi)
        responses = get_response(deadline_offset, key_list, responses, quit_keys=quit_keys, delta=while_loop_delta)
        second_resp_loop_done = core.getTime()

        flip_offset_flip = win.flip()
        flip_offset = core.getTime() # Don't trust flip timing (?)
        #print('Image time: %0.04f\n'%(flip_offset-flip_onset))
        #print('Resp time diff: %0.04f\n'%(second_resp_loop_done-first_resp_loop_done))
        timing.append(dict(
            # Drawing
            load_time=load_done-load_start,
            draw_time=draw_done-draw_start,
            # Onsets
            onset_deadline=deadline_onset,
            resp0_returned=first_resp_loop_done,
            resp0_diff=first_resp_loop_done-deadline_onset,
            on_diff=flip_onset-float(onset_time)-t0,
            on_diff_flip=flip_onset_flip-deadline_onset,
            resp0_returned_since_draw=first_resp_loop_done-draw_done, 
            # Offsets
            offset_deadline=deadline_offset,
            resp1_returned=second_resp_loop_done,
            resp1_diff=second_resp_loop_done-deadline_offset,
            off_diff=flip_offset-float(offset_time)-t0,
            off_diff_flip=flip_offset_flip-deadline_offset,
            # Image up
            image_shown=flip_offset - flip_onset,
            response_return_diff=second_resp_loop_done-first_resp_loop_done,
            ))

except:
    np.savez(sfile, **responses)
    plot_timing(timing)
    plt.show()
    raise
    # Save / close file
    win.close()
    core.quit()
    # raise the exception that broke the try loop
    
# Save / close file

# Close screen and quit
win.close()
core.quit()

plot_timing(timing)