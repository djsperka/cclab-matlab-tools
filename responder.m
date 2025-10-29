classdef responder < handle
    %responder Class that treats a keyboard device as a response box. 
    %   Treats any device with a PTB-style keyboard index as a button box.
    %   Monitors a queue on that device, with convenience methods that
    %   check for responses and their response times.

    properties
        ResponderType
        DevIndex
        Responses
    end

    methods (Access = public)
        function obj = responder(ind,rtype)
            %   Construct a responder object for device with index.
            %   The device at index ind is used. You must determine this
            %   index value before calling. Each device should have a type,
            %   rtype, which should be one of 'mkey01', 'kbd'. (more to
            %   come). The property 'Responses' is a 2-column cell array.
            %   The first column of each row is a key name (e.g. returned
            %   from @KbName), and the second column is the value to be
            %   returned as the responseIndex. Multiple key names can be
            %   mapped to a single responseIndex. Not all key names must be
            %   used - keys whose names are not in Responses are ignored
            %   by the responder.

            arguments
                ind {mustBeNonnegative} 
                rtype {mustBeTextScalar,mustBeMember(rtype,{'mkey01','kbd'})} = 'mkey01'
            end

            % Always use unified key names
            KbName('UnifyKeyNames');
            obj.DevIndex = ind;
            KbQueueCreate(obj.DevIndex);

            switch rtype
                case 'mkey01'
                    % This was the original setup - left and right-hand buttons were different. 
                    % obj.Responses = { KbName('1!'), 1; KbName('return'), 0; KbName('2@'), 2; KbName('3#'), 1; KbName('4$'), 2};
                    % New version (V2 - 8/22/2024) - center button is "no change",
                    % all other buttons are "change". Not asking if change is left
                    % or right.
                    obj.ResponderType = 'mkey01';
                    obj.Responses = { KbName('1!'), 1; KbName('return'), 0; KbName('2@'), 1; KbName('3#'), 1; KbName('4$'), 1};
                case 'kbd'
                    obj.ResponderType = 'kbd';
                    obj.Responses = {};
                otherwise
                    error('responder:UnknownResponderType', 'Responder type given (%s) is not supported.', rtype);
            end
        end

        function delete(obj)
            % Close queue and delete object.
            KbQueueStop(obj.DevIndex);
            KbQueueRelease(obj.DevIndex);
        end

        function start(obj)
            % Start monitoring event queue for this device. 
            KbQueueStart(obj.DevIndex);
        end

        function stop(obj, bflush)
            % Stop monitoring event queue. If bflush is true, the queue is
            % also flushed.
            arguments
                obj (1,1) responder
                bflush (1,1) {mustBeNumericOrLogical} = false
            end
            KbQueueStop(obj.DevIndex);
            if bflush
                obj.flush(true);
            end
        end

        function flush(obj, bflush)
            % flush the queue if bflush is true.
            flushType = 0;
            if bflush
                flushType = 3;
            end
            KbQueueFlush(obj.DevIndex, flushType);
        end

        function dump(obj)
            %Prints information on all events in queue to screen. Queue is
            %cleared when done.

            while KbEventAvail(obj.DevIndex) 
                [event, ~] = KbEventGet(obj.DevIndex);
                fprintf('code %3d (%s) pressed %d t %f\n', event.Keycode, KbName(event.Keycode), event.Pressed, event.Time);
            end
        end

        function [isKey, keyCode, tKey] = anykey(obj)
            % ANYKEY() check for any keyPRESS, independent of the currently
            % set Responses{}. Any keypress is accepted, and the literal
            % keycode is returned (not the response id in Responses{}).
            % This can be used when using the responder as an actual
            % response device, but also for gathering other input - e.g.
            % operator input. Be careful to flush() before switching uses,
            % probably important....
            saveResponses = obj.Responses;
            obj.Responses = {};
            [isKey, keyCode, tKey] = obj.response();
            obj.Responses = saveResponses();
        end

        function [isResponse, responseIndex, tResponse] = response(obj)
            % Get the oldest response from the device, if any. A key PRESS 
            % (of any key whose name is in the first column of Responses)
            % is considered a response (we don't wait for the corresponding
            % key RELEASE). isResponse is true if a response has occurred.
            % If so, responseIndex and the response time are assigned. If
            % no response has occurred, then isResponse is false and the
            % values of responseIndex and tResponse are set to nonsense.

            isResponse = false;
            responseIndex = -999;
            tResponse = -1;

            %look at key PRESSES
            [keyPressed, keyCode, tPressed] = obj.nextPress();
            while keyPressed

                % if Responses is empty, then return keyCode. Otherwise,
                % look for a match in first column of responses.
                if ~isempty(obj.Responses)
                    A = cellfun(@(x) any(x==keyCode), obj.Responses(:,1));
                    if any(A)
                        if sum(A) > 1
                            error('Found overlapping responses. Check responses arg to responder constructor.');
                        end
                        isResponse = true;
                        tResponse = tPressed;
                        responseIndex = obj.Responses{A, 2};
                        break;
                    end
                else
                    isResponse = true;
                    tResponse = tPressed;
                    responseIndex= keyCode;
                    break;
                end
                % If we get here, it means we checked a keycode and didn't
                % find it in the responses. Get the next keypress. 
                % This is really only relevant when there are input keypresses
                % that are not in Responses.
                [keyPressed, keyCode, tPressed] = obj.nextPress();
            end
        end
    end

    methods (Access = private)
        function [keyPressed, keyCode, tPressed] = nextPress(obj)
            keyPressed = false;
            keyCode = 0;
            tPressed = -1;
            while KbEventAvail(obj.DevIndex) 
                [event, ~] = KbEventGet(obj.DevIndex);
                %fprintf('code %3d pressed %d t %f\n', event.Keycode, event.Pressed, event.Time);
                if event.Pressed
                    keyPressed = true;
                    keyCode = event.Keycode;
                    tPressed = event.Time;
                    break;
                end
            end
        end
    end
end            
