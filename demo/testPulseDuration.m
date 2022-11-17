function [times] = testPulseDuration(nPulses, tPulseLengthMS)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


times = zeros(nPulses, 1);
t0 = GetSecs();
cclabInitDIO('AB');
for i=1:nPulses
    t0 = GetSecs();
    cclabPulse('B', tPulseLengthMS);
    times(i) = GetSecs() - t0;
    WaitSecs(.1);
end
cclabCloseDIO();
return;