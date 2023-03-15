function kbqdemo()


% Get device index, use the first one found if more than one
mkind = cclabGetMilliKeyIndices();
if isempty(mkind)
    error('No MilliKey devices found');
end
ind = mkind(1);

% Create and start queue
PsychHID('KbQueueCreate', ind);

t0 = GetSecs();
PsychHID('KbQueueStart', ind);

t1 = 0; % key press
t2 = 0; % key release
iquit = 0;
while ~iquit

   % Use KbEventAvail to tell if there is anything available.
   while ~iquit && KbEventAvail(ind)
       [event, nremaining] = KbEventGet(ind);
       if event.Pressed
           t1 =  event.Time;
           if event.Keycode == 37
               iquit = 1;
           end
       else
           t2 = event.Time;
           fprintf('keycode %d, lapsed %f, down %f\n', event.Keycode, t1-t0, t2-t1);
       end
   end

   ~iquit && WaitSecs(.1);
end

% stop the queue from collecting events
PsychHID('KbQueueStop', ind);

% Flush all events from the queue, or they will remain in queue if/when you 
% call 'KbQueueStart' again! 
KbEventFlush(ind);
