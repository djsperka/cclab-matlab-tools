# cclab-matlab-tools

Matlab tools for CC lab rig DAQ machine. Uses the NiDAQ card to control the reward system, and also to generate TTL signals for synchronization.

These functions assume you have a NIZZZZZZ card. This is easily modified, provided matlab's DAQToolbox supports it (see cclabInitDIO.m). You can also use these functions without any DIO card - see cclabInitDIO() below. 

Typical usage looks like this:

```
% Initialize DIO system
cclabInitDIO('jAB');

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

### **cclabInitDIO(*type*)**

Call this before you call either *cclabReward()* or *cclabPulse()*.  
The parameter *type* is a string, with characters indicating which parts of the DIO system will be used.  
    
For the reward system, use a 'j' for DIO reward system output, 'n' for dummy output to the screen.  
    
For the two TTL output channels (called **A** and **B**, and labelled thus on the breakout box). If you use either 'A' or 'B' in your *type* argument, the DIO system will be configured for TTL output. The system is configured for dummy output if you omit both 'A' and 'B'.
    
For use on the DAQ rig, call with 'jAB' argument to use real DIO:
    
```
cclabInitDIO('jAB');
```
    
For use on your desktop/laptop:
    
```
cclabInitDIO('n');
```
    
A global struct *g_dio* is created in your workspace, which the other toolbox functions will access. Do not modify the contents of this struct. The struct is removed (and all resources released) when you call *cclabCloseDIO()*.
 
 
 ### **cclabReward(*msec*, *n*=1, *gap*=50)**

    Deliver reward, open valve for 'msec' milliseconds, n times, with 'gap' ms between rewards.
    This is a synchronous function, it will block Matlab until reward is done. Must call cclabInitDIO before calling this function. 

### **cclabPulse(*which*, *width*=1)**

    Output TTL pulses on a dig output line(s). Must call cclabInitDIO before calling this function.  
    
    *cclabPulse('A');* - output a single 1ms pulse on dig output line 'A'. 
    *cclabPulse('B', 0.1)* - output a single pulse of width 0.1ms on line 'B'

### **cclabCloseDIO()**

    Releases all resources. Call at end of script. 
