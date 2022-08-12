function [success] = cclabInitReward(rewtype)
%cclabInitReward Initialize reward system.
%   rewtype "j" for syringe pump, "n" for none (dummy)

global g_reward;
success = 0;

% g_reward is not empty if it was init'd elsewhere
if isempty(g_reward)

    % enumerate daq devices, according to daq toolbox...
    daqs = daqlist();

    % WARNING! Assuming that there is a single daq device, and that the
    % first one is the ni PCIe-6351. If that changes, or if another card is
    % added to the machine, this will something more clever. djs
    if strcmpi(rewtype, "j")
        if strcmp(daqs.Model(1), "PCIe-6351")
            % create daq object, populate it
            g_reward.type = "j";
            g_reward.daq = daq("ni");
            g_reward.daq.Rate = 5000;
            addoutput(g_reward.daq, "Dev1", "ao0", "Voltage");
            success = 1;
        else
            error("cclabInitReward: Cannot find ni PCIe-6351");
        end
    elseif strcmpi(rewtype, "n")
        g_reward.type = "n";
        g_reward.daq = [];
        success = 1;
    else
        error("Unrecognized reward type %s", rewtype);
    end
elseif isstruct(g_reward)
    if g_reward.type == "j" && isa(g_reward.daq, 'daq.interfaces.DataAcquisition')
        fprintf('Found configured reward object using ni DAQ card.\n');
        success = 1;
    elseif g_reward.type == "n"
        fprintf('Found configured DUMMY reward object.\n');
        success = 1;
    else
        error("g_reward found, unknown type: %s", g_reward.type);
    end
end