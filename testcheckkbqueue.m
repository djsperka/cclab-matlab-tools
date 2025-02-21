KbQueueCreate(6);
KbQueueStart(6);
tStart = GetSecs();
while GetSecs - tStart < 10
    [keyCode, keyPressed, tEvent] = checkKbQueue(6,1);
    if keyCode > 0
        fprintf('KbName(%d) = %s pressed %d t %f\n',keyCode, KbName(keyCode), keyPressed, tEvent);
    else
        fprintf('No event\n');
    end
    WaitSecs(0.5);
end
