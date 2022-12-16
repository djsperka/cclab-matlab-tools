function cclabCloseReward()
%cclabCloseReward Calls cclabCloseDIO - Releases all daq resources, NOT 
% JUST THOSE USED FOR REWARD, and removes global var from workspace.
%   Call this to release all resources used for digital IO system (in other
%   words, call this at the end of your script if you called cclabInitDIO
%   elsewhere in your script. Calling this function multiple times is not
%   harmful.
    cclabCloseDIO();
end