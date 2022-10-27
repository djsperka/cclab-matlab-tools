function [] = bfix(cfg)
%afix Summary of this function goes here
%   Detailed explanation goes here


    %  kb stuff
    ListenChar(2); % disable kb input at matlab command window
    KbName('UnifyKeyNames');



    % Open window
    [wp, wrect] = Screen('OpenWindow', cfg.screen_number, cfg.background_color, cfg.screen_rect);
    Screen('FillRect', wp, cfg.background_color);



    pauseSec = 0.5;
    maxStimFrames = 20;
    stimLoopFrames = 4;
    bQuit = 0;
    bGo = 0;
    state = "WAIT_GO";
    tStateStart = -1;

    fprintf('Enter ''g'' to go, ''q'' to quit.');
    while ~bQuit && state ~= "DONE"
    
        % Check kb each time 
        [keyIsDown, ~, keyCode] = KbCheck();
        
        % TODO kb handling
        bQuit = keyIsDown && keyCode(KbName('q'));
        bGo = keyIsDown && keyCode(KbName('g'));
        if bQuit
            state = "DONE";
            fprintf('got Q\n');
        end

        switch(state)
            case "WAIT_GO"
                if bGo
                    mylogger(cfg, "WAIT_GO: got go signal\n");
                    nFrames = 0;
                    state = "STIM";
                end
            case "STIM"
                drawScreen(cfg, wp, mod(nFrames, stimLoopFrames)/stimLoopFrames);
                nFrames = nFrames + 1;
                if nFrames == maxStimFrames
                    state = "DONE";
                else
                    state = "PAUSE";
                end
            case "PAUSE"
                WaitSecs(pauseSec);
                state = "STIM";
            case "DONE"
                drawScreen(cfg, wp, 0);
            otherwise
                error("Unhandled state %s\n", state);
        end                                 
    end

    ListenChar(0);
    sca;

end

function [tflip] = drawScreen(cfg, wp, x)
    Screen('FillRect', wp, cfg.background_color);
    if ~isempty(x) && isscalar(x)
        % rect for drawing photodiode square
        marker_rect_pos = [0, cfg.screen_resolution(2)-cfg.marker_rect(4), cfg.marker_rect(3), cfg.screen_resolution(2)];
        Screen('FillRect', wp, [x*255, x*255, x*255], marker_rect_pos);
    end
    tflip = Screen('Flip', wp);
end
    
function [] = mylogger(cfg, str)
    if cfg.verbose
        fprintf(str);
    end
end
