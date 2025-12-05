# Misc Tools for Psychophysics experiments

## pixdegcvt - Convert between pixels and degrees

Does deg <--> pixel conversions for a given screen/subject setup, 
and coordinate transformations from eye space (center of screen 
is origin in degrees, positive degrees up & right) to screen space
(origin top right, positive pixels down).

Unsophisticated conversion. Assumes small angles, because we're
taking tan(theta) = theta, and we don't care how big the number
really is. 

Example [here](demo/demo_pixdegcvt.md).

## beeper/twotonebeeper - Make sounds 

## responder - get responses from a millikey

