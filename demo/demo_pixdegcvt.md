
# pixdegcvt \- pixel\-degree conversions

In psychophysics experiments, common parameters are specified in  *visual degrees* in a system where the subject eye position is at the origin. The size of a stimulus to be displayed, or the position in the visual field where it is to be placed, will often be specified in degrees. But to make practical use of them we must convert *visual degrees* in this system to *pixels* on the display screen. The conversions to do this are simple, and can be done in several ways. I've created a matlab class that can do these conversions for you. 

## pixdegcvt

The converter class, called ```pixdegcvt```, will perform conversions for a system with a given screen resolution, size, and eye\-screen distance (i.e. your experimental setup). 


Create the object like this:


myconverter = pixdegcvt(screen\_rect\_pixels, screen\_size\_mm, screen\_distance\_mm);


where 

-  screen\_rect\_pixels is a PTB\-style rectangle representing your display area \- the window created with Screen 
-  screen\_size\_mm is \[width\_mm, height\_mm\] for the visible pixels in your screen 
-  screen\_distance\_mm is the eye\-screen distance  

There are a few methods to do the conversions:

### deg2pix

Convert a value from degrees to pixels \- a distance, or the size of a displayed graphic:


&nbsp;&nbsp;&nbsp;&nbsp; npixels = myconverter.**deg2pix**(distance\_in\_degrees);

### pix2deg

Convert from pixels to degrees


&nbsp;&nbsp;&nbsp;&nbsp; ndegrees = myconverter.**pix2deg**(npixels);

### deg2scr

Convert an (x,y) coordinate in degrees to screen coordinates


&nbsp;&nbsp;&nbsp;&nbsp; scr\_coords = myconverter.**deg2scr**(\[0,0\]);  % get screen coords of the center of screen

### deg2mm

Convert a 'distance' in degrees to mm


&nbsp;&nbsp;&nbsp;&nbsp; mm = myconverter.**deg2mm**(degrees);

## Example 

Set up values for the fixation point (position and diameter in degrees), the fixation point window, and the physical geometry of the screen and subject. 


   Our EEG booth has a screen with resolution 1920x1080. The viewable pixels cover an area that is 640x360mm. The subject eye is 900mm from the screen. 


   For the example below, I scale the screen geometry down by a factor of 4, and I display the window on the desktop screen in the middle of the right\-hand\-side.

```matlab
% Screen resolution, 1/4 scale of our EEG booth geometry
screenResolutionPix = [480, 270];   % booth is [1920, 1080]
screenWHMM = [160, 90];             % booth is [640, 360]
screenDistanceMM = 225;             % booth is 900 or so;)

% my screen id is 0 - YMMV
screenID = 0;

% The coordinates here are in visual degrees. 
% Fixation point will be drawn at [4,-2], diameter 1 degree, color red.
fixptXYDeg = [4,-2];
fixptColor = [1,0,0];
fixptDDeg = 1;

% Fixation window will a square be 3 degrees each side. 
% Make it blue, 2 pixels thick
fixationWindowDeg = 3;
fixationWindowColor = [0, 0, 1];
fixationWindowPenWidth = 2;

```
# Now do stuff

   We open a window, the use the rectangle representing the window, and the screen/subject physical dimensions to create a pixdegcvt object for converting between degrees, pixels, and screen coordinates. 

```matlab
% open window
[windowID, windowRect, ~] = makeWindow(screenResolutionPix, screenID, 'center', 'right');

% makeWindow returns a PTB rectangle (1x4 matrix, left,top,right,bottom). 
% Use that rect (which is in pixels), and physical dimensions to make
% a pixdegcvt object to convert between degrees and pixels in this system.
cvt = pixdegcvt(windowRect, screenWHMM, screenDistanceMM);

% Now convert fixation diameter from degrees to pixels
fixptDPixels = cvt.deg2pix(fixptDDeg);

% Get the fixation point position in screen coordinates - the coordinates
% used in PTB drawing functions. PTB uses 0,0 at the upper left corner
% of the window. Positive X is to the right, but positive Y is down!
fixptXYScr = cvt.deg2scr(fixptXYDeg);

% Make a rectangle centered at fixpt position, each side fixationWindowDe
% This rectangle can be used to draw a rectangle with Screen('FillRect') or
% Screen('FrameRect').
fixationWindowPix = cvt.deg2pix(fixationWindowDeg);
tmpRect = SetRect(0, 0, fixationWindowPix, fixationWindowPix);
fixationWindowRect = CenterRectOnPoint(tmpRect, fixptXYScr(1), fixptXYScr(2));

```
# Draw and Flip
```matlab
% This class is a simple fixation point class. 
fixpt = FixationPoint(fixptXYScr, fixptDPixels, fixptColor);
fixpt.draw(windowID);

% This class is a simple rectangle class. 
rectangle = Rectangle(rect=fixationWindowRect, color=fixationWindowColor, penwidth=fixationWindowPenWidth);
rectangle.draw(windowID);
Screen('Flip', windowID);

```
# Cleanup
```matlab
sca;
```
