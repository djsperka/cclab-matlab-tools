function [windowPtr,windowRect, mywr] = makeWindow(wh,screen,a1,a2)
%makeWindow(wh,screen,a1,a2) Make a window in the given screen,with given
%size. Placement uses last two args - see AlignRect().
%   Convenience function for creating a PTB window. Placement of the
%   window uses the values 'a1' and 'a2'. These are passed directly to
%   AlignRect to determine where on the screen the window is placed. The
%   PTB function PsychDefaultSetup(2) is called. The window index, the
%   window rect, and the rect defined within the full screen, are returned.
%   For example, the call 
% 
%   [w, wrect, bigwrect] = makeWindow([800, 600], 0, 'center', 'right');
% 
%   creates a window on the right-hand-side of my screen (I have only one
%   screen so it is screen 0), centered between top and bottom. The value
%   of wrect is [0, 0, 400, 300]. The value of bigwrect is 
%   [1520, 450, 1920, 750] (my screen size is 1920x1080). 
    PsychDefaultSetup(2);
    r=SetRect(0,0,wh(1),wh(2));
    sr=Screen('Rect', screen);
    mywr=AlignRect(r,sr,a1,a2);
    [windowPtr, windowRect] = PsychImaging('OpenWindow', screen, [.5 .5 .5], mywr);
end

