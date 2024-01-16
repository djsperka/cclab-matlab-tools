function [success, sample] = cclabPulse(varargin)
%cclabPulse(which, widthMS=1) 
%   Output TTL pulses on a dig output line. Must call cclabInitDIO first. 
%   cclabPulse('A') = output a single 1ms pulse on dig output line 'A'
%   cclabPulse('B', 0.1) = output a single pulse of width 0.1ms on line 'B'

    success = 0;
    if ~cclabDIOIsReady()
        error('reward system not ready - call cclabInitReward()');
    else

        % Check input parameters
        global g_dio;
        tPulseWidthMS = 1;
        channel = '';
        switch(nargin)
        case 1
            channel = varargin{1};
        case 2
            channel = varargin{1};
            tPulseWidthMS = varargin{2};
        otherwise
            error('cclabPulse: InvalidNumberOfInputs', ...
           'This function expects 1-2 inputs.');
        end

        % 4/24/2023 djs: There are now 5 lines, 'A'-'E'
        sample = zeros(1, 5);
        clear = sample;         % bring all lines low at end of pulse
        if contains(channel, 'A')
            sample(1) = 1;
        end
        if contains(channel, 'B')
            sample(2) = 1;
        end
        if contains(channel, 'C')
            sample(3) = 1;
        end
        if contains(channel, 'D')
            sample(4) = 1;
        end
        if contains(channel, 'E')
            sample(5) = 1;
        end

        % spinlock implementation here, using WaitSecs
        % just a single pulse

        write(g_dio.digout.daq, sample);
        WaitSecs(tPulseWidthMS / 1000);
        write(g_dio.digout.daq, clear);

    end
end