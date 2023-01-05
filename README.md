# cclab-matlab-tools

Matlab tools for CC lab rig DAQ machine. Uses the NiDAQ card to control the reward system, and also to generate TTL signals for synchronization.

These functions assume you have a NIZZZZZZ card. This is easily modified, provided matlab's DAQToolbox supports it (see cclabInitDIO.m). You can also use these functions without any DIO card - see cclabInitDIO() below. 

## Functions

> **cclabInitDIO(*type*)**

    Call this before you call either *cclabReward()* or *cclabPulse()*. The parameter *type* is a string, with characters indicating which parts of the DIO system will be used.  
    
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
 
 
 > **cclabReward(*rewardMS, count=1, gapMS=50*)**

    Issue reward of sizeMS millisecons. If count>1, then count rewards are delivered, with capMS milliseconds between each. This function is synchronous - it will not return until the reward has been fully delivered. 
