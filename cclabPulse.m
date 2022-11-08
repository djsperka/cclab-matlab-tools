function [success, s] = cclabPulse(varargin)
%cclabPulse(which, msec=1, n=1, gap=1) 
%   This is an async function, it may return before reward is done.
    s = [];
    success = 0;
    if ~cclabDIOIsReady()
        error('reward system not ready - call cclabInitReward()');
    else
        global g_dio;
        p = inputParser;
        addRequired(p, 'which', @(x) ischar(x) && length(x)==1 && (contains(x, 'A') || contains(x, 'B')));    % one at a time
        addOptional(p, 'msec', 1, @(x) isnumeric(x) && isscalar(x) && (x > 0));
        addOptional(p, 'n', 1, @(x) isnumeric(x) && isscalar(x) && (x > 0));
        addOptional(p, 'gap', 1, @(x) isnumeric(x) && isscalar(x) && (x > 0));
        parse(p, varargin{:});

        % Which column, column 1 = 'A', column 2 = 'B'
        column = -1;
        if contains(p.Results.which, 'A')
            column = 1;
        elseif contains(p.Results.which, 'B')
            column = 2;
        end

        % how many samples in the pulse?
        % WARN: Assuming that daq set with 1K sampling rate
        n = p.Results.n * p.Results.msec + (p.Results.n - 1) * p.Results.gap + 1;
        sample = zeros(n, 2);
        for i=1:p.Results.n
            sample((i-1)*(p.Results.msec + p.Results.gap)+1:(i-1)*(p.Results.msec + p.Results.gap)+p.Results.msec, column) = 1;
        end
        write(g_dio.daqAB, sample);

end