function [keyCode, keyPressed, tEvent] = checkKbQueue(kbindex,press)
%checkKbQueue Scans the event queue for 'kbindex' looking for the first 
% occurrence of a key press event (if press==true) or a key release event
% (if press==false - this is the default). 
%   If an event is not found, the keyCode returned will be zero. The time
%   tEvent will be <0 in that case.

    arguments
        kbindex (1,1) {mustBeNumeric}
        press (1,1) {mustBeNumericOrLogical} = false
    end
    keyPressed = false;
    keyCode = 0;
    tEvent = -1;
    bquit = false;
    
    % Fetch events until we find a press/release 
    
     while ~bquit && KbEventAvail(kbindex) 
        [event, ~] = KbEventGet(kbindex);
        if event.Pressed == press
            keyCode = event.Keycode;
            tEvent =  event.Time;
            keyPressed = event.Pressed;
            bquit = true;
        end
     end
end
