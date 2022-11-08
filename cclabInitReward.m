function [success] = cclabInitReward(rewtype)
%cclabInitReward Initialize reward system.
%   rewtype "j" for syringe pump, "n" for none (dummy)

    success = cclabInitDIO(rewtype);
end