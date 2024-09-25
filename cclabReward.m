function [success, s] = cclabReward(varargin)
%cclabReward(msec, n=1, gap=50) Deliver reward, open valve for 'msec' 
% milliseconds, n times, with 'gap' ms between rewards. 
%   This is a synchronous function, it will block Matlab until reward is 
%   done. Call cclabInitDIO before calling this. 
    s = [];
    success = 0;
    if ~cclabRewardIsReady()
        error('reward system not ready - call cclabInitReward()');
    else

        global g_dio;
        p = inputParser;
        addRequired(p, 'msec', @(x) isnumeric(x) && isscalar(x) && (x > 0));
        addOptional(p, 'n', 1, @(x) isnumeric(x) && isscalar(x) && (x > 0));
        addOptional(p, 'gap', 50, @(x) isnumeric(x) && isscalar(x) && (x > 0));
        addParameter(p, 'margin', 50, @(x) isnumeric(x) && isscalar(x) && (x > 0))
        parse(p, varargin{:});

        if ismember(g_dio.reward.device, {'ni','mcc'})

            % make automatic end margin of MARGIN size with 0V output.
            % Will have (n-1) * gap
            % number of samples in the reward signal and in the gap
            nmargin = floor(p.Results.margin/1000.0 * g_dio.reward.Rate);
            nrew = floor(p.Results.msec/1000.0 * g_dio.reward.Rate);
            ngap = floor(p.Results.gap/1000.0 * g_dio.reward.Rate);
            nsamples = 2*nmargin + p.Results.n * nrew + (p.Results.n-1) * ngap;
        
            fprintf('nmargin %d nrew %d ngap %d nsamples %d\n', nmargin, nrew, ngap, nsamples);

            % Make samples run from 0-1, first and last GAP are zero.
            s = ones(nsamples, 1);
            s(1:nmargin) = 0;
            s(end-nmargin:end) = 0;
        
            % gaps, if any
            for i = [2:p.Results.n]
                ind = nmargin + nrew + (i-2)*(nrew+ngap);
                s(ind+1 : ind+ngap) = 0;
            end

            if g_dio.reward.device == "ni"
                if g_dio.reward.daq.Running
                    fprintf('Warning - Previous reward scan is running, time since is %f!\n', toc(g_dio.reward.tic));
                else
                    g_dio.reward.tic = tic;
                    % write 5*s to get 5V signals.
                    write(g_dio.reward.daq, 5*s);
                end
    
                %let's declare success!
                success = 1;
            elseif g_dio.reward.device == "mcc"

                % Doesn't seem to work right on windows or linux. No time
                % to decipher/fix, change to using WaitSecs as temp fix.
                %
                % opts.FirstChannel = 0;
                % opts.LastChannel = 0;
                % opts.f = g_dio.reward.Rate;
                % opts.trigger = 0;
                % opts.getReports = 1;
                % opts.print = 1;
                % disp(opts);
                % disp(size(s));
                % params=DaqAOutScan(g_dio.reward.daq, s, opts);
                % 
                % 
                % if isempty(params.start)
                %   params.start=nan;
                % end
                % if isempty(params.end)
                %   params.end=nan;
                % end
                % c = 1;
                % fprintf('Sent %.0f (out of %.0f) samples/channel on %d channels in %.0f (out of %.0f) ms. Actual rate %f\n',...
                %   params.countActual,length(s),c,1000*(params.end-params.start),1000*length(s)/opts.f, params.fActual);
                % r=(params.numberOfReportsSent-1)/(params.end-params.start);
                % fprintf('Sending speed was %.0f report/s, %.0f sample/channel/s.\n',r,r*32/c);
                
                % As a compromise, respect only the reward time, no repeats
                % Change channel 0 (pins 13/12=gnd)
                DaqAOut(g_dio.reward.daq, 0, 1);
                WaitSecs(p.Results.msec/1000);
                DaqAOut(g_dio.reward.daq, 0, 0);
                success = 1;
            else
                error('Unhandled device type in cclabReward()');
            end
        elseif g_dio.reward.device == "none"

            fprintf('cclabReward: dummy reward of %dms, n=%d, gap=%dms\n', p.Results.msec, p.Results.n, p.Results.gap);
            success = 1;
            
        end
    end
end