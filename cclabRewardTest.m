function [s] = cclabRewardTest(varargin)
%cclabRewardTest Deliver reward with duration and n.
%   Pass through to cclabReward(durationMS, n)

p = inputParser;
addRequired(p, 'durationMS', @(x) isnumeric(x) && isscalar(x) && (x > 0));
addOptional(p, 'n', 1, @(x) isnumeric(x) && isscalar(x) && (x > 0));
addParameter(p, 'gap', 50, @(x) isnumeric(x) && isscalar(x) && (x > 0));
addParameter(p, 'nReps', 1, @(x) isnumeric(x) && isscalar(x) && (x > 0));
addParameter(p, 'interRepGap', 100, @(x) isnumeric(x) && isscalar(x) && (x > 0));
parse(p, varargin{:});

s = [];
cclabInitReward("j");
for i = 1:p.Results.nReps
    fprintf('repetition %d\n', i);
    [success, s] = cclabReward(p.Results.durationMS, p.Results.n, p.Results.gap);
    pause(p.Results.interRepGap/1000);
end
cclabCloseReward();