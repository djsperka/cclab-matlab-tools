## LabHackers MilliKey devices in Matlab/Linux

Assume you have working Matlab and PTB,  as this relies on the PsychHID functions, and will only work on linux. 

### Install the Xorg conf file

*(Assuming you are running Ubuntu 20.04, should work with debian variants)* 

Copy the file *99-millikey-float.conf* file to the folder **/usr/share/X11/xorg.conf.d/**

You will have to restart your Xorg instance (log out and log back in - don't have to reboot) for the change to take effect. 

If you do **not** copy this file an restart the Xorg instance, then your MilliKey device will be treated as a keyboard by X. That means any keypresses are
used by the system as if you typed at your keyboard. This wouldn't be good if the device were used as a response box in an experiment, unless all keyboard input were ignored.
 
This file tells the Xorg server to leave the device as a *floating slave* keyboard, and keypresses on it are not merged with keypresses from your regular keyboard. 
It works with Xorg's hotplugging system, so no additional configuration is needed. When you plug in a MilliKey device, the xinput list looks like this:


```shell
dan@bucky:~/work/cclab/cclab-matlab-tools$ xinput -list
⎡ Virtual core pointer                    	id=2	[master pointer  (3)]
⎜   ↳ Virtual core XTEST pointer              	id=4	[slave  pointer  (2)]
⎜   ↳ Logitech USB Trackball                  	id=10	[slave  pointer  (2)]
⎜   ↳ LabHackers MilliKey                     	id=13	[slave  pointer  (2)]
⎣ Virtual core keyboard                   	id=3	[master keyboard (2)]
    ↳ Virtual core XTEST keyboard             	id=5	[slave  keyboard (3)]
    ↳ Power Button                            	id=6	[slave  keyboard (3)]
    ↳ Power Button                            	id=7	[slave  keyboard (3)]
    ↳ Sleep Button                            	id=8	[slave  keyboard (3)]
    ↳ Dell Dell USB Keyboard                  	id=9	[slave  keyboard (3)]
    ↳ LabHackers MilliKey (keys)              	id=12	[slave  keyboard (3)]
∼ LabHackers MilliKey                     	id=11	[floating slave]
```

### Using the MilliKey in Matlab

Once the MilliKey device is plugged in, you can use it in Matlab as follows. 

1. Get the device index. This will be the 'device index' parameter passed to the **KbXXX()** functions. Note that it is a different value than the 'id' from *xinput*. 

    ```
    >> ind = cclabGetMilliKeyIndices()
    
        ind =
       
         9
    ```

2. Create a queue. There is no return value. Functions that access and control the queue use the device index. 

    ```
    >> PsychHID('KbQueueCreate', ind);
    ```

3. Start the queue. Once the queue is started, any keypresses will be captured and saved in the queue until it is flushed.

    ```
    >> PsychHID('KbQueueCreate', ind);
    ```

4. Stop the queue. Eventually you should stop the queue. New events will not be added to the queue, but the contents of the queue when this is called are left untouched. 

    ```
    >> PsychHID('KbQueueCreate', ind);
    ```

### Getting events from the queue

Each keypress and key*release* are recorded as events. The event type (keypress or release), time (consistent with GetSecs() clock), which key was pressed/released, are all part of the event structure. Each keypress is registered as two consecutive events, one when the key is *pressed*, and another when the key is *released* (when event.Pressed is 0).

A simple way to iterate over all *available* events is shown below. The queue can be queried for events even if it is running! 

```
   while KbEventAvail(ind)
       [event, nremaining] = KbEventGet(ind);
       if event.Pressed
           t1 =  event.Time;
       else
           t2 = event.Time;
           fprintf('keycode %d, down %f\n', event.Keycode, t2-t1);
       end
   end

```
    
