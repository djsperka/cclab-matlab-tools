# cclab-matlab-tools

Matlab tools for CC lab rig DAQ machine. Uses the NiDAQ card to control the reward system, and also to generate TTL signals for synchronization.

## How to use these tools

 1. Make sure tools are in your Matlab path.
 2. In your script, initialize with cclabInitDIO(type), where *type* is a string, with characters indicating which parts of the DIO system will be used.
 
     - Reward system: 'j' for DIO output of signal (will fail if no nidaq card), 'n' writes to console only, no actual reward (for dev on machine without nidaq  card).
     - Digital out: both channels A and B are initialized if 'A' or 'B' are present (will fail if no nidaq card present). Without 'A' or 'B', will write to console only, no actual TTL output (for dev on machine without nidaq card).
     
     **Examples**  
       
     *cclabInitDIO('jAB')* will initialize the rig machine to use the pump and digital out channels A and B.  
     *cclabInitDIO('n')* will initialize desktop (any machine w/o nidaq card). Calls to *cclabReward()* and *cclabPulse()* only produce console output.  
 

3. To issue reward, call cclabReward()
4. To generate TTL pulse, call cclabPulse()
5. At end of script, call cclabCloseDIO(). 
