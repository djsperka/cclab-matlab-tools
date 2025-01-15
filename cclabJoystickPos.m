function [joypos joyvolts] = cclabJoystickPos()
%cclabJoyPos Get current joystick position. 
%   Read joystick axes, return L=1, C=0, or R=-1

    joypos = [];
    joyvolts = [];
    
    if ~cclabJoystickIsReady
        error('Joystick not initialized.');
    end
    
    global g_dio
    
    if ~isempty(g_dio.joystick.daq)
    
        if g_dio.joystick.device == "ni"
            % read analog inputs. These are returned as a timetable, with a single
            % row, one column per channel. 
            A = read(g_dio.joystick.daq);
        
            joypos = zeros(1, length(g_dio.joystick.codes));
            joyvolts = A{1, :};
            for icode = 1:length(g_dio.joystick.codes)
                % S tells us if left is more positive than right (1 if so, -1 if not)
                S = 1;
                if g_dio.joystick.cal(icode,2) > g_dio.joystick.cal(icode,1)
                    S = -1;
                end
            
                vhi = max(g_dio.joystick.cal(icode,1), g_dio.joystick.cal(icode,2));
                vlo = min(g_dio.joystick.cal(icode,1), g_dio.joystick.cal(icode,2));
                if A{1, icode} >= vhi
                    pos = S;
                elseif A{1, icode} >= vlo
                    pos = 0;
                else
                    pos = -S;
                end
                joypos(icode) = pos;
            end
        elseif g_dio.joystick.device == "mcc"
    
            joypos = zeros(1, length(g_dio.joystick.codes));
            joyvolts = zeros(1, length(g_dio.joystick.codes));
            for icode = 1:length(g_dio.joystick.codes)
    
                joyvolts(icode) = DaqAIn(g_dio.joystick.daq, g_dio.joystick.channels(icode), 1);
                joypos(icode) = getJoyPos(joyvolts(icode), g_dio.joystick.cal(icode, :));
    
            end
    
        elseif g_dio.joystick.device == "none"
            joypos = cclabUIJoystick(g_dio.joystick.codes);
        else
            error('Unknown joystick device type "%s"\n', g_dio.joystick.device);
        end
    else
        error('No joystick configured, check cfg file.');
    end
end


function pos = getJoyPos(v, cal)
    % S tells us if left is more positive than right (1 if so, -1 if not)
    S = 1;
    if cal(2) > cal(1)
        S = -1;
    end
    
    vhi = max(cal(1), cal(2));
    vlo = min(cal(1), cal(2));
    if v >= vhi
        pos = S;
    elseif v >= vlo
        pos = 0;
    else
        pos = -S;
    end
end