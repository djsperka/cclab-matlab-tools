
% create clock
daqClock = daq("ni");
addoutput(daqClock, "Dev1", "ctr0", "PulseGeneration");
daqClock.Channels(1).Frequency=1000;
daqClock.Channels(1).Terminal

% for juicer
% daqJ = daq("ni");
% addoutput(daqJ, "Dev1", "port0/line2", "Digital");
% addclock(daqJ, "ScanClock", "External", "Dev1/PFI12");
% daqJ.Rate=1000;



% pulse shape 70ms on
juice =zeros(1000,1);
juice(100:800)=1;
%write(daqJ, juice);

% make another pulse channel, use same clock

daqP = daq("ni");
daqP.Rate=1000;
addoutput(daqP, "Dev1", "port0/line3", "Digital");
addclock(daqP, "ScanClock", "External", "Dev1/PFI12");

daqClock.start("Continuous");
