function [isready] = cclabJoystickIsReady()
%cclabJoystickIsReady check if cclabJoyPos can return a value (init & cal)
%   Detailed explanation goes here

global g_dio
isready = 0;
if cclabDIOIsReady()
    if isfield(g_dio.joystick, 'cal') && ~isempty(g_dio.joystick.cal)
        isready = 1;
    end
end
