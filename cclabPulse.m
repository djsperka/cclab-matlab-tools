function [success, sample] = cclabPulse(varargin)
%cclabPulse(which, widthMS=1, numPulses=1, gap=1) 
%   Output TTL pulses on a dig output line. Must call cclabInitDIO first. 
%   cclabPulse('A') = output a single 1ms pulse on dig output line 'A'
%   cclabPulse('B', 0.1) = output a single pulse of width 0.1ms on line 'B'
%   TODO: 'numPulses' and 'gap' are ignored! The multiple pulses were 
%   removed when switching to spinlock, easy to re-implement if needed.

    sample = [];
    success = 0;
    if ~cclabDIOIsReady()
        error('reward system not ready - call cclabInitReward()');
    else

        % Check input parameters
        global g_dio;
        nPulses = 1;
        pulseGapMS = 1;
        tPulseWidthMS = 1;
        channel = '';
        switch(nargin)
        case 1
            channel = varargin{1};
        case 2
            channel = varargin{1};
            tPulseWidthMS = varargin{2};
        case 3
            channel = varargin{1};
            tPulseWidthMS = varargin{2};
            nPulses = varargin{3};
        case 4
            channel = varargin{1};
            widthMS = varargin{2};
            nPulses = varargin{3};
            pulseGapMS = varargin{4};
        otherwise
            error('cclabPulse: InvalidNumberOfInputs', ...
           'This function expects 1-4 inputs.');
        end

        % Which column, column 1 = 'A', column 2 = 'B'
        column = -1;
        if contains(channel, 'A')
            column = 1;
        elseif contains(channel, 'B')
            column = 2;
        end

        % spinlock implementation here, using WaitSecs
        % just a single pulse

        sample = [0 0];
        sample(column) = 1;
        write(g_dio.daqAB, sample);
        WaitSecs(tPulseWidthMS / 1000);
        write(g_dio.daqAB, [0 0]);

    end
end