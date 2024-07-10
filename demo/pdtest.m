function pdtest(n, durationMS, screen_number)
%pdtest flash lower right corner of screen n times.
%   Detailed explanation goes here

Screen('Preference', 'SkipSyncTests', 1);
% PsychImaging('PrepareConfiguration');
% PsychImaging('AddTask', 'General', 'FloatingPoint32Bit');
% PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');
% 
%[wp, rect] = Screen('OpenWindow', 1, [127 127 127], [2160 1140 2560 1440]);

cclabInitDIO('rig-left');
[wp, ~] = Screen('OpenWindow', screen_number, [127 127 127]);
WaitSecs(3);
tstart = tic;
for i=1:n
    if mod(i,2)
        Screen('FillRect', wp, 255*[1 1 1]);
    else
        %Screen('FillRect', wp, 127*[1 1 1]);
        Screen('FillRect', wp, [0,0,0]);
    end        
    %Screen('FillRect', wp, 255*[1 1 1]);
    Screen('Flip', wp);
    cclabPulse('A');
    if (durationMS > 0)
        WaitSecs(durationMS/1000);
    end
end
t=toc(tstart);
Screen('CloseAll');
rate=n/t;

disp(rate);

cclabCloseDIO();