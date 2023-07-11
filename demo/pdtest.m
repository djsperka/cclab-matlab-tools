function [outputArg1,outputArg2] = pdtest(n, durationMS, gapMS)
%pdtest flash lower right corner of screen n times.
%   Detailed explanation goes here

Screen('Preference', 'SkipSyncTests', 1);
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'FloatingPoint32Bit');
PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');

[wp, rect] = PsychImaging('OpenWindow', 0, [127 127 127], [2160 1140 2560 1440]);

for i=1:n
    Screen('FillRect', wp, 255*mod(i,2)*[1 1 1]);
    Screen('Flip', wp);
    WaitSecs(durationMS/1000);
end

Screen('CloseAll');
