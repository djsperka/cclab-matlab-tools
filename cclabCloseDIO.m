function cclabCloseDIO()
%cclabCloseDIO Releases all daq resources, and removes global var from
%workspace.
%   Call this to release all resources used for digital IO system (in other
%   words, call this at the end of your script if you called cclabInitDIO
%   elsewhere in your script. Calling this function multiple times is not
%   harmful. 


%   clean up reward system parts of dio
%    cclabCloseReward();

%   Now clean up pulse channels. Have to re-declare g_dio and see if its
%   empty or not, then clear it again. 
    global g_dio;
    if ~isempty(g_dio)
        g_dio.daqAB = [];
    end
    clear global g_dio;
end