# cclab-matlab-tools

Matlab tools for CC lab rig DAQ machine. Uses the NiDAQ card to control the reward system, and also to generate TTL signals for synchronization.

## How to use these tools

1. Make sure tools are in your Matlab path.
2. In your script, initialize with cclabInitDIO(type).

#Type# is a string, with characters indicating which parts of the DIO system will be used.
- 'j' - Use reward system
- 'n' - Do not use reward system (calls to cclabReward() will still work, but will write to screen only)
- 'A' or 'B' - use the digital I/O channels. These channels are all-or-none, so using 'A', 'B', or 'AB' are equivalent - both of the digital output channels are used. 

3. To issue reward, call cclabReward()
4. To generate TTL pulse, call cclabPulse()
5. At end of script, call cclabCloseDIO(). 
