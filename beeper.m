classdef beeper < handle
    %beeper Generate one of two beeps.
    %   Detailed explanation goes here
    
    properties (Access = private)
        PAHandle
        SampleRate
        IsUsingSnd
        Sounds
        SNameIndexMap
    end

    methods
        function obj = beeper(s, OpenSnd)
            %beeper Class that makes sounds for you, either tones or wav
            %files.
            %   Correct (default 800) is freq of correct() tone, Incorrect (default 350) is freq of
            %   incorrect(). Duration (default 0.25s) is in sec.
            %   A filename of a sound file may be supplied for both Correct
            %   and Incorrect (both must be files, or else neither). In
            %   this case, the frequencies of the two files must be the
            %   same.
            
            arguments
                s {mustBeOKBeeperArg} = []
                OpenSnd (1,1) {mustBeNumericOrLogical} = false
            end

            InitializePsychSound(1);
            obj.IsUsingSnd = OpenSnd;
            obj.SNameIndexMap = containers.Map(KeyType='char', ValueType='uint32');
            obj.Sounds=[];

            % Open default audio device. 
            % If OpenSnd is true (the default), then use the handle to open
            % the Snd device. See "help Snd" notes section "Audio device 
            % sharing for interop with PsychPortAudio"
            obj.PAHandle = PsychPortAudio('Open');
            if (obj.IsUsingSnd)
                Snd('Open', obj.PAHandle, 1);
            end
            
            status = PsychPortAudio('GetStatus', obj.PAHandle);
            obj.SampleRate = status.SampleRate;
            fprintf('Sound device using sample rate %f\n', obj.SampleRate);

            % add initial sounds - input is cell or empty
            if iscell(s)
                if size(s, 1) == 1
                    obj.addsound(s{:});
                else
                    cellfun(@(x) obj.addsound(x{:}), s);
                end
            end

        end
        
        function [ind] = addsound(obj, name, freq_or_file, dur)

            arguments (Input)
                obj (1,1) beeper
                name {mustBeNonzeroLengthText} 
                freq_or_file {mustBeFreqOrFile}
                dur (1,1) {mustBeNonnegative} = 0.25
            end
                
            s=struct;
            s.name=name;

            % requirement on input for freq tone
            if isnumeric(freq_or_file) && isscalar(freq_or_file)
                [s.lr] = sound_from_single_freq(obj, freq_or_file, obj.SampleRate, dur);
            elseif isfile(freq_or_file)
                [s.lr] = sound_from_file(obj, freq_or_file, obj.SampleRate, dur);
            else
                error('cclab-matlab-tools-beeper:NotFreqOrFile', 'Not a frequency or existing filename.');
            end

            % If name exists in the map, replace it in the array. 
            % Otherwise, add to array, and then to the map.
            if isKey(obj.SNameIndexMap, s.name)
                warning('Replacing sound with name ''%s''', s.name)
                obj.Sounds(obj.SNameIndexMap(s.name)) = s;
            else
                if isempty(obj.Sounds)
                    obj.Sounds = s;
                else
                    obj.Sounds(end+1) = s;
                end
                ind = length(obj.Sounds);
                obj.SNameIndexMap(s.name) = ind;
            end
        end

        function info(obj)
            obj.print_sounds_info();
        end

        function play(obj, id)

            if ischar(id)
                if isKey(obj.SNameIndexMap, id)
                    obj.playsound(obj.Sounds(obj.SNameIndexMap(id)).lr);
                else
                    error('cclab-matlab-tools-beeper:NotAGoodID', 'Cannot find sound with this name(%s).', id);
                end
            elseif isscalar(id) && isnumeric(id) 
                if id > 0 && id<=length(obj.Sounds)
                    obj.playsound(obj.Sounds(id).lr);
                else
                    error('cclab-matlab-tools-beeper:NotAGoodID', 'Cannot find sound with this id(%d).', id);
                end                    
            else
                error('cclab-matlab-tools-beeper:NotAGoodID', 'Bad arg, id must be an int or char.');
            end
        end

        function delete(obj)
            %DELETE Destructor method runs when this object is deleted.
            %   When this object is deleted, clear'd, or otherwise gets
            %   cleaned up, this method will run. Close audio ports.
            if (obj.IsUsingSnd)
                Snd('Close', 1);
            end
            PsychPortAudio('Close', obj.PAHandle);
        end
    end

    methods (Access=private)

        function playsound(obj, lr)
            PsychPortAudio('FillBuffer', obj.PAHandle, lr);
            PsychPortAudio('Start', obj.PAHandle, 1, 0, 1);
            WaitSecs(size(lr,2)/obj.SampleRate);
            PsychPortAudio('Stop', obj.PAHandle);
        end

        function [lr] = sound_from_single_freq(obj, freq, rate, dur)
            t = [0:1/obj.SampleRate:dur];
            l = sin(2 * pi * freq * t);
            lr = vertcat(l,l);
        end

        function [lr] = sound_from_file(obj, filename, rate, dur)
            [lr_up, f_from_file] = audioread(filename);
            if f_from_file ~= obj.SampleRate
                warning('Audio file (%s) has sample rate (%f) different than default device rate (%f)', f_from_file, obj.SampleRate);
            end

            % NOTE: Assuming here that all audio files will have exactly
            % two channels when returned from audioread.

            if dur <= 0
                lr = lr_up';
            else
                % check duration of sound when played at obj.SampleRate
                nsamples_from_file = size(lr_up,1);
                nsamples_needed = dur * obj.SampleRate;
                if nsamples_needed <= nsamples_from_file
                    % no problems
                    lr = lr_up(1:nsamples_needed,:)';
                else
                    warning('Audio file (%s) is shorter (%fs) than request (%fs). Returning shorter amt.', filename, nsamples_from_file/obj.SampleRate, dur);
                    lr = lr_up';
                end
            end
        end

        function print_sounds_info(obj)
            fprintf('There are %d sounds\n', length(obj.Sounds));
            for i=1:length(obj.Sounds)
                fprintf('%d: %s\t%.2fsec\n', i, obj.Sounds(i).name, size(obj.Sounds(i).lr, 2)/obj.SampleRate);
            end
        end
                    

    end
end

function mustBeFreqOrFile(f)
    assert((isnumeric(f) && isscalar(f)) || isfile(f), 'Must be frequency or filename');
end

function mustBeOKBeeperArg(s)
    % arg can be a single sound spec in the form of a 1x3 cell, e.g.
    % {'myname',1000,1} for a 1 s tone at 1000Hz named 'myname', or 
    % {'myname','/path/to/soundfile',2}
    % For files, a duration of 0 means use the whole file.
    assert(isempty(s) || (iscell(s) && (size(s) == [1,3] || size(s, 2)==1)));
end