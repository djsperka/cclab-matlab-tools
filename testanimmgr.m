function testanimmgr(w)

    % Create animation manager
    anim = AnimMgr();

    % get rect
    wrect = Screen('Rect', w);
    [x, y] = RectCenter(wrect);
    s.rect=CenterRectOnPoint([0 0 50 50],x,y); 
    s.thick=0;
    s.on=1;
    s.off=5;
    s.ramp=2;
    s.color=[.7 .3 .4];
    s.values=[];

    anim.start(@animMgrSampleCallback, [0,5], s);
    while anim.animate(w) 
        Screen('Flip',w);
    end
    anim.UserData.values

end