classdef SplitKbQueue
    %SplitKbdQueue Creates a KbQueue, sort of, for the case where one is
    %using a kbd for two queues - e.g. as a response device for the subject, 
    %and as a control device for the operator.
    %   Detailed explanation goes here

    properties
        Keylists
        KbIndex
        Queues
        Filters
        Responses
    end

    methods
        function obj = SplitKbQueue(ind, options)
            %SplitKbdQueue Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                ind (1,1) {mustBeNumeric}
                options.filters cell = {}   % each row {'a','b'} any length
                options.responses cell = {} % if responses row is empty, 
                                            % response() will return
                                            % keycode, otherwise expecting
                                            % {{0}, {1}}
            end
            obj.KbIndex = ind;
            obj.Filters = options.filters;
            obj.Responses = options.responses;


            % check filters, prepare a keylist for each
            % expect filters to look like this
            % { {'1!','2@'}; {'+','-'} };
            % single-column array, each element is a cell array, and each
            % element is a key that KbName recognizes.

            % When filters is {}, this should behave like a keyboard queue
            if isempty(options.filters)
                obj.Keylists = ones(256, 1);
                obj.Queues = {CQueue()};
            else
                % when filters isn't empty, the row is fed to KbName, which
                % should then yield a vector of keycodes. For example, 
                % KbName({'+','-'})
                keylist = zeros(256, 1);
                obj.Keylists = zeros(256, length(options.filters));
                obj.Queues = cell(length(options.filters), 1);
                for i=1:length(options.filters)
                    thiskeylist = zeros(256,1);
                    thiskeylist(KbName(options.filters(i))) = 1;
                    keylist(KbName(options.filters(i))) = 1;
                    obj.Keylists(:,i) = thiskeylist;
                    obj.Queues{i} = CQueue();
                end
            end

            KbName('UnifyKeyNames');
            KbQueueCreate(obj.KbIndex, keylist);

        end

        function delete(obj)
            % Close queue and delete object.
            KbQueueStop(obj.KbIndex);
            KbQueueRelease(obj.KbIndex);
            cellfun(@(x) x.remove(), obj.Queues);
        end

        function start(obj)
            % Start monitoring event queue for this device. 
            KbQueueStart(obj.KbIndex);
        end

        function stop(obj, bflush)
            % Stop monitoring event queue. If bflush is true, the queue is
            % also flushed.
            arguments
                obj (1,1) SplitKbQueue
                bflush (1,1) {mustBeNumericOrLogical} = false
            end
            KbQueueStop(obj.KbIndex);
            if bflush
                obj.flush(true);
            end
        end

        function flush(obj, qind)
            obj.get()

            if qind<1
                % flush all queues
                cellfun(@(x) x.remove(), obj.Queues);
            else
                obj.Queues{qind}.remove();
            end

            % flush ptb queue for good measure. The get() effectively did
            % it I think.
            KbQueueFlush(obj.KbIndex);
        end

        function dumpQueue(obj, qind)
            if obj.Queues{qind}.isempty()
                fprintf('Split queue %d is empty.\n', qind);
            else
                fprintf('Split queue %d has %d elements:\n', qind, obj.Queues{qind}.size());
                while ~obj.Queues{qind}.isempty()
                    e=obj.Queues{qind}.pop();
                    fprintf('%d (%s)\n', e.Keycode, KbName(e.Keycode));
                end
            end
        end

        function dump(obj, qind)
            %Prints information on all events in queue to screen. Queue is
            %cleared when done.

            arguments
                obj (1,1) SplitKbQueue
                qind  {mustBeScalarOrEmpty} = []
            end

            obj.get();
            if isempty(qind)
                for i=1:length(obj.Queues)
                    obj.dumpQueue(i);
                end
            else
                obj.dumpQueue(qind);
            end
        end

        function get(obj)
            %Gets all events from PTB queue and distributes them to saved
            %queues
            while KbEventAvail(obj.KbIndex) 
                [event, ~] = KbEventGet(obj.KbIndex);
                if event.Pressed
                    for i=1:size(obj.Keylists, 2)
                        if obj.Keylists(event.Keycode,i) > 0
                            obj.Queues{i}.push(event);
                            fprintf('add key %s to queue %d\n', KbName(event.Keycode), i);
                        end
                    end
                end
                %fprintf('code %3d (%s) pressed %d t %f\n', event.Keycode, KbName(event.Keycode), event.Pressed, event.Time);
            end
        end
            
        function [tf] = isempty(obj, qind)
            obj.get();
            tf = obj.Queues{qind}.isempty();
        end

        function [keycode, tpressed] = pop(obj, qind)
            obj.get();
            keycode=[];
            tpressed=-1;
            if qind > 0 && qind <= size(obj.Queues, 1)
                event = obj.Queues{qind}.pop();
                keycode = event.Keycode;
                tpressed = event.Time;
            end
        end

        function [isResponse, response, tResp] = response(obj, qind)
            obj.get();
            isResponse = false;
            response = [];
            tResp = -1;
            if qind > 0 && qind <= size(obj.Queues, 1)
                if ~obj.Queues{qind}.isempty()
                    isResponse = true;
                    event = obj.Queues{qind}.pop();
                    tResp = event.Time;
                    keycode = event.Keycode;
                    % If obj.Responses{qind} is empty, then response is
                    % keycode. Otherwise, find keycode in the filter, use
                    % column to grab response. 
                    if isempty(obj.Responses)
                        response = keycode;
                    elseif isempty(obj.Responses{qind})
                        response = keycode;
                    else
                        A=strcmp(obj.Filters{qind}, KbName(keycode));
                        if any(A)
                            if sum(A) > 1
                                error('Found overlapping responses. Check responses arg to constructor.');
                            else
                                response = obj.Responses{qind}{A};
                            end
                        else
                            % this cannot happen
                            error('cannot find keycode in filters?!?!?!');
                        end
                    end
                end
            end
        end    
    end
end