function [isready] = cclabRewardIsReady()
%cclabRewardIsReady checks whether reward system is initialized and ready.
%   Detailed explanation goes here

    isready = 0;
    if ismember(who('global'), 'g_reward')
        isready = 1;
    end

end
