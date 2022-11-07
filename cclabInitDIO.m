function [success] = cclabInitDIO(types)

%cclabInitDIO Initialize DIO channels on rig.
% 'types' is a string of channels to be configured. There is a reward 
% channel, which you should specify with either "j" or "n" ("n" gives a 
% dummy channel - use this when working on a machine other than the rig.
% 'types' can also include "A" or "B". These two channels are for output 
% pulses - call cclabPulse("A"), e.g.
% 

global g_dio;
success = 0;


% First - check for "j" or "n", and then deal with the reward setup.
if contains(types, 'j') || contains(types, 'n')

    % g_dio.reward is not empty if it was init'd elsewhere
    if isempty(g_dio) || ~isfield(g_dio, 'reward')
    
        % WARNING! Assuming that there is a single daq device, and that the
        % first one is the ni PCIe-6351. If that changes, or if another card is
        % added to the machine, this will something more clever. djs
        if contains(types, 'j')
            % enumerate daq devices, according to daq toolbox...
            daqs = daqlist();
    
            if strcmp(daqs.Model(1), "PCIe-6351")
                % create daq object, populate it
                g_dio.reward.type = "j";
                g_dio.reward.daq = daq("ni");
                g_dio.reward.daq.Rate = 5000;
                addoutput(g_dio.reward.daq, "Dev1", "ao0", "Voltage");
                success = 1;
            else
                error("cclabInitReward: Cannot find ni PCIe-6351");
            end
        elseif contains(types, 'n')
            g_dio.reward.type = "n";
            g_dio.reward.daq = [];
            success = 1;
        else
            error("Unrecognized reward type %s", rewtype);
        end
    elseif isfield(g_dio, 'reward')
        if g_dio.reward.type == "j" && isa(g_dio.reward.daq, 'daq.interfaces.DataAcquisition')
            fprintf('Found configured reward object using ni DAQ card.\n');
            success = 1;
        elseif g_dio.reward.type == "n"
            fprintf('Found configured DUMMY reward object.\n');
            success = 1;
        else
            error("g_reward found, unknown type: %s", g_dio.reward.type);
        end
    end
end