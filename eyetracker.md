# Using the ASL Eyetracker

## eyetracker

`eyetracker` encapsulates the ASL eyetracker functions for psychophysics expts. 

The ASL eyetracker can be used in MATLAB experiments. The TCP/IP connection between the Matlab and eyetracker computers is used for communications. Once connected to the tracker, the Matlab script may switch the tracker to _setup mode_, with the Matlab script blocking until the operator clicks the __Exit Setup__ button on the ASL GUI screen. While in setup, the tracker may be adjusted, calibrated, validated, etc. 

In order to instantiate the eyetracker class, you will need to know the physical geometry of your system, and have a PTB window open. 

### Methods

#### [tracker] = eyetracker(mode, screen_dimensions, screen_distance, name, window\[, DoSetup=true|false\]\[, Verbose = true|false\])

- _mode_: `1|0`, 1 for dummymode, 0 for real tracking with a subject.
- _screen\_dimensions_: `[width_mm,height_mm]`, size of visible area of pixels
- _screen\_distance_: `distance_mm`, eye-screen distance
- _name_: name for eyetracker data file. Max 8 characters, no dot or extension.
- _window_: existing window pointer of display screen
- _DoSetup=true|false_: switch tracker into setup mode when instantiated. Default is `true`.
- _Verbose=true|false_: wordy messages. Default is 'false'.

When first instantiated, the class will establish a connection to the tracker. You will see the green status bar in the upper-right corner of the tracker screen change its display status to _Connected_. 

If `DoSetup` is `true`, the tracker is switched to __Setup Mode__, and the experimenter may calibrate and/or validate. The Matlab script is blocked until the operator clicks __Exit Setup__. 

The tracker operates in a streaming mode whenever it is _recording_ (see `start_recording()` below). It is also saving tracking data into a data file on the tracker machine when _recording_.

#### szBytes = tracker.receive_file()
#### szBytes = tracker.receive_file(name_or_path, is_path)

Copy the edf file (eyetracker data) created on the eyetracker computer, to the matlab computer. The first form, with no args, copies the file with its original name to the current directory. The second form allows you to change the filename and/or the folder where it is copied. 

If `ispath=1`, the the file with its original name are copied to the path in `name_or_path`. If `is_path=0`, then the filename is changed, but it is copied to the current folder. 

#### tracker.command(format, args)

This issues a COMMAND command to the tracker. See Eyelink docs for more details. The `format` and `args` work as in C `printf`.

#### tracker.message(format, args)

This writes a MSG into the EDF data file. The `format` and `args` work as in C `printf`.

#### tracker.drift_correct(x, y)

Draw something at `(x,y)`, then call this to initiate drift correction. This function blocks Matlab until it exits. Once this is called, ask the subject to look at the point, and hit _Accept Fixation_ on the tracker screen to accept the fixation. The tracker will perform a drift correction and automatically return control to matlab.

#### tracker.do_tracker_setup()

Switch the tracker into _Camera Setup_. Operator can adjust, calibrate, validate. Blocks Matlab while running. Returns control to Matlab when you hit _Exit Setup_. 

#### tracker.start_recording()

Switch tracker into streaming mode. Tracks continuously, records to file. 

#### tracker.start_recording()
#### tracker.offline()

Switch tracker OUT OF streaming mode. 

#### tracker.always_in_rect(bAlways)

If `bAlways=True`, put tracker in a mode where _all_ calls to `is_in_rect()` will return True, regardless of actual eye position. This is useful when testing without a subject present. __Be cautious using this!__ Turn this behavior off by calling with `bAlways=False`. 

#### [tf] = tracker.is_in_rect(rect)

Is the current eye position in the (PTB-style) rectangle?

#### [x,y,tf] = tracker.eyepos()

Get current eye position, screen pixel coordinates. `tf` is `true` when the eye signal is valid, `false` otherwise. 

#### [S] = tracker.saccade(R)

Check if the eye position is in one of the rectangles in `R`. `R` should be `4xN`, where each column is a PTB rectangle. The return value `S` is a `1xN` logical array, indicating if the eyepos is in each of the rectangles in `R`. 

This is useful for checking a saccade to one of a set of images. Put the rectangle for each image into a column of `R`, then call. 

### Methods for drawing on the eyetracker screen

These methods draw on the eyetracker GUI screen. Don't call these functions in a time-critical place, they can be very slow!

#### tracker.clear_screen(c)

Clear tracker screen to a color. The value `c` is an int denoting the color (0 is black). 

#### tracker.draw_box(x1,y1,x2,y2,c)

Draw a box on the tracker screen with corners `(x1,y1)` and `(x2,y2)`.

#### tracker.draw_cross(x,y,c)

Draw a cross '\+'-sign on the tracker screen. 
