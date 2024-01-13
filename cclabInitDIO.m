function [] = cclabInitDIO(varargin)
%cclabInitDIO Initialize DIO channels on rig.
% Input arg can be a config filename. The old letters, e.g. "jAB" will be
% accepted as well, but given the default rig configuration - that is the
% config for the right rig. 


    rewardRate = 5000;
    abRate = 1000000;
    joyRate = 1000;


    cclabCloseDIO();
    global g_dio;
    g_dio.reward = [];
    g_dio.digout = [];
    g_dio.digout.codes = '';
    g_dio.joystick = [];
    g_dio.joystick.codes = '';

    % load configuration
    cConfig = cclabLoadIOConfig(varargin{1});

    % find device id. We assume that the device is an NI pcie-6351. This
    % would be easy to change, but this is the only device in town, so
    % that's what we're going with. 
    niDevID='None';
    if any(contains(cConfig{3}, 'ni'))
        daqs = daqlist();
        for i=1:size(daqs, 1)  
            if strcmp(daqs(i, :).Model, "PCIe-6351")
                niDevID = daqs(i, :).DeviceID;
                break;
            end
        end
        fprintf('found DeviceID %s\n', niDevID);
    end


    % reward

    if any(contains(cConfig{2}, 'reward'))

        ind = find(contains(cConfig{2}, 'reward'));
        letter = cConfig{1}{ind};
        porttype = cConfig{2}{ind};
        thingy = cConfig{3}{ind};
        portname = cConfig{4}{ind}; 

        if contains(thingy, 'ni', 'IgnoreCase', true)
            % create daq object, populate it
            g_dio.reward.type = "j";
            g_dio.reward.daq = daq("ni");
            g_dio.reward.daq.Rate = rewardRate;
            addoutput(g_dio.reward.daq, niDevID, "ao0", "Voltage");
            success = 1;
        elseif contains(thingy, 'none', 'IgnoreCase', true)
            g_dio.reward.type = "n";
            g_dio.reward.daq = [];
            success = 1;
        else
            error("Unrecognized j thingy (column 3) - check cfg file %s", thingy);
        end
    end     % end of dealing with 'j'


    % digital output - porttype='digout'

    if any(contains(cConfig{2}, 'digout'))

        digoutInd = find(contains(cConfig{2}, 'digout'));
        for ind = 1:length(digoutInd)
            letter = cConfig{1}{digoutInd(ind)};
            thingy = cConfig{3}{digoutInd(ind)};
            portname = cConfig{4}{digoutInd(ind)};

            % TODO this will have trouble if one mixes digout 'ni' and
            % 'none', as the first time through the daq is created (or
            % not). 
            if contains(thingy, 'ni', 'IgnoreCase', true)
                % create daq obj if not already created
                if ~isfield(g_dio.digout, 'daq')
                    g_dio.digout.daq = daq('ni');
                    g_dio.digout.daq.Rate=abRate;
                elseif isempty(g_dio.digout.daq)
                    error('Cannot mix ''ni'' and ''none'' type io ports');
                end
                addoutput(g_dio.digout.daq, niDevID, portname, "Digital");
                g_dio.digout.codes = strcat(g_dio.digout.codes, letter);
            elseif contains(thingy, 'none', 'IgnoreCase', true)
                if ~isfield(g_dio.digout, 'daq')
                    g_dio.digout.daq = [];
                elseif isa(g_dio.digout.daq, 'daq.interfaces.DataAcquisition')
                    error('Cannot mix ''ni'' and ''none'' type io ports');
                end
                g_dio.digout.codes = strcat(g_dio.digout.codes, letter);                
            end
        end
    end


    % analog input - porttype='joystick'
    
    if any(contains(cConfig{2}, 'joystick'))

        joystickInd = find(contains(cConfig{2}, 'joystick'));
        for ind = 1:length(joystickInd)
            letter = cConfig{1}{joystickInd(ind)};
            thingy = cConfig{3}{joystickInd(ind)};
            portname = cConfig{4}{joystickInd(ind)};

            if contains(thingy, 'ni', 'IgnoreCase', true)
                % create daq obj if not already created
                if ~isfield(g_dio.joystick, 'daq')
                    g_dio.joystick.daq = daq('ni');
                    g_dio.joystick.daq.Rate=joyRate;
                end
                ch = addinput(g_dio.joystick.daq, niDevID, portname, "Voltage");
                ch.Range = [-5, 5];
                g_dio.joystick.codes = strcat(g_dio.joystick.codes, letter);
            elseif contains(thingy, 'none', 'IgnoreCase', true)
                g_dio.joystick.codes = strcat(g_dio.joystick.codes, letter);

                if ~isfield(g_dio.joystick, 'daq')
                    g_dio.joystick.daq = [];
                elseif isa(g_dio.joystick.daq, 'daq.interfaces.DataAcquisition')
                    error('Cannot mix ''ni'' and ''none'' type joystick ports');
                end
                g_dio.joystick.codes = strcat(g_dio.joystick.codes, letter);                

            
            end
        end
    end
end