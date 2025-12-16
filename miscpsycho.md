# Misc Tools for Psychophysics experiments

## imageset

`imageset` provides a portable and flexible way to display images from a folder or a set of folders.

### Methods

#### imageset(root [, paramsFunc], options)

Input arguments:

- _root_ - root folder. Images are found in subfolders defined in SubFolders.
- _paramsFunc_ - (optional). Name of a function (which can be found with current path), or a path to a function (including function name, but not extension). This function should return a structure where the field names match any of the optional variables. The values of those fields are used in the construction of the object. 
- _SubFolders = SUBFOLDERS_. Nx2 cell array. First column is name of a subfolder (below _root_). Second column is a string to use in the key for images from this folder. The key for images in this folder is _folderkey/filebase_. There can be multiple subfolders. No combination of _folderkey/filebase_ can appear more than once in a single imageset.
- _Extensions = EXTENSIONS_. 1xN cell array of file extensions to include. Default is `{'.bmp', '.jpg', '.png'}`
- _OnLoad = FUNCTION\_HANDLE_. A processing function that is run on each image as read by imread(). This function should accept a single image and return a single image. Default is a no-op (deal()). 
- _MaskParameters = MASK\_ARRAY_. An array of parameters for a simple mask. If the array has a single element, [P], the image will be resized to PxP pixels. An array with three `[a,b,c]` elements will have the image blended with the background, using a circular mask which is the product of two masks: the first has a radius `a`: ```exp(-0.5 * r\*\*2/c\*\*2)```. The second is a `1` inside of radius `r1`, and then is a linear ramp down to `0` at radius 'a' (and zero at larger radii). The net effect is a circular image faded to the background at r=`a`. 
- _Bkgd = [a,b,c]_. Background color to use. Default is `[0.5,0.5,0.5]`. This applies when using the MaskParameters. Also if you use the texture key 'BKGD'. 
- _ShowName = 1|0_. Default is `false`. For testing, will show name of image on top of texture. Must have image processing toolbox.
- _Lazy = true|false_. Default is `false`. If true, images are not loaded until they are actually needed. The default is false (OK for our imagesets, 400 images `256x256`.)

Each subfolder in _SUBFOLDERS[:,1]_ is searched for images with _EXTENSIONS_. Any that are found are loaded (unless `Lazy=true`) and given a _key_. The corresponding _folder key_ value in the second column of _SUBFOLDERS_ is used with the _file key_ (the basename of the image file) to form a key for the image: _folder key/file key_. 

For example, we put high salience black and white images in a subfolder called _bw_, and low salience texturized version of the same images into a subfolder called _tex_. The images are named with a digit from 1-100. Our `Subfolders` argument looks like this:

```matlab
Subfolders = { 'bw', 'H'; 'tex', 'L'};
```

In the subfolder _bw_, images _1.bmp, 2.bmp, ..., 99.bmp, 100.bmp_ are loaded and given keys _'H/1', 'H/2', ..., 'H/99', 'H/100'_. Similarly, subfolder _tex_, which has images with the same filenames (each image being the texturized version of its original in subfolder _bw_), will have its images given keys _'L/1', 'L/2', ..., 'L/99', 'L/100'_. 


#### [textureID] = texture(w, key[, PreProcessFunc=func])

Creates a texture using the image having key `key`. If a `PreProcessFunc` is given, it should accept an image as input and should return an image. The default is `deal` (a no-op). The `textureID` returned should be used in calls to `Screen('DrawTexture', ...)` or `Screen('DrawTextures', ...)`. A `textureID` can be used multiple times, but only on the window used when created here. The texture also uses resources, so if you display many textures, you should eventually free them with `Screen('Close', textureID)`. 

#### [tf] = is_key(key)

Returns true (false) if the key is found (is not found) in the imageset. 

#### [rect] = rect(key)

Returns a PTB rectangle representing the size of the image with key `key`. 

#### flip(w, key[, PreProcessFunc=func])

For testing, will display image `key` at the center of window `w`. The image is preprocessed by `func`, before the texture is created, if given.

#### mflip(w, keys[, PreProcessFunc=func])

Same as `flip()`, but works with multiple images. Pass keys as a cellstr, e.g.: `{'key1', 'key2', 'key3'}`. Will attempt to fit all textures onto screen, but will not try that hard. Don't rely on this in an experiment - testing only! 

#### [fname] = filename(key)

Return the full pathname for the image file with key `key`.

#### [image] = get_image(key)

Return the image loaded (whatever was returned by imread) for `key`.

#### [keys] = keys(regex)

Returns a cell array with all keys that match the regular expression `regex`. This is the string of a regex, not a compiled regular expression. 

### Methods (static)

These are utilities I use when creating sets of trials that have lists of image keys. 

#### [key] = imageset.make_key(folder_key, file_key)

Creates a key using the given folder and file key. Nothing special, just contatenate the string folder and file keys with a '/' sandwiched in between. Will work with cell arrays of folder and/or file keys. Special case when _folder_key_ is `'*'`, the key returned is `'BKGD'`. 

#### [key] = imageset.make_key(folder_key, file_key)

Same as `imageset.make_key`, but for lists of keys.

#### [folder_key, file_key] = imageset.split_key(key)

Split the given key back into its parts. 



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
