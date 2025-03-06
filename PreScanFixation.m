% by Yuan
% 2025/02/20 14:26
% fixations for fmri

%% Exp Start
rad = Param.RDK.OuterRadius;
Disc = [Param.Stimuli.Locations(Param.Stimuli.LocationUsed,1)-rad, Param.Stimuli.Locations(Param.Stimuli.LocationUsed,2)-rad,Param.Stimuli.Locations(Param.Stimuli.LocationUsed,1)+rad,Param.Stimuli.Locations(Param.Stimuli.LocationUsed,2)+rad];

Screen('FillOval', wnd, Param.Fixation.OvalColor, Disc);
% Screen('DrawLines', wnd, Param.Fixation.CrossLoc, Param.Fixation.CrossWidth, Param.Fixation.CrossColor, [], 1);
% Screen('DrawLines', wnd, [Param.Stimuli.Locations(Param.Stimuli.LocationUsed,1)-200,Param.Stimuli.Locations(Param.Stimuli.LocationUsed,1)+200;Param.Stimuli.Locations(Param.Stimuli.LocationUsed,2),Param.Stimuli.Locations(Param.Stimuli.LocationUsed,2)], Param.Fixation.CrossWidth, Param.Fixation.CrossColor, [], 1);

Screen('Flip', wnd);

is_true = 0;
while (is_true == 0)
    [~,~,keyCode] = KbCheck;
    if keyCode(Param.Keys.EscPress)
        abort;
    end
end

delete *.asv  