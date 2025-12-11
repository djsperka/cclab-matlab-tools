# Misc Tools for Psychophysics experiments

## imageset

`imageset` provides a portable and flexible way to display images from a folder or a set of folders.

### Methods

#### imageset(root [, paramsFunc], options)

Input arguments:

- _root_ - root folder. Images are found in subfolders defined in SubFolders.
- _paramsFunc_ - (optional). Name of a function (which can be found with current path), or a path to a function (including function name, but not extension). This function should return a structure where the field names match any of the optional variables. The values of those fields are used in the construction of the object. 
- _SubFolders = SUBFOLDERS_. Nx2 cell array. First column is name of a subfolder (below _root_). Second column is a string to use in the key for images from this folder. The key for images in this folder is _folderkey/filebase_. There can be multiple subfolders. No combination of _folderkey/filebase_ can appear more than once in a single imageset.



I'm using the repo 'cclab-images' for examples below. 

The simplest way to use is to identify a folder where images reside. Subfolders are NOT searched!

```matlab
img = imageset('/home/dan/work/cclab/cclab-images/test');
```

To quickly check the contents of an imageset, open a window and call `flip()`. The texture is displayed at the center of the window, full size. 


```matlab
img.flip(windowID, 'R-1');
```


## SplitKbQueue

SplitKbdQueue Behaves like PTB KbQueue, for the case where one is using a single kbd for two queues - e.g. as a response device for the subject, and as a control device for the operator.

When running psychophysics experiments on Windows, one often uses a keyboard (or a response device that presents itself as a keyboard, like the MilliKey) to collect responses from the subject.

It may also be important that the experimenter is able to provide input, to pause/resume the experiment, quit, change parameters, etc. This presents a problem - the keyboard input must be scanned for responses (while ignoring experimenter input), and also for experimenter input (while ignoring subject responses). 

This class will control PTB's keyboard queue and present a split interface, as if there were multiple queues and devices present. 

### Filters and responses

To create a SplitKbQueue, you must provide a _filter_ and _responses_ for each queue. The _filter_ is a 1xN cell array, each element being a key label (see [KbName()](http://psychtoolbox.org/docs/KbName)). The _responses_ for a given _filter_ is, if not empty, a 1xN cell array of the value to be returned as the _response_ for that key. If _responses_ is empty for a given filter, then the PTB keycode is returned as a response value.

In my experiment, I use the keypad for responses. The center '5' indicates a "NO" response, which I'll want to represent as `0`. The other number keys '1','2','3','4','6','7','8','9' indicate a "YES" response, which I'll represent as `1`.

I'll also use the keyboard for experimenter input. The keys 's', 'q', 'd', and ' ' (space) will be represented by their keycodes. 

The filters and responses for this experiment are:

```matlab

filters =  { {'1', '2', '3', '4', '5', '6', '7', '8', '9'} ; {'s', 'q', 'd', 'space'}};
responses = { { 0,0,0,0,1,0,0,0,0 }; {} };

```

To instantiate the object, use the device index for the keyboard. On Windows, this is always 0 (I think this is the case). On linux or Mac the keyboard may have a different device ID. 

```
splitQ = SplitKbQueue(0, filters=filters, responses=responses);
```

### Using the queues

There is a single queue for each row of the `filters` used to create the object. To refer to any one queue, use the row number (referred to as `qind` below) corresponding to the filter and responses. To use a queue, you must first call `start()` - keystrokes are monitored and saved. 

#### start(qind)

Start monitoring keystrokes for the given queue. 

#### stop(qind) 

Stop monitoring keystrokes for this queue. The queue is not emptied. 

#### isempty(qind)

Are there any keystroke events in the queue? 

    tf = splitQ.isempty(qind);

#### response(qind)

Get the oldest response in the queue, if any.

    [isResponse, response, tResponse] = splitQ.response(qind)

The returned values are 
- isResponse - is this a response (1) or not (0)?
- response - the response value corresponding to the key
- tResponse - the time of the keypress

#### pop(qind)

Get the oldest entry in the queue. This may be more useful than `response()` when using the queue for user input, not responses. 

    [keycode, t] = splitQ.pop(qind);

The keyname entered is `KbName(keycode)`.

#### flush(qind)

Empty any entries currently in the queue. Does not start or stop queue. 




## makeWindow

Psychtoolbox's Screen function lets you open a window for displaying graphics. This function makes it a little easier to do this on my desktop when testing. 


```matlab


[windowIndex, windowRect, fullScreenRect] = makeWindow( resolution, screenID, 'side1', 'side2', color);


```


*resolution*: screen resolution in pixels: \[width, height\] 

*screenID*: PTB's screen identifier

*side1,side2*: for positioning the created window on your desktop. See the PTB function **AlignRect** for details. Allowed values for these are 'center', 'left', 'right',  'top', and 'bottom'. Using 'center', 'right' will put the window along the center of the right\-hand edge of your screen


*color*: PTB-style color, \[r,g,b\], where each value is between 0,1

The function returns these values:

*windowIndex*: the PTB window index to use in drawing commands

*windowRect*: PTB-style rectangle describing the window (left, top are both 0)

*fullScreenRect*: PTB-style rectangle describing the window within the full screen window


## pixdegcvt

The converter class, called ```pixdegcvt```, will perform conversions for a system with a given screen resolution, size, and eye\-screen distance (i.e. your experimental setup). 


Create the object like this:

```matlab
myconverter = pixdegcvt(screen\_rect\_pixels, screen\_size\_mm, screen\_distance\_mm);
```

where 

-  screen\_rect\_pixels is a PTB\-style rectangle representing your display area \- the window created with Screen 
-  screen\_size\_mm is \[width\_mm, height\_mm\] for the visible pixels in your screen 
-  screen\_distance\_mm is the eye\-screen distance  

### Methods

These methods do the conversions:

#### deg2pix

Convert a value from degrees to pixels \- a distance, or the size of a displayed graphic:

```
npixels = myconverter.**deg2pix**(distance\_in\_degrees);
```

#### pix2deg

Convert from pixels to degrees

    ndegrees = myconverter.**pix2deg**(npixels);

#### deg2scr

Convert an (x,y) coordinate in degrees to screen coordinates


    scr\_coords = myconverter.**deg2scr**(\[0,0\]);  % get screen coords of the center of screen

#### deg2mm

Convert a 'distance' in degrees to mm


    mm = myconverter.**deg2mm**(degrees);

### Example 

Set up values for the fixation point (position and diameter in degrees), the fixation point window, and the physical geometry of the screen and subject. 

#### Physical geometry

Our EEG booth has a screen with resolution 1920x1080. The viewable pixels cover an area that is 640x360mm. The subject eye is 900mm from the screen. For this example, I scale the screen geometry down by a factor of 4, and I display the window on the desktop screen in the middle of the right\-hand\-side. The _relative_ placement and size of stimuli will be the same as for the experiment as long as I use the same _degree_ coordinates. 

```matlab
% Screen resolution, 1/4 scale of our EEG booth geometry
screenResolutionPix = [480, 270];   % booth is [1920, 1080]
screenWHMM = [160, 90];             % booth is [640, 360]
screenDistanceMM = 225;             % booth is 900 or so;)

% my screen id is 0 - YMMV
screenID = 0;
```

#### Open window

We open a window, the use the rectangle representing the window, and the screen/subject physical dimensions to create a pixdegcvt object for converting between degrees, pixels, and screen coordinates. 

```matlab
% open window
[windowID, windowRect, ~] = makeWindow(screenResolutionPix, screenID, 'center', 'right');

% makeWindow returns a PTB rectangle (1x4 matrix, left,top,right,bottom). 
% Use that rect (which is in pixels), and physical dimensions to make
% a pixdegcvt object to convert between degrees and pixels in this system.
cvt = pixdegcvt(windowRect, screenWHMM, screenDistanceMM);
```


#### Draw fixation point

```matlab
% The coordinates here are in visual degrees. 
% Fixation point will be drawn at [4,-2], diameter 1 degree, color red.
fixptXYDeg = [4,-2];
fixptColor = [1,0,0];
fixptDDeg = 1;

% To draw an oval in PTB, create the box that contains it. 
% Get center point in screen coords:
xyScr = cvt.deg2scr(fixptXYDeg);

% get diameter in pixels
dPixels = cvt.deg2pix(fixptDDeg);

% make rect for fixpt
tmpRect = SetRect(0, 0, dPixels, dPixels);
fixptRect = CenterRectOnPoint(tmpRect, xyScr(1), xyScr(2));

% draw and flip
Screen('FillOval', windowID, fixptColor, fixptRect);
Screen('Flip', windowID);

```


#### Cleanup

Issue `sca` to close the window.


```matlab
sca;
```
