%% parameters
Param = struct;

%% Basic Settings--Behav
Param.Settings.ViewDistance      = 700;              % 1100 mm 
Param.Settings.ScrnResolution    = [0 0 1024 768];   % rect_computer = [0 0 40 30];
Param.Settings.SquareSize        = Param.Settings.ScrnResolution(3);             % 400 mm 
Param.Settings.SquareLength      = 350;              % 154 mm  
Param.Settings.PixelPerDegree    = 2*Param.Settings.ViewDistance*tan(1/2/180*pi)*Param.Settings.SquareSize/Param.Settings.SquareLength;       
Param.Settings.offset            = offset;

%% Basic Settings--ZJU
% Param.Settings.ViewDistance   = 1430;            % mm 
% Param.Settings.ViewDistance     = 3000;            % 1560mm, with bitebar, editted in 24 May 2023
% Param.Settings.ScrnResolution   = [0 0 1920 1080]; %[0 0 1920 1080]
% Param.Settings.SquareSize       = Param.Settings.ScrnResolution(3);             % pixels
% Param.Settings.SquareLength     = 885;             % mm 
% Param.Settings.PixelPerDegree   = 2*Param.Settings.ViewDistance*tan(1/2/180*pi)*Param.Settings.SquareSize/Param.Settings.SquareLength; 
% Param.Settings.offset           = offset;
% Param.Settings.ViewDistance   = 1430;            % mm 
% Param.Settings.ScrnResolution = [0 0 1920 1080];
% Param.Settings.SquareSize     = 400;             % pixels
% Param.Settings.SquareLength   = 100;             % mm 
% Param.Settings.PixelPerDegree = 2*Param.Settings.ViewDistance*tan(1/2/180*pi)*Param.Settings.SquareSize/Param.Settings.SquareLength; 
% Param.Settings.offset         = offset;

%% Keys for Response
Param.Keys.Space        = 32;  
Param.Keys.EscPress     = 27;
Param.Keys.Left         = 37; 
Param.Keys.Right        = 39;
Param.Keys.one1         = 49; 
Param.Keys.two1         = 50;
Param.Keys.one2         = 97; 
Param.Keys.two2         = 98;
Param.Keys.Trigger1     = 83;  % 's'    

%% Stimulus Locations
Param.Stimuli.Eccentricity   = 5; % degree
Param.Stimuli.Locations(1,:) = [Param.Settings.ScrnResolution(3)/2 - Param.Stimuli.Eccentricity * Param.Settings.PixelPerDegree , Param.Settings.ScrnResolution(4)/2] + Param.Settings.offset;
Param.Stimuli.Locations(2,:) = [Param.Settings.ScrnResolution(3)/2 + Param.Stimuli.Eccentricity * Param.Settings.PixelPerDegree , Param.Settings.ScrnResolution(4)/2] + Param.Settings.offset;
Param.Stimuli.Locations(3,:) = [Param.Settings.ScrnResolution(3)/2, Param.Settings.ScrnResolution(4)/2] + Param.Settings.offset;
Param.Stimuli.LocationsText  = {'Left','Right','Center'};
% location(1) = Left Visual Field;  location(2) = Right Visual Field;   location(3) = Center Visual Field;
Param.Stimuli.LocationUsed   = 3;
% Param.Stimuli.OuterRadius    = 3.25 * Param.Settings.PixelPerDegree;

%% Parameters for Fixation
Param.Fixation.CrossColor    = [1,1,1]*255;
Param.Fixation.CrossSize     = 0.2*Param.Settings.PixelPerDegree;
Param.Fixation.CrossWidth    = 0.05*Param.Settings.PixelPerDegree;
Param.Fixation.CrossLoc      = [Param.Stimuli.Locations(Param.Stimuli.LocationUsed,1)-Param.Fixation.CrossSize, Param.Stimuli.Locations(Param.Stimuli.LocationUsed,1)+Param.Fixation.CrossSize, Param.Stimuli.Locations(Param.Stimuli.LocationUsed,1), Param.Stimuli.Locations(Param.Stimuli.LocationUsed,1);...
                                Param.Stimuli.Locations(Param.Stimuli.LocationUsed,2), Param.Stimuli.Locations(Param.Stimuli.LocationUsed,2), Param.Stimuli.Locations(Param.Stimuli.LocationUsed,2)-Param.Fixation.CrossSize, Param.Stimuli.Locations(Param.Stimuli.LocationUsed,2)+Param.Fixation.CrossSize]; 

Param.Fixation.OvalSize      = 0.25*Param.Settings.PixelPerDegree;
Param.Fixation.OvalLoc       = [Param.Stimuli.Locations(Param.Stimuli.LocationUsed,1)-Param.Fixation.OvalSize, Param.Stimuli.Locations(Param.Stimuli.LocationUsed,2)-Param.Fixation.OvalSize,Param.Stimuli.Locations(Param.Stimuli.LocationUsed,1)+Param.Fixation.OvalSize,Param.Stimuli.Locations(Param.Stimuli.LocationUsed,2)+Param.Fixation.OvalSize];
Param.Fixation.OvalColor     = [0,0,0]; 

%% font size
Param.Text.Font = 'Helvetica';
Param.Text.Size = 20;
%% Open Window
screens = Screen('Screens');
screenNumber = max(screens);	

white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
gray = round((white+black)/2);
yellow =[255,153,18];
red    =[178,34,34];
Screen('Preference', 'SkipSyncTests', 1);
wnd = Screen('OpenWindow',screenNumber,gray,Param.Settings.ScrnResolution); 
Screen('BlendFunction', wnd, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

FrameRate = Screen('FrameRate',wnd);
NominalFrameRate = Screen('NominalFrameRate',wnd); 
RefreshDur = Screen('GetFlipInterval',wnd);
Slack = RefreshDur / 2;

Screen('TextFont', wnd, Param.Text.Font);
Screen('TextSize', wnd, Param.Text.Size);

%% Parameters for RDK
Param.RDK.DotNum          = 400;
Param.RDK.DotSize         = 4; 
Param.RDK.Speed           = 8;         % Watanabe 14.2  %点运动速度，用于控制实验难度
Param.RDK.Coherence       = 1;         % 0-1

Param.RDK.OuterRadius     = 3.5*Param.Settings.PixelPerDegree;         % radius
Param.RDK.InnerRadius     = 0.5*Param.Settings.PixelPerDegree;       % radius
Param.RDK.Duration        = 0.5;                                     % s
Param.RDK.FramesPerMove   = 1;                                    % 每XX个frame更新点的位置
Param.RDK.NumFrames       = Param.RDK.Duration*NominalFrameRate/Param.RDK.FramesPerMove;         %注意：这里必须是整数
Param.RDK.StepPerMove     = Param.RDK.FramesPerMove/NominalFrameRate*Param.RDK.Speed*Param.Settings.PixelPerDegree; %移动pixel数
Param.RDK.OvalSize        = 5*Param.Settings.PixelPerDegree;
Param.RDK.OvalLoc         = [Param.Stimuli.Locations(Param.Stimuli.LocationUsed,1)-Param.RDK.OvalSize, Param.Stimuli.Locations(Param.Stimuli.LocationUsed,2)-Param.RDK.OvalSize,Param.Stimuli.Locations(Param.Stimuli.LocationUsed,1)+Param.RDK.OvalSize,Param.Stimuli.Locations(Param.Stimuli.LocationUsed,2)+Param.RDK.OvalSize];

%% Parameters for spatial dots
Param.SpatialDot.DotSize        = 0.15 * Param.Settings.PixelPerDegree;
Param.SpatialDot.OuterRadius    = 3.5 * Param.Settings.PixelPerDegree;

%% Parameters for Trials
Param.Trial.TR = 3;
Param.Trial.Duration_fMRI = 10 * Param.Trial.TR;  % 30
Param.Trial.prefix        = 0.5;
Param.Trial.durDot        = 0.5;
Param.Trial.testDot       = 0.5;
Param.Trial.Delay         = (5*Param.Trial.TR)-Param.Trial.durDot-Param.Trial.prefix;  % 14
Param.Trial.MaxRT         = 1.5;

%% Behaviour 
Param.trainTrial.Duration_Beh  = 6 * Param.Trial.TR; %18
Param.trainTrial.Duration_Beh2  = 8;
Param.DisBehav.TrialNum        = 42;
Param.DisBehav.minirun         = 21;
Param.DisBehav.AngleDelta      = Curr_AngleDelta;
Param.trainTrial.prefix        = 0.5;
Param.trainTrial.ITI           = 1;
Param.trainTrial.durDot        = 0.5;
Param.trainTrial.testDot       = 0.5;
Param.trainTrial.Delay         = (5*Param.Trial.TR)-Param.trainTrial.durDot-Param.trainTrial.prefix; % 15
Param.trainTrial.Delay2        = 4;
Param.trainTrial.MaxRT         = 1.5;
Param.trainTrial.feedback      = 1;

%% Discrimination
Param.Discri.Directions   = [15,75,135,195,255,315]; % 6 directions
Param.Discri.DirectionNum = length(Param.Discri.Directions);
Param.Discri.Jitter       = 10;

%% fMRI 
Param.DisfMRI.TrialNum     = 18;
Param.DisfMRI.AngleDelta   = Curr_AngleDelta;
Param.DisfMRI.Dummy        = 2*Param.Trial.TR;

%% Parameters for Staircase
Param.Staircase.AngleDelta      = Curr_AngleDelta;        % start
Param.Staircase.MaxTrial        = 60;      
Param.Staircase.Up              = 1;        % increase after 1 wrong
Param.Staircase.Down            = 3;        % decrease after 3 consecutive right
Param.Staircase.StepSizeDown    = 0.5;           
Param.Staircase.StepSizeUp      = 0.5;      
Param.Staircase.StopCriterion1  = 'trials';   
Param.Staircase.StopRule1       = Param.DisBehav.TrialNum;  
Param.Staircase.ReversalsUsed1  = 3; 
Param.Staircase.StopCriterion2  = 'reversals';   
Param.Staircase.StopRule2       = 10;
Param.Staircase.ReversalsUsed2  = 4; 
Param.Staircase.xMax            = 15;              
Param.Staircase.xMin            = 0;
