function [tf, sreturned] = animMgrSampleCallback(ind, t, ~, w, s)
%animMgrSampleCallback Callback for AnimMgr - animate a fade-out rectangle.
%   User data arg must be a struct with fields color, on, ramp, off, thick
%   thick is the line thickness for 'FrameRect'. If 0, 'FillRect' is used
%   instead. Rect is drawn at center of window w, with a fixed size
%   hardcoded below.


    if ind
        s.values = [s.values, t];
        [srcfactorOld, dstFactorOld, ~] = Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        color=s.color;
        if t < s.on
            color(4) = 0;
        elseif t < s.ramp
            color(4) = 1;
        elseif t < s.off
            color(4) = 1-(t-s.ramp)/(s.off-s.ramp);
            % The last time we are called, 
        else 
            color(4) = 0;
        end
        if s.thick
            Screen('FrameRect', w, color, s.rect, s.thick);
        else
            Screen('FillRect', w, color, s.rect);
        end
        Screen('BlendFunction', w, srcfactorOld, dstFactorOld);

        % draw text after blending turned off
        [x,y] = RectCenter(s.rect);
        y = y+3*RectHeight(s.rect);
        smsg = sprintf('%03d %5.2f alpha %5.4f', ind, t, color(4));
        DrawFormattedText(w, smsg, 'center', y, [0,0,0]);
        tf=true;
    else
        tf = false;   % ignored when ind==0
    end
    sreturned = s;
end
