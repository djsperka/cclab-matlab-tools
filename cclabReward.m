function [success] = cclabReward(msec)
%cclabReward Deliver reward, open valve for specified number of milliseconds.
%   This is an async function, it may return before reward is done.

    success = 0;
    if ~cclabRewardIsReady()
        error('reward system not ready - call cclabInitReward()');
    else

        global g_reward;

        if g_reward.type == "j"

            % Create square wave
            nsamples = floor(msec/1000.0 * g_reward.daq.Rate) + 2;
            s = 5 * ones(nsamples, 1);
            s(1) = 0;
            s(end) = 0;
    
            % preload and start
            preload(g_reward.daq, s);
            start(g_reward.daq);
    
            %TODO we don't really know this, but let's declare success!
            success = 1;

        elseif g_reward.type == "n"

            fprintf('cclabReward: dummy reward of %dms\n', msec);
            success = 1;
            
        end
    end
end