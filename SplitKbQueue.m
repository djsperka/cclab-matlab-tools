classdef SplitKbQueue < handle
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
        KbQueueCreated
        KbQueueStarted
        QindStarted
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
            obj.KbQueueCreated = false;
            obj.KbQueueStarted = false;

            % do this before anything else
            KbName('UnifyKeyNames');


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
                % For each filter given, create a CQueue object to hold its
                % events.
                keylist = zeros(256, 1);
                obj.Keylists = zeros(256, length(options.filters));
                obj.Queues = cell(length(options.filters), 1);
                obj.QindStarted = false(length(options.filters), 1);
                for i=1:length(options.filters)
                    thiskeylist = zeros(256,1);
                    thiskeylist(KbName(options.filters(i))) = 1;
                    keylist(KbName(options.filters(i))) = 1;
                    obj.Keylists(:,i) = thiskeylist;
                    obj.Queues{i} = CQueue();
                end
            end

            KbQueueCreate(obj.KbIndex, keylist);
            obj.KbQueueCreated = true;

        end

        function delete(obj)
            % Close queue and delete object.
            KbQueueStop(obj.KbIndex);
            KbQueueRelease(obj.KbIndex);
            cellfun(@(x) x.remove(), obj.Queues);
        end

        function start(obj, qind)
            % Start monitoring event queue for the qind given. if qind<1, 
            % start all of them. Check if the underlying queue is started
            % and start if needed.
            
            if qind > length(obj.Filters)
                error('qind (%d) out of range 1-%d', qind, length(obj.Filters));
            end

            if ~obj.KbQueueStarted
                KbQueueStart(obj.KbIndex);
                obj.KbQueueStarted = true;
            end
            if qind<1
                obj.QindStarted(:) = true;
            else
                obj.QindStarted(qind) = true;
            end
        end

        function stop(obj, qind, bflush)
            % Stop monitoring event queue. If bflush is true, the queue is
            % also flushed.
            arguments
                obj (1,1) SplitKbQueue
                qind (1,1) {mustBeNumeric} = 0
                bflush (1,1) {mustBeNumericOrLogical} = false
            end

            obj.get();

            if qind > length(obj.Filters)
                error('qind (%d) out of range 1-%d', qind, length(obj.Filters));
            end

            if qind<1
                KbQueueStop(obj.KbIndex);
                obj.KbQueueStarted = false;
                obj.QindStarted(:) = false;
            else
                obj.QindStarted(qind) = false;
            end

            if bflush
                obj.flush(qind);
            end
        end

        function flush(obj, qind)

            % Get everything out of the KbQueue. Note that this effectively
            % flushes this queue, so we don't explicitly call KbQueueFlush.
            obj.get()

            if qind<1
                % flush all queues
                cellfun(@(x) x.remove(), obj.Queues);
            else
                obj.Queues{qind}.remove();
            end
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
            %queues, if they are started.
            while KbEventAvail(obj.KbIndex) 
                [event, ~] = KbEventGet(obj.KbIndex);
                if event.Pressed
                    for i=1:size(obj.Keylists, 2)
                        if obj.Keylists(event.Keycode,i) > 0
                            if obj.QindStarted(i)
                                obj.Queues{i}.push(event);
                                fprintf('add key %s to queue %d\n', KbName(event.Keycode), i);
                            else
                                fprintf('skip key %s queue %d stopped\n', KbName(event.Keycode), i);
                            end
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