function [] = cclabInitDIO(types)

%cclabInitDIO Initialize DIO channels on rig.
% 'types' is a string of channels to be configured. There is a reward 
% channel, which you should specify with either "j" or "n" ("n" gives a 
% dummy channel - use this when working on a machine other than the rig.
% TODO: As currently configured, two DIO channels are automatically 
% set up, or at least its attempted, but this function will fail if run
% without a working NI PCIe-6351. 

    rewardRate = 5000;
    abRate = 1000000;
    global g_dio;
    

    % find device id. We assume that the device is an NI pcie-6351. This
    % would be easy to change, but this is the only device in town, so
    % that's what we're going with. 

    daqs = daqlist();
    devID='None';
    for i=1:size(daqs, 1)  
        if strcmp(daqs(i, :).Model, "PCIe-6351")
            devID = daqs(i, :).DeviceID;
            break;
        end
    end
    fprintf('found DeviceID %s\n', devID);

    % First - check for "j" or "n", and then deal with the reward setup.
    if contains(types, 'j') || contains(types, 'n')
    
        % g_dio.reward is not empty if it was init'd elsewhere
        if isempty(g_dio) || ~isfield(g_dio, 'reward')
        
            % WARNING! Assuming that there is a single daq device, and that the
            % first one is the ni PCIe-6351. If that changes, or if another card is
            % added to the machine, this will something more clever. djs
            if contains(types, 'j')
                % create daq object, populate it
                g_dio.reward.type = "j";
                g_dio.reward.daq = daq("ni");
                g_dio.reward.daq.Rate = rewardRate;
                addoutput(g_dio.reward.daq, devID, "ao0", "Voltage");
                success = 1;
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

    % will do spinlock, so no clock.
    if isempty(g_dio) || ~isfield(g_dio, 'daqAB')

        % Now do pulse channels - check for "A" or "B".
        if contains(types, 'A') || contains(types, 'B')
        
            % create daq object, populate it
            g_dio.daqAB = daq("ni");
            addoutput(g_dio.daqAB, devID, "port0/line4", "Digital"); % A
            addoutput(g_dio.daqAB, devID, "port0/line3", "Digital"); % B
            addoutput(g_dio.daqAB, devID, "port0/line5", "Digital"); % C
            addoutput(g_dio.daqAB, devID, "port0/line6", "Digital"); % D
            addoutput(g_dio.daqAB, devID, "port0/line7", "Digital"); % E
            g_dio.daqAB.Rate=abRate;
        else
            g_dio.daqAB='DUMMY';
        end
    end
end