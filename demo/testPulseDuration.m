function [times] = testPulseDuration(nPulses, tPulseLengthMS)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


times = zeros(nPulses, 1);
t0 = GetSecs();
cclabInitDIO('AB');
for i=1:nPulses
    times(i) = GetSecs();
    cclabPulse('B', tPulseLengthMS);
    %WaitSecs(.1);
end
cclabCloseDIO();
return;