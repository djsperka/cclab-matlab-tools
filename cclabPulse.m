function [success, sample] = cclabPulse(varargin)
%cclabPulse(which, widthMS=1) 
%   Output TTL pulses on a dig output line. Must call cclabInitDIO first. 
%   cclabPulse('A') = output a single 1ms pulse on dig output line 'A'
%   cclabPulse('B', 0.1) = output a single pulse of width 0.1ms on line 'B'

    success = 0;
    if ~cclabDIOIsReady()
        error('reward system not ready - call cclabInitReward()');
    else

        % Check input parameters. 
        % The first arg is the channel or channels that should get a pulse.
        % If present, the second arg is the pulse width in MS. 
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

        % The order of the output array values should correspond to the
        % channel order.

        sample = zeros(1, length(g_dio.digout.codes));
        clear = zeros(1, length(g_dio.digout.codes));
        for ich=1:length(channel)
            z=strfind(g_dio.digout.codes, channel(ich));
            if isempty(z)
                warning('cclabPulse - channel %s was not configured.', channel(ich));
            else
                sample(z) = 1;
            end
        end

        if ~isempty(g_dio.digout.daq)

            if g_dio.digout.device == "ni"
                % spinlock implementation here, using WaitSecs
                % just a single pulse
        
                write(g_dio.digout.daq, sample);
                WaitSecs(tPulseWidthMS / 1000);
                write(g_dio.digout.daq, clear);
            elseif g_dio.digout.device == "mcc"
                v=0;    % will be written to DOut
                A=find(sample);
                if ~isempty(A)
                    v = bitor(v, sum(2.^(A-1)));
                end
                DaqDOut(g_dio.digout.daq, g_dio.digout.port, v);
                WaitSecs(tPulseWidthMS / 1000);
                DaqDOut(g_dio.digout.daq, g_dio.digout.port, 0);
            else
                fprintf('cclabPulse() dummy digout: ');
                fprintf('%d', sample);
                fprintf('\n');
            end

        else


        end

    end
end