function [success] = cclabReward(varargin)
%cclabReward(msec, n=1, gap=50) Deliver reward, open valve for msec milliseconds, n times, with 'gap' ms between.
%   This is an async function, it may return before reward is done.

    success = 0;
    if ~cclabRewardIsReady()
        error('reward system not ready - call cclabInitReward()');
    else

        global g_reward;
        p = inputParser;
        addRequired(p, 'msec', @(x) isnumeric(x) && isscalar(x) && (x > 0));
        addOptional(p, 'n', 1, @(x) isnumeric(x) && isscalar(x) && (x > 0));
        addOptional(p, 'gap', 50, @(x) isnumeric(x) && isscalar(x) && (x > 0));
        parse(p, varargin{:});

        if g_reward.type == "j"

            % number of samples in the reward signal and in the gap
            nrew = floor(p.Results.msec/1000.0 * g_reward.daq.Rate);
            ngap = floor(p.Results.gap/1000.0 * g_reward.daq.Rate);
            nsamples = 2 + p.Results.n * nrew + (p.Results.n-1) * ngap;
        
            % 5 V samples, first and last are zero.
            s = 5 * ones(nsamples, 1);
            s(1) = 0;
            s(end) = 0;
        
            % gaps, if any
            for i = [2:p.Results.n]
                ind = 1 + nrew + (i-2)*(nrew+ngap);
                s(ind+1 : ind+ngap) = 0;
            end
    
            % preload and start
            preload(g_reward.daq, s);
            start(g_reward.daq);
    
            %TODO we don't really know this, but let's declare success!
            success = 1;

        elseif g_reward.type == "n"

            fprintf('cclabReward: dummy reward of %dms, n=%d, gap=%dms\n', p.Results.msec, p.Results.n, p.Results.gap);
            success = 1;
            
        end
    end
end