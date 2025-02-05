function [isready] = cclabDIOIsReady()
%cclabDIOIsReady checks whether DIO system is initialized and ready.
%   Detailed explanation goes here

    global g_dio;
    isready = 0;
    if ~isempty(g_dio) && isfield(g_dio, 'reward') && isfield(g_dio, 'digout')
        isready = 1;
    end

end
