function [success, s] = cclabReward(varargin)
%cclabReward(msec, n=1, gap=50) Deliver reward, open valve for msec milliseconds, n times, with 'gap' ms between.
%   This is an async function, it may return before reward is done.
    s = [];
    success = 0;
    if ~cclabRewardIsReady()
        error('reward system not ready - call cclabInitReward()');
    else

        global g_reward;
        p = inputParser;
        addRequired(p, 'msec', @(x) isnumeric(x) && isscalar(x) && (x > 0));
        addOptional(p, 'n', 1, @(x) isnumeric(x) && isscalar(x) && (x > 0));
        addOptional(p, 'gap', 50, @(x) isnumeric(x) && isscalar(x) && (x > 0));
        addParameter(p, 'margin', 50, @(x) isnumeric(x) && isscalar(x) && (x > 0))
        parse(p, varargin{:});

        if g_reward.type == "j"

            % make automatic end margin of MARGIN size with 0V output.
            % Will have (n-1) * gap
            % number of samples in the reward signal and in the gap
            nmargin = floor(p.Results.margin/1000.0 * g_reward.daq.Rate);
            nrew = floor(p.Results.msec/1000.0 * g_reward.daq.Rate);
            ngap = floor(p.Results.gap/1000.0 * g_reward.daq.Rate);
            nsamples = 2*nmargin + p.Results.n * nrew + (p.Results.n-1) * ngap;
        
            % 5 V samples, first and last GAP are zero.
            s = 5 * ones(nsamples, 1);
            s(1:nmargin) = 0;
            s(end-nmargin:end) = 0;
        
            % gaps, if any
            for i = [2:p.Results.n]
                ind = nmargin + nrew + (i-2)*(nrew+ngap);
                s(ind+1 : ind+ngap) = 0;
            end
    
            % preload and start
            %fprintf('cclabReward(): running? %d, preload length %d, time since last reward %f\n', g_reward.daq.Running, length(s), toc(g_reward.tic));
            if g_reward.daq.Running
                fprintf('Warning - Previous reward scan is running, time since is %f!\n', toc(g_reward.tic));
                %g_reward.daq
            else
                g_reward.tic = tic;
%                 preload(g_reward.daq, s);
%                 start(g_reward.daq);
                write(g_reward.daq, s);
            end

%             z=0;
%             while z<10 && g_reward.daq.Running
%                 z = z+1;
%                 fprintf('waiting... pause .2s %d, time since %f\n', z, toc(g_reward.tic));
%                 g_reward.daq
%                 pause(.1);
%             end

    
            %TODO we don't really know this, but let's declare success!
            success = 1;

        elseif g_reward.type == "n"

            fprintf('cclabReward: dummy reward of %dms, n=%d, gap=%dms\n', p.Results.msec, p.Results.n, p.Results.gap);
            success = 1;
            
        end
    end
end