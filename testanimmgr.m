function testanimmgr(w)

    % get rect
    wrect = Screen('Rect', w);
    [x, y] = RectCenter(wrect);
    s.rect=CenterRectOnPoint([0 0 50 50],x,y); 
    s.thick=0;

    s.on=1;
    s.off=5;
    s.ramp=2;
    s.color=[.7 .3 .4];
    t0 = tic;
    anim=AnimMgr([0 5],@animMgrSampleCallback,s);
    anim.start();
    while anim.animate(w) 
        Screen('Flip',w);
    end
    % This last flip makes the cleanup visible.
    Screen('Flip',w);

end