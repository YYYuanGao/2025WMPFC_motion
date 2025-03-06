%% for WM PFC-motion ver
% by Yuan 2025-02-20 14:50

clear all;
clc;

%% parameters need to be changed
SubjID            = 'mot_s03';
Curr_AngleDelta   = 8.14;
SessID            = 1;
RunID             = 1;
IfEyelink         = 0; % 1-no eyelink; 0-eyelink
offset            = [0,0];  % x positive--right; y postive--down

%%  
CurrDir = pwd;
warning off;
SetupRand;
set_test_gamma;
HideCursor;
parameters;
%% 
% line400pixels; % should be around 9.1 cm21212
% CalculateVisibleArea(SubjID,1,1);
%% 
% PreScanFixation;
% EyelinkExample;

%%
% CheckVisibleArea(SubjID,1,1,Param);
% RSfixation;
% wm_motion_practice;
% wm_motion_BehTest;
% wm_motion_training;
wm_motion_fMRI;

delete *.asv
