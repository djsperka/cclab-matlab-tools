function [ok,response] = intermission(window, q, qind, str, textsize)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    timeout = 10;
    oldtextsize = Screen('TextSize', window);
    Screen('TextSize', window, textsize);
    Screen('Flip', window);
    DrawFormattedText(window, str, 'center', 'center', [0, 0, 0]);
    Screen('Flip', window);
    q.start(qind);
    t0 = GetSecs;
    ok = false;
    response = -999;
    while ~ok && (GetSecs-t0)<timeout
        [ok, response, ~] = q.response(qind);
    end
    Screen('TextSize', window, oldtextsize);
    Screen('Flip', window);
end