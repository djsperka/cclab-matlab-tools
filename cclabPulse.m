function [success, sample] = cclabPulse(varargin)
%cclabPulse(which, widthMS=1, numPulses=1, gap=1) 
%   Pulse 'which' channel ('A' or 'B'). Default is a single 1ms pulse. 
    sample = [];
    success = 0;
    if ~cclabDIOIsReady()
        error('reward system not ready - call cclabInitReward()');
    else
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
           'This function expects 0, 1, or 5 inputs.');
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



%         % how many samples, at current rate, in a single pulse?
%         rate = g_dio.daqAB.Rate;
%         pSamples = floor(tPulseWidthMS / 1000 * rate);
% 
%         % how many samples in the gaps?
%         gSamples = floor(pulseGapMS / 1000 * rate);
% 
%         % total number of samples needed. 
%         % Note the number of channels is hard-coded here! Two columns.
%         % Only the channel 'A' or 'B' gets pulsed. 
%         n = nPulses*pSamples + (nPulses-1)*gSamples + 1;
%         sample = zeros(n, 2);
%         for i=1:nPulses
%             sample((i-1)*(pSamples + gSamples)+1:(i-1)*(pSamples + gSamples)+pSamples, column) = 1;
%         end
%         write(g_dio.daqAB, sample);

    end
end