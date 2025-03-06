function CalculateVisibleArea(subjId, acqId, buttonBox)
% Measure visible area of the screen by interactive adjustment of a
% rectangle using a keyboard on button box.
%
% By Ke Jia, 08-Mar-2022 18:25

%%% arg check
if nargin < 1
    subjId = 'TEST';
end

if nargin < 2
    acqId = 1;
end

if nargin < 3
    buttonBox = 0;
    % if 0, check with keyboard using left/right/up/down
    % if 1, check with buttonbox
end

%%% print instructions
commandwindow;
Screen('Preference', 'SkipSyncTests', 1);

fprintf('\nPlease use the following keys to adjust the position of the white square\n')
fprintf('such that it is entirely visible to the subject:\n\n')
fprintf('### 1: decrease edge coordinate\n')
fprintf('### 2: increase edge coordinate\n')
fprintf('### 3: move to next edge\n')
fprintf('### 4: confirm adjustment\n\n')
fprintf('Press any key to proceed...\n')

pause;

%%% display
Screens=Screen('Screens');
ScnNbr=max(Screens);
[wPtr,wRect]=Screen('OpenWindow', ScnNbr, 0,[],32,2);
Screen(wPtr,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
HideCursor;

Black=BlackIndex(ScnNbr);
White=WhiteIndex(ScnNbr);
Gray=round((White+Black)/2);
if round(Gray)==White
	Gray=Black;
end

Screen('FillRect', wPtr, Gray);
Screen('Flip', wPtr);


%%% initial rectangle dimensions
width = 800;
height = 600;
FrmRect=CenterRect([0,0,width,height], wRect);
Screen('FrameRect', wPtr, White, FrmRect, 1);
Screen('Flip', wPtr);

KbName('UnifyKeyNames');

%%% initialize button box
if buttonBox == 1
    % define buttons
    lessButton = KbName('1!');
    moreButton = KbName('2@');
    nextButton = KbName('3#');
    doneButton = KbName('4$');
    
else
    % if we're not using button box, then we use a normal keyboard instead
    lessButton = KbName('LeftArrow');
    moreButton = KbName('RightArrow');
    nextButton = KbName('DownArrow');
    doneButton = KbName('UpArrow'); 
end

activeEdge = 1;

EscapeKey = KbName('Escape');
[touch, secs, keyCode] = KbCheck;
while 1    

    [touch, secs, keyCode] = KbCheck;
    moveToNext = keyCode(nextButton);
    increment = keyCode(moreButton);
    decrement = keyCode(lessButton);
    done = keyCode(EscapeKey) || keyCode(doneButton);
   
    if moveToNext
        pause(0.2);
        activeEdge = activeEdge + 1;
        if activeEdge > 4
            activeEdge = 1;
        end
    end
    
    switch activeEdge
        case 1
            xy = [FrmRect(1), mean(FrmRect([2,4]))];
        case 2
            xy = [mean(FrmRect([1,3])), FrmRect(2)];
        case 3
            xy = [FrmRect(3), mean(FrmRect([2,4]))];
        case 4
            xy = [mean(FrmRect([1,3])), FrmRect(4)];
    end
    
    FrmRect(activeEdge) = FrmRect(activeEdge) + increment;
    FrmRect(activeEdge) = FrmRect(activeEdge) - decrement;
    
    Screen('FrameRect', wPtr, White, FrmRect, 1);
    Screen('DrawDots', wPtr, xy, 10)
    Screen('Flip',wPtr);
    
    if done
        ShowCursor;
        Screen('CloseAll');
        break;
    end
end

fprintf('Final rect\n')
fprintf('[%i, %i, %i, %i]\n', FrmRect(1), FrmRect(2), FrmRect(3), FrmRect(4))
save([pwd '\Results\VisibleArea\' subjId '_' num2str(acqId) '_visible-area.mat'], 'FrmRect');
delete *.asv
