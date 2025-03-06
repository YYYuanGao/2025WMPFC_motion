% abort
function abort  
    ShowCursor;              
    Screen('CloseAll');      
    reset_test_gamma;       
    warning on;              
    error('aborting due to user cancellation...');
end