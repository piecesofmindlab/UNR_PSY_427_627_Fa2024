% Run experiment

% Parameters
screenFps = 60;
ifi = 1 / screenFps;
deadlinePct = 0.2; % percent of a screen refresh interval by which 
whileLoopDelta = 0.001; % 1 ms
% to return control in while loops

subjectNumber = 1;
fullScreen = false; % false for debugging, true to run
imageSize = [500,500];
textColor = [255, 255, 255];
fixationColor = [255, 235, 0]; % a nice yellow
fixationSize = 12; % pixels
screenColor = [128,128,128];
% Choose screen, in case you want to display on another screen (e.g. the 
% projector in an fMRI experiment setup)
screens=Screen('Screens');
% Choosing the display with the highest display number is
% a best guess about where you want the stimulus displayed.
screenNumber=max(screens);
% File to save
date = datetime('now');
date.Format = 'yyyy_MM_dd_hh_mm';
sfile = sprintf('subject%02d_%s', subjectNumber, date);
% Instructions
instructions_choice = 'Please press the button you want to use to respond';
quitKeys = {'ESCAPE', 'q'};
instructions = {'Thank you!',...
                '',...
                'In this experiment, you will see images of', ...
                'faces, places, bodies, objects, and text,', ...
                'along with scrambled images.' ...
                '', ...
                'As you watch the images go by, please press', ...
                'the response key as fast as you can if you see', ...
                'a repeated image.', ...
                '',...
                '(Press any key to continue)'};
instructions = strjoin(instructions, '\n');

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
% fixation
xCenter = screenSize(1) / 2;
yCenter = screenSize(2) / 2;
fixationRect = CenterRectOnPoint([0 0 fixationSize fixationSize], xCenter, yCenter);

% Skip sync tests for now (sync tests cause issues on Mac OS)
Screen('Preference', 'SkipSyncTests', 0);
% Load `trials` variable
load(sprintf('subject%02d_plan.mat', subjectNumber));

if ~exist('imageFolder','var')
    imageFolder = '~/Teaching/PSY427_627/datasets/fLoc_stimuli/';
end
if ~exist(imageFolder, 'dir')
    error('Image folder does not exist!')
end
nTrials = length(trials);
% preallocate trials
rfields = {'keyPressed', 'rt', 'rtAbsolute', 'blockNumber', 'trial', 'deltaTime'};
responses = cell2struct(cell(length(rfields), nTrials), rfields, 1);
% preallocate responses
tfields = {'load_time', 'draw_time', 'image_time', 'trial',};
timing= cell2struct(cell(length(tfields), nTrials), tfields, 1);
flipDelta = 0.002;
% try / catch around opening screen
try
    % Disable keys in matlab window
    ListenChar(2);
    % Open window with default settings:
    win = Screen('OpenWindow', screenNumber, screenColor, screenRect);
    % Choose response key
    DrawFormattedText(win, instructions_choice, 'center','center', textColor);
    Screen('Flip', win);
    FlushEvents; 
    WaitSecs(.5); 
    respKey = 'ESCAPE';
    while any(strcmp(quitKeys, respKey))
        [keyTime, keyCode, dTime] = KbWait;
        % Make sure we have one clear keypress
        if sum(keyCode) > 1
            continue
        end
        % Keep key & break loop
        respKey = find(keyCode);
    end

    % Display instructions
    DrawFormattedText(win, instructions, 'center','center', textColor);
    Screen('Flip', win);
    KbWait;
    t0 = GetSecs;
    timeFrom = t0;
    % Load first image
    imgFile = fullfile(imageFolder, trials{1, 1});
    imgOrig = imread(imgFile);
    imgSmall = imresize(imgOrig, imageSize);
    imageTexture = Screen('MakeTexture', win, imgSmall);
    % Loop over trials
    for itrial = 1:length(trials)
        % Load timing parameters
        onsetTime = trials{itrial, 2};
        offsetTime = trials{itrial, 3};
        isTarget = trials{itrial, 4};
        blockNumber = trials{itrial, 5};
        % Draw image texture
        draw_start = GetSecs;
        Screen('DrawTexture', win, imageTexture);
        Screen('FillOval', win, fixationColor, fixationRect);    
        draw_done = GetSecs;
        % Use any remaining time before presentation deadline to check for
        % response keys
        deadline_1 = (t0 + onsetTime - deadlinePct * ifi);
        tmp = getResponses(deadline_1, respKey, timeFrom, whileLoopDelta, quitKeys);
        responses(itrial) = tmp;
        
        flipOnset = Screen('Flip', win, t0 + trials{itrial, 2}-flipDelta);
        if isTarget
            timeFrom = flipOnset;
        end
        Screen('FillOval', win, fixationColor, fixationRect);
        
        if itrial < length(trials)
            load_start = GetSecs;
            imgFile = fullfile(imageFolder, trials{itrial+1, 1});
            imgOrig = imread(imgFile);
            imgSmall = imresize(imgOrig, imageSize);
            imageTexture = Screen('MakeTexture', win, imgSmall);
            load_done = GetSecs; 
        end
        % Deadline is `deadlinePct` of a refresh before intnded flip
        deadline_2 = (t0 + offsetTime - deadlinePct * ifi);
        tmp = getResponses(deadline_2, respKey, timeFrom, whileLoopDelta, quitKeys);
        if ~isempty(tmp.rt)
            responses(itrial) = tmp;
        end
        responses(itrial).trial = itrial;
        responses(itrial).blockNumber = blockNumber;

        flipOffset = Screen('Flip', win, t0 + trials{itrial, 3}-flipDelta);
        % Record Timing
        timing(itrial).deadline_1 = deadline_1;
        timing(itrial).flipOnset = flipOnset;
        timing(itrial).flipOffset = flipOffset;
        timing(itrial).deadline_2 = deadline_2;
        timing(itrial).load_time = load_done-load_start;
        timing(itrial).draw_time = draw_done-draw_start;
        timing(itrial).image_time = flipOffset-flipOnset;
        timing(itrial).trial = itrial;
    end
catch %ME
    % Close screen
    sca;
    % Enable keystrokes in Matlab window
    ListenChar(0);
    % Close trial file
    %fclose(fid);
    % Display the error we caught
    error(lasterror)
end
% Close screen
sca;
% Enable keystrokes in Matlab window
ListenChar(0);
% Close trial file
%fclose(fid);
image_time = [timing.image_time];
mm = mean(image_time);
ss = std(image_time);
fprintf('Image time = %.05f +/- %0.5f', mm, ss);
figure;
bins = linspace(mm - ifi*2, mm + ifi*2, 31);
hist(image_time, bins)

function response = getResponses(deadline, respKey, timeFrom, whileLoopDelta, quitKeys)
% Usage: [resp] = getResponses(deadline)
% 
if ~exist('whileLoopDelta', 'var')
    whileLoopDelta = 0.001;
end
if ~exist('quitKeys', 'var')
    quitKeys = {'ESCAPE', 'q'};
end

rfields = {'keyPressed', 'rt', 'rtAbsolute', 'blockNumber', 'trial', 'deltaTime'};
response = cell2struct(cell(length(rfields), 1), rfields, 1);

while GetSecs < deadline
    [keyDown, rt, keyCode, deltaTime] = KbCheck;
    if keyDown && keyCode(respKey)
        % record response
        response.keyPressed = KbName(keyCode);
        response.rtAbsolute = rt;
        response.rt = rt - timeFrom;
        response.deltaTime = deltaTime;
        break
    elseif keyDown && any(keyCode(KbName(quitKeys)))
        error("Manual quit!")
    end
    % Allow operating system to do its thing for 1 ms
    WaitSecs(whileLoopDelta);
end
% Continue listening for quit keys if response has already been
% collected
while GetSecs < deadline
    [keyDown, rt, keyCode, deltaTime] = KbCheck;
    if keyDown && any(keyCode(KbName(quitKeys)))
        error("Manual quit!")
    end
    % Allow operating system to do its thing for 1 ms
    WaitSecs(whileLoopDelta);
end
end