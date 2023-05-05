function kbqdemo()


% Get device index, use the first one found if more than one
mkind = cclabGetMilliKeyIndices();
if isempty(mkind)
    error('No MilliKey devices found');
end
ind = mkind(1);

% Create and start queue
PsychHID('KbQueueCreate', ind);



% Here, react to each keypress as it comes in. Since the queue runs in its
% own thread, it can accumulate events once it is started with
% 'KbQueueStart'. 
%
% Use KbEventAvail to tell you if any events are present in the queue. 
% 

fprintf('\nDemo #1: Reacting to keypresses as they occur:\n\nPress keys on the Millikey. \nAs each key is pressed and released, the time held down is printed.\nHold center key down for more than 2 sec to end.\n');


t0 = GetSecs();
PsychHID('KbQueueStart', ind);

t1 = 0; % key press time (event.Pressed == 1)
t2 = 0; % key release time (event.Pressed == 0)
iquit = 0;
while ~iquit

   % Use KbEventAvail to tell if there is anything available.
   while ~iquit && KbEventAvail(ind)
       [event, nremaining] = KbEventGet(ind);
       if event.Pressed
           t1 =  event.Time;
       else
           t2 = event.Time;
           fprintf('keycode %d, held down for %f, time lapsed since start %f\n', event.Keycode, t2-t1, t1-t0);
           if event.Keycode == 37 & (t2-t1) > 2
               iquit = 1;
           end
       end
   end

   ~iquit && WaitSecs(.1);
end

% stop the queue from collecting events
PsychHID('KbQueueStop', ind);

% Flush all events from the queue, or they will remain in queue if/when you 
% call 'KbQueueStart' again! 
KbEventFlush(ind);


% Here, allow the queue to collect events during a fixed period. After the
% period ends, stop the queue and count up the keypresses.

fprintf('\nDemo #2: Collecting keypresses for later analysis:\n\nWe will start a queue and leave it open for 10 seconds. Press any keys on the Millikey during this time. \nAfter 10 seconds, a summary will be printed.\n\nPress any key to start.\n');
pause;
fprintf('\nNow press keys on the Millikey...');


lastsec = 0;        % keep track of how many seconds have passed to limit printing below
t0 = GetSecs();
PsychHID('KbQueueStart', ind);
t = GetSecs();
while t < t0+10
    WaitSecs(0.1);
    if floor(t-t0) > lastsec
        lastsec = floor(t-t0);
        fprintf('%d sec: %d events in queue\n', lastsec, KbEventAvail(ind));
    end
    t = GetSecs();
end
PsychHID('KbQueueStop', ind);
fprintf('\nQueue is stopped.\nThere are %d events in the queue\n', KbEventAvail(ind));
fprintf('\nIterate over the events in queue and count keypresses, and sum the time each key held down:\n');

tpressed = 0;
counter = 0;    % total number of keypresses
keypresses = zeros(1,5);
keydown = zeros(1,5);
mkeycodes = [11, 12, 13, 14, 37];
while KbEventAvail(ind)
    [event, nremaining] = KbEventGet(ind);
    keyind = find(mkeycodes == event.Keycode);
    if event.Pressed
        tpressed = event.Time;
    else
        counter = counter + 1;
        keypresses(keyind) = keypresses(keyind) + 1;
        keydown(keyind) = keydown(keyind) + event.Time-tpressed;
    end
end

% The queue is now empty! We effectively flushed it by getting all events
% until KbEventAvail returns 0. 

fprintf('\nCounted %d total keypress/release sequences\n', counter);
for i=1:length(keypresses)
    if keypresses(i) == 0
        fprintf('%d keycode %d: 0\n', i, mkeycodes(i));
    else
        fprintf('%d keycode %d: %d (total %f, avg %f)\n', i, mkeycodes(i), keypresses(i), keydown(i), keydown(i)/keypresses(i));
    end
end
