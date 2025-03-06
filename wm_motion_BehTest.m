
% By Yuan    @ 20250220

%% 

resDir = [CurrDir '\Results\BehTest\' SubjID '\'];
if ~isdir(resDir)
    mkdir(resDir);
end

if exist([resDir SubjID '_Sess' num2str(SessID) '_motionTask_run' num2str(RunID) '.mat'],'file')
    ShowCursor;
    Screen('CloseAll');
    reset_test_gamma;
    warning on;
    error('This run number has been tested, please enter a new run num!');
end

results = zeros(Param.DisBehav.TrialNum,8);
timePoints = zeros(Param.DisBehav.TrialNum,8);
trial_index = randperm(Param.DisBehav.TrialNum);
trial_index = mod(trial_index,Param.Discri.DirectionNum)+1;

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% Results Matrix %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1- trial number           2- visual field location
% 3- sample baseline        4- task_diff
% 5- test angle             6- response, 1 = left, 2 = right
% 7- acc, 1 = right, 0 = wrong 
% 8- sample actual

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% TimePoint Matrix %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1- trial onset            2- fix onset delay  
% 3- Prefix duration        4- Sample duration
% 5- Delay duration         6- Test duration
% 7- RT                     8- trial dur
%% Main experiment
%% Staircase settings
if SessID == 1 && RunID == 1
    Param.Staircase.AngleDelta = Curr_AngleDelta;
elseif SessID == 1 && RunID ~= 1
    previous_results = load([CurrDir '\Results\BehTest\' SubjID '\' SubjID '_Sess' num2str(SessID) '_motionTask_run' num2str(RunID-1) '.mat']);
    Param.Staircase.AngleDelta = previous_results.threshold_value;
end
%% Eyelink Setting
if IfEyelink==0
    % initialize eye tracker
    mainfilename = [SubjID '_' num2str(SessID) '_' num2str(RunID)];
    dummymode = IfEyelink; 

    el=EyelinkInitDefaults(wnd);

    if ~EyelinkInit(dummymode, 1)
        fprintf('Eyelink Init aborted.\n');
        cleanup;  % cleanup function
        return;
    end

    [v vs]=Eyelink('GetTrackerVersion');
    fprintf('Running experiment on a ''%s'' tracker.\n', vs);

    % make sure that we get event data from the Eyelink
    Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');
    Eyelink('command', 'link_event_data = GAZE,GAZERES,HREF,AREA,VELOCITY');
    Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,BLINK,SACCADE,BUTTON');
    % draw_box
    Eyelink('command', 'draw_box %d %d %d %d 15',round(Param.Settings.ScrnResolution(3)/2-2*Param.RDK.InnerRadius),round(Param.Settings.ScrnResolution(4)/2-2*Param.RDK.InnerRadius),round(Param.Settings.ScrnResolution(3)/2+2*Param.RDK.InnerRadius),round(Param.Settings.ScrnResolution(4)/2+2*Param.RDK.InnerRadius));
    % open file to record data to
    edfFile=[mainfilename '.edf'];
    Eyelink('Openfile', edfFile);

    % STEP 4
    % Calibrate the eye tracker
    EyelinkDoTrackerSetup(el);

    % STEP 6
    % do a final check of calibration using driftcorrection
    success=EyelinkDoDriftCorrection(el);
    if success~=1
        cleanup;
        return;
    end

    eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
    if eye_used == el.BINOCULAR % if both eyes are tracked
        eye_used = el.LEFT_EYE; % use left eye
    end
end

%% stop by trials
UD = PAL_AMUD_setupUD('up',Param.Staircase.Up,'down',Param.Staircase.Down);
UD = PAL_AMUD_setupUD(UD,'StepSizeDown',Param.Staircase.StepSizeDown,'StepSizeUp',Param.Staircase.StepSizeUp, ...
    'stopcriterion', Param.Staircase.StopCriterion1,'xMax',Param.Staircase.xMax,'xMin',Param.Staircase.xMin,'truncate','yes');
UD = PAL_AMUD_setupUD(UD,'startvalue', Param.Staircase.AngleDelta,'stoprule',Param.Staircase.StopRule1);

%% Motion task
for trial_i = 1:Param.DisBehav.TrialNum

  if mod(trial_i,Param.DisBehav.minirun)==1
       if trial_i == 1
           DrawFormattedText(wnd,'Press space to start!','center','center', white);
       else
           DrawFormattedText(wnd,'Take a rest! Press space to start!','center','center', white);
       end

       Screen('Flip',wnd);
       is_true = 0;
       while (is_true == 0)
           [ifkey,RT_time,keyCode] = KbCheck;
           if keyCode(Param.Keys.Space)
               is_true = 1;
           elseif keyCode(Param.Keys.EscPress)
               abort;
           end
       end
  end

    results(trial_i,1) = trial_i;
    results(trial_i,2) = Param.Stimuli.LocationUsed;

    % task diff
    results(trial_i,4) = UD.xCurrent;
    jitter_temp = sign(rand-0.5);
    if jitter_temp == 0
        jitter_temp = 1;
    end
    curr_jitter = jitter_temp * results(trial_i,4);

    % determine location
    results(trial_i,3) = Param.Discri.Directions(trial_index(trial_i));  % target location = first sample
    temp_loc = randi(Param.Discri.DirectionNum-1);

    % task start time
    trial_onset = GetSecs;
    timePoints(trial_i,1) = trial_onset;

    % start recoding
    if IfEyelink==0
        % Eyelink start;
        Eyelink('startrecording');
        Eyelink('Message','Trial %d Begin',trial_i);
    end

    %% dots setting
    curr_loc = zeros(2,2);
    results(trial_i,8) = results(trial_i,3) + (rand - 0.5) * 2 *Param.Discri.Jitter;
    results(trial_i,5) = results(trial_i,8) + curr_jitter;
    
    MyDot_1 = Gen_DotMatrix_bm(results(trial_i,3),Param.RDK.Coherence,Param.RDK.NumFrames,Param.RDK.DotNum,Param.RDK.InnerRadius,Param.RDK.OuterRadius,Param.RDK.StepPerMove);
    MyDot_2 = Gen_DotMatrix_bm(results(trial_i,5),Param.RDK.Coherence,Param.RDK.NumFrames,Param.RDK.DotNum,Param.RDK.InnerRadius,Param.RDK.OuterRadius,Param.RDK.StepPerMove);

%% Go!

    %% Prefix
    Screen('FillOval',wnd,Param.Fixation.OvalColor,Param.Fixation.OvalLoc);
    Screen('DrawLines', wnd, Param.Fixation.CrossLoc, Param.Fixation.CrossWidth, Param.Fixation.CrossColor, [], 1);
    vbl = Screen('Flip',wnd);
    timePoints(trial_i,2) = vbl-timePoints(trial_i,1);

    %% Sample
    for frame_i = 1:Param.RDK.NumFrames
        %motion
        Screen('DrawDots',wnd,MyDot_1{1,frame_i},Param.RDK.DotSize,black,Param.Stimuli.Locations(results(trial_i,2),:),1);
        Screen('FillOval', wnd, Param.Fixation.OvalColor, Param.Fixation.OvalLoc);
        Screen('DrawLines', wnd, Param.Fixation.CrossLoc, Param.Fixation.CrossWidth, Param.Fixation.CrossColor, [], 1);
        if frame_i == 1
            vbl = Screen('Flip',wnd,vbl + Param.trainTrial.prefix);
            timePoints(trial_i,3) = vbl - sum(timePoints(trial_i,1:2));
        else
            Screen('Flip',wnd);
        end
    end    

    %% Delay
    Screen('FillOval',wnd,Param.Fixation.OvalColor,Param.Fixation.OvalLoc);
    Screen('DrawLines',wnd,Param.Fixation.CrossLoc,Param.Fixation.CrossWidth,Param.Fixation.CrossColor,[],1);
    vbl = Screen('Flip',wnd,vbl + Param.trainTrial.durDot);
    timePoints(trial_i,4) = vbl - sum(timePoints(trial_i,1:3));

    %% test
    for frame_i = 1:Param.RDK.NumFrames
        %motion
        Screen('DrawDots',wnd,MyDot_2{1,frame_i},Param.RDK.DotSize,black,Param.Stimuli.Locations(results(trial_i,2),:),1);
        Screen('FillOval', wnd, Param.Fixation.OvalColor, Param.Fixation.OvalLoc);
        Screen('DrawLines', wnd, Param.Fixation.CrossLoc, Param.Fixation.CrossWidth, Param.Fixation.CrossColor, [], 1);
        if frame_i == 1
            vbl = Screen('Flip',wnd,vbl+Param.trainTrial.Delay);
            timePoints(trial_i,5) = vbl - sum(timePoints(trial_i,1:4));
        else
            Screen('Flip',wnd);
        end
    end

    %% response
    Screen('FillOval',wnd,Param.Fixation.OvalColor,Param.Fixation.OvalLoc);
    Screen('DrawLines',wnd,Param.Fixation.CrossLoc,Param.Fixation.CrossWidth,Param.Fixation.CrossColor,[],1);
    vbl = Screen('Flip',wnd,vbl+Param.trainTrial.testDot);
    timePoints(trial_i,6) = vbl - sum(timePoints(trial_i,1:5));

    is_true = 0;
    while (is_true == 0 && GetSecs-vbl < Param.trainTrial.MaxRT)
        [keyIsDown_1, RT_time, keyCode] = KbCheck;
        if keyCode(Param.Keys.Right) || keyCode(Param.Keys.two1) || keyCode(Param.Keys.two2)
            results(trial_i,6) = 2;        % response
            if jitter_temp == 1
                results(trial_i,7) = 1; % acc
            end
            timePoints(trial_i,7) = RT_time - vbl;    % reation time
            is_true = 1;
        elseif keyCode(Param.Keys.Left) || keyCode(Param.Keys.one1) || keyCode(Param.Keys.one2)
            results(trial_i,6) = 1;
            if jitter_temp == -1
                results(trial_i,7) = 1;
            end
            timePoints(trial_i,7) = RT_time - vbl;
            is_true = 1;
        elseif keyCode(Param.Keys.EscPress)
            abort;
        end
    end
    UD = PAL_AMUD_updateUD(UD, results(trial_i,7)); % update UD structure
    %% ITI
    Screen('FillOval',wnd,Param.Fixation.OvalColor,Param.Fixation.OvalLoc);
    Screen('Flip',wnd);

    while (GetSecs - timePoints(trial_i,1) < Param.trainTrial.Duration_Beh)
        timePoints(trial_i,8) = GetSecs - timePoints(trial_i,1);
    end

    % stop recoding
    if IfEyelink==0
        Eyelink('Message','Trial %d End',trial_i);
        Eyelink('stoprecording');
    end

end

%% compute accuracy
threshold_value = PAL_AMUD_analyzeUD(UD, 'trials', Param.Staircase.StopRule1);
Accu = sum(results(:,7))./Param.DisBehav.TrialNum;
disp(' ');
disp(['Accuracy: ' num2str(Accu)]);
disp(' ');

%% save data
cd(resDir);
resName = [SubjID '_Sess' num2str(SessID) '_motionTask_run' num2str(RunID) '.mat'];
save(resName,'results','timePoints','UD','threshold_value','Accu','Param');
cd(CurrDir);

%% download eyelink data file
if IfEyelink==0
Eyelink('CloseFile');
% download data file
try
    fprintf('Receiving data file ''%s''\n', edfFile);
    status=Eyelink('ReceiveFile');
    if status > 0
        fprintf('ReceiveFile status %d\n', status);
    end
    if 2==exist(edfFile, 'file')
        fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd);
    end
catch rdf
    fprintf('Problem receiving data file ''%s''\n', edfFile );
    rdf;
end
end

cd(CurrDir);

if IfEyelink==0
figure(1);
edf_used=Edf2Mat([mainfilename '.edf'],1);
fix_num = size(edf_used.Events.Efix.start,2);
scatter(edf_used.Events.Efix.posX,edf_used.Events.Efix.posY);
end

hold on;

%% plot
figure(2);
end_trial = size(UD.x,2);
task_diff_temp = UD.x;

plot(1:end_trial,task_diff_temp(1:end_trial));
axis([0 Param.Staircase.MaxTrial 0 15]);

%%
warning on;
reset_test_gamma;
ShowCursor;
Screen('CloseAll');

delete *.asv