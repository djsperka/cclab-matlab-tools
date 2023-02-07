function [times] = dfix(cfg)
%afix Summary of this function goes here
%   Detailed explanation goes here

    try
        % docs say this call with (2) arg does the following:
        % AssertOpenGL();
        % KbName('UnifyKeyNames');
        % It also says that any time Screen('OpenWindow'....) is called, that 
        % the following call is implied:
        % Screen('ColorRange', window, 1, [], 1);
        % It means that we should use color values in [0,1], not [0, 255].
    
        PsychDefaultSetup(2);
        % TODO ListenChar(2); % disable kb input at matlab command window
    
        % Init dio, no reward
        cclabInitDIO(cfg.dio);
    
        % Open window
        Screen('Preference', 'SkipSyncTests', cfg.SkipSyncTests);
        [cfg.wp, cfg.wrect] = Screen('OpenWindow', cfg.screen_number, cfg.screen_rect);
    
    
        % eyelink    
        myEyelinkInit(cfg, 'aaa010');
    
        pause();
    
    
    
        ListenChar(0);
        sca;
        cclabCloseDIO();
    
        Eyelink('CloseFile');
        Eyelink('ReceiveFile');
        Eyelink('Shutdown');

    catch exception
        % cleanup
        ListenChar(0);
        sca;
        cclabCloseDIO();
        Eyelink('Shutdown');
        % rethrow ex
        rethrow(exception);
    end
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

function [] = myEyelinkInit(cfg, filename)

%   Initialization of eyelink struct
    el = EyelinkInitDefaults(cfg.wp);
    el.calibrationtargetsize = 5;% Outer target size as percentage of the screen
    el.calibrationtargetwidth = 0;% Inner target size as percentage of the screen
    el.backgroundcolour = [128 128 128];% RGB grey
    el.calibrationtargetcolour = [0 0 1];% RGB black
    el.msgfontcolour = [0 0 1];% RGB black
    EyelinkUpdateDefaults(el);

    % Now do the actual eyelink init. The connection is established here, 
    % unless dummymode is set. 
    EyelinkInit(cfg.eyelink_dummymode);
    status = Eyelink('IsConnected');
    [ver, versionstring] = Eyelink('GetTrackerVersion');
    if ~cfg.eyelink_dummymode
        if ~status
            % asked for connection but didn't get it
            ME = MException('Eyelink connection failed.');
            throw(ME);
        else
            fprintf('Eyelink (%s) is connected.\n', versionstring);

        %   Open EDF file
            failOpen = Eyelink('OpenFile', filename);
            if failOpen
                ME = MException('Cannot open Eyelink data file %s\n', filename);
                throw(ME);  
            end
        
        
            Eyelink('Command', 'add_file_preamble_text "RECORDED BY Matlab %s session name: %s"', mfilename, filename);
        
            % Events for file and online
            Eyelink('Command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
            Eyelink('Command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,BUTTON,FIXUPDATE,INPUT');
            % specify data contained in each recorded event
            Eyelink('Command', 'file_event_data = GAZE,GAZERES,HREF,AREA,VELOCITY');
            Eyelink('Command', 'link_event_data = GAZE,GAZERES,HREF,AREA,FIXAVG,NOSTART');
            % Within samples, these things are recorded for each sample (I think)
            Eyelink('Command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,RAW,AREA,HTARGET,GAZERES,BUTTON,STATUS,INPUT');
            Eyelink('Command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,HTARGET,STATUS,INPUT');
        
        
            % BOILERPLATE CONFIG - HIDE THIS IN FINAL.INI OR ELSEWHERE? 
        
        
            % SCREEN physical size of viewing area and dist to eye
            Eyelink('Command','screen_phys_coords = %d %d %d %d', ...
                -cfg.screen_visible_mm(1)/2, cfg.screen_visible_mm(2)/2, ...
                cfg.screen_visible_mm(1)/2, -cfg.screen_visible_mm(2)/2);
            Eyelink('Command', 'screen_distance = %d', cfg.screen_distance_mm);

            % Set gaze coordinate system. Set calibration_type after this call
            Eyelink('Command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, RectWidth(cfg.wrect)-1, RectHeight(cfg.wrect)-1);
            Eyelink('Command', 'calibration_type = HV5');
            % Allow a supported EyeLink Host PC button box to accept calibration or drift-check/correction targets via button 5
            Eyelink('Command', 'button_function 5 "accept_target_fixation"');
            % How much of screen area to use for calibration points
            Eyelink('Command','calibration_area_proportion 0.5 0.5');
        
            % Write DISPLAY_COORDS message to EDF file: sets display coordinates in DataViewer
            % See DataViewer manual section: Protocol for EyeLink Data to Viewer Integration > Pre-trial Message Commands
            % The screen_pixel_coords are mapped onto this coord system for drawing
            % commands. Convenient to use screen_pixel_coords here.
            Eyelink('Message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, RectWidth(cfg.wrect)-1, RectHeight(cfg.wrect)-1);
        
            % END BOILERPLATE CONFIG STUFF HERE
        end
    end
end