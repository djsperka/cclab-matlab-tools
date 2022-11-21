function [] = cclabInitDIO(types)

%cclabInitDIO Initialize DIO channels on rig.
% 'types' is a string of channels to be configured. There is a reward 
% channel, which you should specify with either "j" or "n" ("n" gives a 
% dummy channel - use this when working on a machine other than the rig.
% 'types' can also include "A" or "B". These two channels are for output 
% pulses - call cclabPulse("A"), e.g.
% 

    rewardRate = 5000;
    abRate = 1000000;
    global g_dio;
    
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
                    g_dio.reward.daq.Rate = rewardRate;
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


%     % Now pulse channels - set up automatically
%     % Do not require AB in types string.
% 
%     if isempty(g_dio) || ~isfield(g_dio, 'daqClock')
%     
%         % WARNING! Assuming that there is a single daq device, and that the
%         % first one is the ni PCIe-6351. If that changes, or if another card is
%         % added to the machine, this will something more clever. djs
%         daqs = daqlist();
%     
%         if strcmp(daqs.Model(1), "PCIe-6351")
%             % create daq object, populate it
%             g_dio.daqClock = daq("ni");
%             addoutput(g_dio.daqClock, "Dev1", "ctr0", "PulseGeneration");
%             g_dio.daqClock.Channels(1).Frequency=abRate;
%             g_dio.daqClock.Rate = abRate;
%             start(g_dio.daqClock, "Continuous");
%         else
%             error("cclabInitDIO: Cannot find ni PCIe-6351");
%         end
% 
%     end
% 

% will do spinlock, so no clock.
    if isempty(g_dio) || ~isfield(g_dio, 'daqAB')
    
        % WARNING! Assuming that there is a single daq device, and that the
        % first one is the ni PCIe-6351. If that changes, or if another card is
        % added to the machine, this will something more clever. djs
        daqs = daqlist();
    
        if strcmp(daqs.Model(1), "PCIe-6351")
            % create daq object, populate it
            g_dio.daqAB = daq("ni");
            addoutput(g_dio.daqAB, "Dev1", "port0/line4", "Digital"); % A
            addoutput(g_dio.daqAB, "Dev1", "port0/line3", "Digital"); % B
            %terminal = g_dio.daqClock.Channels(1).Terminal;
            %addclock(g_dio.daqAB, "ScanClock", "External", strcat('Dev1/', terminal));
            g_dio.daqAB.Rate=abRate;
        else
            error("cclabInitDIO: Cannot find ni PCIe-6351");
        end
    end
end