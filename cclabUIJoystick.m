function [pos] = cclabUIJoystick(codes)
%cclabUIJoystick A modal dialog to use as a dummy joystick.
%   Blocks until a button is pushed. Returns 1/0/-1 for L,C,R respectively.
%   Returns NaN if dialog is closed via the X button,

    if length(codes) > 2
        error('Max of 2 axes for the ui joystick');
    end


    value = nan;
    position = [0 800 400 100];
    c_yellow=[.95, .95, .7];

    if isempty(codes)
        usecodes = '?';
    else
        usecodes = codes;
    end
    pos = nan(1, length(usecodes)); % when all are ~nan, we are done


    % open dialog window
    d = dialog('Position', position, 'Name', 'Choose joystick pos');


    % If there are two codes, we make two rows of buttons

    for i=1:length(usecodes)

        if i==1
            if length(codes) == 2
                btnposition = [.1 .2 .2 .2];    % re-use this by setting x=.1, .4, .7
            else
                btnposition = [.1 .4 .2 .2];    % re-use this by setting x=.1, .4, .7
            end
        else
            btnposition = [.1 .6 .2 .2];    % re-use this by setting x=.1, .4, .7
        end

        lblposition = btnposition;
        lblposition(1) = 0.0;
        lblposition(2) = lblposition(2)+0.05;
        lblposition(3) = .15;
        lblposition(4) = .15;

        % label
        uicontrol('Parent', d, ...
            'Style','text', ...
            'String', usecodes(i), ...
            'Units', 'normalized', ...
            'Position', lblposition);

        %   left button
        uicontrol('Parent', d, ...
            'style','pushbutton',...
            'units','normalized',...
            'position', btnposition,...
            'string','+1',...
            'backgroundcolor', c_yellow,...
            'fontweight','bold',...
            'callback', {@buttonPushed, i, 1});
        
        %   center
        btnposition(1) = .4;
        uicontrol('Parent', d, ...
            'style','pushbutton',...
            'units','normalized',...
            'position', btnposition,...
            'string','0',...
            'backgroundcolor', c_yellow,...
            'fontweight','bold',...
            'callback', {@buttonPushed, i, 0});
        
        %   right
        btnposition(1) = .7;
        uicontrol('Parent', d, ...
            'style','pushbutton',...
            'units','normalized',...
            'position', btnposition,...
            'string','-1',...
            'backgroundcolor', c_yellow,...
            'fontweight','bold',...
            'callback', {@buttonPushed, i, -1});
    end    
    function buttonPushed(src, event, icode, value)
        pos(icode) = value;
        if ~any(isnan(pos))
            delete(gcf);
        end
    end
    
    uiwait(d);

end