function [windowPtr,windowRect, mywr] = makeWindow(wh,screen,a1,a2,bkgd)
%makeWindow(wh,screen,a1,a2) Make a window in the given screen,with given
%size. Placement uses 'a1' and 'a2' - see AlignRect().
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
%   The bkgd color should have values between 0-1, default is mean gray
%   [0.5,0.5,0.5].

    arguments
        wh (1,2) {mustBeNumeric}
        screen (1,1) {mustBeInteger,mustBeGreaterThanOrEqual(screen,0)}
        a1 {mustBeText,mustBeMember(a1,{'center','left','right','top','bottom'})} = 'center'
        a2 {mustBeText,mustBeMember(a2,{'center','left','right','top','bottom'})} = 'center'
        bkgd (1,3) {mustBeNumeric,mustBeLessThanOrEqual(bkgd,1),mustBeGreaterThanOrEqual(bkgd,0)} = [.5, .5, .5]
    end
    PsychDefaultSetup(2);
    r=SetRect(0,0,wh(1),wh(2));
    sr=Screen('Rect', screen);
    mywr=AlignRect(r,sr,a1,a2);
    [windowPtr, windowRect] = PsychImaging('OpenWindow', screen, bkgd, mywr);
end

