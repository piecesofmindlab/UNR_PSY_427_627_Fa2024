
% Set up scren
fullScreen = false; % false for debugging, true to run
screenColor = [128,128,128];
movieDurationSecs=2;
writeMovie = true;

if fullScreen
    screenRect = [];
    [width_mm, height_mm] = Screen('DisplaySize', screenNumber);
    res = Screen('Resolution', screenNumber);
    screenSize = [res.width, res.height];
else
    screenSize = [800, 600]; % []
    screenUpperLeft = [200,200];
    screenRect = [screenUpperLeft, screenUpperLeft + screenSize];
end

% Get the list of screens and choose the one with the highest screen number.
% Screen 0 is, by definition, the display with the menu bar. Often when
% two monitors are connected the one without the menu bar is used as
% the stimulus display.  Chosing the display with the highest dislay number is
% a best guess about where you want the stimulus displayed.
screens=Screen('Screens');
screenNumber=max(screens);
% Get screen frame rate
frameRate=Screen('FrameRate',screenNumber);
% If the OS does not know the frame rate the 'FrameRate' will return 0.
% That usually means we run on a flat panel with 60 Hz fixed refresh
% rate:
if frameRate == 0
    frameRate = 60;
end

% Find the color values which correspond to white and black: Usually
% black is always 0 and white 255, but this rule is not true if one of
% the high precision framebuffer modes is enabled via the
% PsychImaging() commmand, so we query the true values via the
% functions WhiteIndex and BlackIndex:
white=WhiteIndex(screenNumber);
black=BlackIndex(screenNumber);

% Round gray to integral number, to avoid roundoff artifacts with some
% graphics cards:
gray=round((white+black)/2);

% This makes sure that on floating point framebuffers we still get a
% well defined gray. It isn't strictly neccessary in this demo:
if gray == white
    gray=white / 2;
end

% Contrast 'inc'rement range for given white and gray values:
inc=white-gray;
% Laregly lifted from DriftDemo from Mario Kleiner in psychtoolbox
try
    % Open a double buffered fullscreen window and select a gray background
    % color:
    win = Screen('OpenWindow', screenNumber, gray, screenRect);
    if writeMovie
        % MAKE A MOVIE! 
        movie = Screen('CreateMovie', win, 'MyTestMovie.mp4', 512, 512, 30, ':CodecSettings=Videoquality=0.5 Profile=2');
    end
    % Compute each frame of the movie and convert the those frames, stored in
    % MATLAB matices, into Psychtoolbox OpenGL textures using 'MakeTexture';
    numFrames=12; % temporal period, in frames, of the drifting grating
    for i=1:numFrames
        phase=(i/numFrames)*2*pi;
        % grating
        [x,y]=meshgrid(-300:300,-300:300);
        angle=30*pi/180; % 30 deg orientation.
        f=0.05*2*pi; % cycles/pixel
        a=cos(angle)*f;
        b=sin(angle)*f;
        m=exp(-((x/90).^2)-((y/90).^2)).*sin(a*x+b*y+phase);
        tex(i)=Screen('MakeTexture', win, round(gray+inc*m)); %#ok<AGROW>
    end

    % Convert movieDuration in seconds to duration in frames to draw:
    movieDurationFrames=round(movieDurationSecs * frameRate);
    movieFrameIndices=mod(0:(movieDurationFrames-1), numFrames) + 1;

    % Use realtime priority for better timing precision:
    priorityLevel=MaxPriority(win);
    Priority(priorityLevel);

    % Animation loop:
    for i=1:movieDurationFrames
        % Draw image:
        Screen('DrawTexture', win, tex(movieFrameIndices(i)));
        % Show it at next display vertical retrace. Please check DriftDemo2
        % and later, as well as DriftWaitDemo for much better approaches to
        % guarantee a robust and constant animation display timing! This is
        % very basic and not best practice!
        Screen('Flip', win);
        % Add a screenshot of the center 512 x 512 pixels as a new video frame to the movie file, if any:
        if writeMovie
            % It would be better to capture the image from the 'backBuffer', but
            % we capture the 'frontBuffer' to work around a bug in the VirtualBox
            % Virtual Machine software when running a Windows-7 VM. This exotic
            % setup is used for testing of PTB, you should not need this
            % workaround on your system.
            Screen('AddFrameToMovie', win, CenterRect([0 0 512 512], Screen('Rect', win)), 'frontBuffer');
        end
    end

    % Finalize and close movie file, if any:
    if writeMovie
        Screen('FinalizeMovie', movie);
    end
    Priority(0);

    % Close all textures. This is not strictly needed, as
    % Screen('CloseAll') would do it anyway. However, it avoids warnings by
    % Psychtoolbox about unclosed textures. The warnings trigger if more
    % than 10 textures are open at invocation of Screen('CloseAll') and we
    % have 12 textues here:
    Screen('Close');

    % Close window:
    sca;

catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    sca;
    Priority(0);
    psychrethrow(psychlasterror);
end %try..catch..
