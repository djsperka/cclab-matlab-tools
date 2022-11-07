function [isready] = cclabRewardIsReady()
%cclabRewardIsReady checks whether reward system is initialized and ready.
%   Detailed explanation goes here

    global g_dio;
    isready = 0;
    if ~isempty(g_dio) && isfield(g_dio, 'reward')
        isready = 1;
    end

end
