## CCLab A/D IO sytem

The software and hardware setup for the cclab I/O system used for analog (joystick) and digital (sync marker pulses, reward) signals is described here.  

The DAQ machines use an A/D card - in our case the **NI PCIe-6351** card - to do things like send sync pulses to recording system(s), control the reward system, triggering other hardware. Software that uses the A/D card has two problems (at least) to deal with. 

First, the DAQ machines in the lab (possible new, different, future machines) are used differently. One machine has a joystick and the other does not. One machine has 5 digital channels connected, the other has only 4. These differences tend to increase over time as new devices are integrated into each rig, old ones are removed, etc. Software should be able to adapt to these differences with little or no intervention on the part of the user. 

Second, the user should be able to use the software on *non-DAQ machines*, like a laptop or their desktop, for testing and development, but lack the **NI PCIe-6351** card. I've created a *dummy mode*, where all the reward, digout, and joystick functions work, and don't require that you comment out pieces of code to allow yourself to do development somewhere other than the rig itself.

## Initialization

To initialize the I/O functions, call *cclabInitDIO*. Its single (optional) argument is a string, which may be one of the following:

* A full path to a configuration file.
* The basename of an existing configuration file in the *cfg* folder, e.g. *'rig-left'*, *'rig-right'*, *'dummy'*. 
* The old strings used, e.g. 'jAB'. These will get the default config *'rig-right'*.
* The string *'dummy'*, which allows the I/O functions to work on machines without the correct **NI** hardware. 

Typical usage looks like this:

```
% Initialize DIO system
cclabInitDIO('rig-right');

% ... do experiment stuff ...

% display stimulus and output sync
Screen('Flip');
cclabPulse('A');

% ... more experiment stuff ...

% reward time
cclabReward(200);

% all done
cclabCloseDIO();
```

## Functions

### **cclabInitDIO(*config*)**

Call this before you call either *cclabReward()*, *cclabPulse()*, or cclabJoystickPos()*.  
The parameter *config* is a string, and is tested in this order:

* is it the path to an existing file? If so, this file will be opened and read for a configuration.
* is it the *basename* of a file that exists in the subfolder *cfg/*, relative to the folder where this script lives. Do not include the *.txt* extension in this argument.
* is it the word 'dummy'? If so, use the *cfg/dummy.txt* config.
* if none of the above (e.g. 'jAB'), then use the default *cfg/rig-right.txt*
     
Current usage on *rig-right*:
    
```
cclabInitDIO('jAB');
```

This is the same as:

```
cclabInitDIO('rig-right');
```
    
For use on your desktop/laptop:
    
```
cclabInitDIO('dummy');
```
    
A global struct *g_dio* is created in your workspace, which the other toolbox functions will access. Do not modify the contents of this struct. The struct is removed (and all resources released) when you call *cclabCloseDIO()*.
 
 
### **cclabReward(*msec*, *n*=1, *gap*=50)**

    Deliver reward, open valve for 'msec' milliseconds, n times, with 'gap' ms between rewards.
    This is a synchronous function, it will block Matlab until reward is done. Must call cclabInitDIO before calling this function. 

### **cclabPulse(*which*, *width*=1)**

    Output TTL pulses on a dig output line(s). Must call cclabInitDIO before calling this function. *which* can be any of 'ABCDE'. The BNC connectors are labelled with these letters. Multiple lines can be pulsed simultaneously. Note that this is a blocking function -- only a single call to *cclabPulse* can be active at one time. 
    
    *cclabPulse('A');* - output a single 1ms pulse on dig output line 'A'. 
    *cclabPulse('B', 0.1)* - output a single pulse of width 0.1ms on line 'B'

### **cclabJoystickPos()**

Get current joystick position. Returned as one of 1, 0, -1. The numbers correspond to the calibration range configured for the joystick axes, and indicate things like *left/center/right* or *forward/center/back* for the instantaneous joystick position. 


### **cclabCloseDIO()**

    Releases all resources. Call at end of script. 

    
## Configuration File Format

The configuration file is a series of lines, one per input or output channel. Each line is a tab-separated series of 4-6 parameters. 

The reward system is configured with three paramters. The first two, '*j reward*' indicate this is the reward system. The last parameter can be *'ni'* to use the **NI** hardware, or *'none'* to use a dummy mode, without reward hardware. When cclabReward is called and the reward system is configured in dummy mode, a message is printed to the screen, but no reward occurs.

```
j	reward	ni
```

The digital output channels are configured with an extra parameter that specifies the I/O line(s) used when configuring. The I/O line parameter is passed directly to the DAQ Toolbox configuration functions, so the value(s) used for this parameter will depend on the particular card being used, and the particular *I/O lines* being used on that card. These config lines look like the following for the *'rig-left'* configuration:

```
A	digout	ni	port0/line4
B	digout	ni	port0/line3
C	digout	ni	port0/line5
D	digout	ni	port0/line7
```

Here, the first parameter on each line (*A*, *B*, ...) is used in the software to identify which channel to send a pulse on. The second parameter indicates that it is a *digout* channel. The third parameter is *'ni'* for the **NI** card, or *'none'* when no hardware is present. The last parameter is passed directly to the *addoutput* function as the *channelID*.

The configuration above specifies 4 digital lines that can be used in a call to *cclabPulse()*:

```
> cclabPulse('AB');	% put a default pulse on lines A and B
> cclabPulse('C');	% pulse line 'C'
```

Finally, the joystick is configured similarly

```
H	joystick	ni	ai0	2.901	2.092
V	joystick	ni	ai1	2.901	2.092
```

This line configures a joystick axis. The 'H' and 'V' are just labels. Results from  *cclabJoystickPos* are returned in the same order that the channels are specified, not as results specific to either a horizontal or vertical axis. 

The fourth parameter *'ai0'* is the analog input line that the joystick output voltage is connected to. The last two parameters are voltage levels, and are interpreted in this way: Suppose you started with the joystick at its neutral center position. Now, move the joystick in the direction you want to call "+1" - let's just say that's *left*. Move the joystick to the *minimum displacement* that you want to call *left* - anything this far *or further* will be considered *left*, and a value of *1* is returned for the axis. Measure the output voltage for that joystick position. Next, move the joystick slightly in the *other direction*. Here, move the joystick to the *minimum displacement* that you want to call *right*, and measure that voltage. The two voltages divide the full range of the joystick's output into three ranges. 

This procedure allows for different wiring of joysticks - where a movement *right* may result in a *higher* or *lower* voltage output, depending on the wiring. The algorithm checks whether the voltage measured is in between the two parameters (this is *center*, and the return value is *0*). If the voltage measured is between the first (second) of the two parameters and the adjacent extreme (either 0V or 5V), then the return value is *1* (*-1*).

The configuration above is for the currently wired joystick. I've got it so that the no-touch voltage is mid-range, about 2.6V. Movements to the *left* (when joystick is oriented as it is in the chairs) give positive voltage displacements. I measured the voltage for a small joystick movement to the left - that measurement was 2.901V. Same for a small joystick movement to the right - that measurement was 2.092V. When cclabJoystickPos is called, the voltage is measured for each configured joystick axis. For the above, given measured voltage V, 

* if V >= 2.901, return 1
* if V < 2.092, return -1
* otherwise, return 0

