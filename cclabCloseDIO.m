function cclabCloseDIO()
%cclabCloseReward Releases daq resources, and removes global var from
%workspace
%   After done using the reward system, call this to release resources.
%   Not strictly required because cclabInitReward will recognize that its
%   already initialized and ready, so you can call init after crashed
%   script, e.g., and it won't complain. 

    cclabCloseReward();

    global g_dio;
    if ~isempty(g_dio)
        stop(g_dio.daqClock);
        g_dio.daqClock = [];
        g_dio.daqAB = [];
    end
    clear global g_dio;
end