function [] = bfix(cfg)
%afix Summary of this function goes here
%   Detailed explanation goes here


    % Init dio, no reward
    cclabInitDIO('AB');

    %  kb stuff
    ListenChar(2); % disable kb input at matlab command window
    KbName('UnifyKeyNames');

    % Open window
    Screen('Preference', 'SkipSyncTests', cfg.SkipSyncTests);

    if cfg.doBitsPlusPlus
        InitializeMatlabOpenGL(1,3,1);
        BitsPlusPlus('SetColorConversionMode', 2);
        [wp, wrect] = BitsPlusPlus('OpenWindowColor++', cfg.screen_number, cfg.background_color, cfg.screen_rect);
        BitsPlusPlus('DIOCommand', wp, -1, 0, 255, trigData, 0, 1, 2);
    else

        % Thank you for this section: https://www.jennyreadresearch.com/research/lab-set-up/datapixx/
        AssertOpenGL;
        % Configure PsychToolbox imaging pipeline to use 32-bit floating point numbers.
        % Our pipeline will also implement an inverse gamma mapping to correct for display gamma.
        PsychImaging('PrepareConfiguration');
        PsychImaging('AddTask', 'General', 'FloatingPoint32Bit');
        PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');
        %oldVerbosity = Screen('Preference', 'Verbosity', 1); % Don%t log the GL stuff
        [wp, wrect] = PsychImaging('OpenWindow', cfg.screen_number, 255 * cfg.background_color);
        %Screen('Preference', 'Verbosity', oldVerbosity);



        % old [wp, wrect] = Screen('OpenWindow', cfg.screen_number, 255*cfg.background_color, cfg.screen_rect);
    end
    trigData = zeros(1, 248);
    trigData(1, 1:10) = 32768;
    cfg.window_rect = wrect;

    pauseSec = 0.25;
    pulseWidth = 0.1; % ms
    maxStimFrames = 800;
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
                cclabPulse('A', pulseWidth);
                drawScreenNoFlip(cfg, wp, 255*mod(nFrames, 2));                
                tflip = Screen('Flip', wp);

                % only put out this trigger on b-w trans
                if mod(nFrames, 2)
                    cclabPulse('B', pulseWidth);
                end
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
                drawScreenNoFlip(cfg, wp, 0);
                Screen('Flip', wp);
            otherwise
                error("Unhandled state %s\n", state);
        end                                 
    end
    if cfg.doBitsPlusPlus
        BitsPlusPlus('DIOCommandReset', wp);
        BitsPlusPlus('Close');
    end
    ListenChar(0);
    sca;
    cclabCloseDIO();

end


function [tflip] = drawScreenNoFlip(cfg, wp, x)
    Screen('FillRect', wp, 255*cfg.background_color);
    if ~isempty(x) && isscalar(x)
        % rect for drawing photodiode square
        % 'center', 'left', 'right', 'top', and 'bottom'. 
        r=AlignRect(cfg.marker_rect ,cfg.window_rect, cfg.marker_rect_side1, cfg.marker_rect_side2);
        Screen('FillRect', wp, [x, x, x], r);
    end
end
    
function [] = mylogger(cfg, str)
    if cfg.verbose
        fprintf(str);
    end
end
