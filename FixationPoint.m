classdef FixationPoint
    %FixationPoint Encapsupate a fixation point, either cross or dot.
    %   Detailed explanation goes here

    properties (Access = public)
        XY
        Diameter
        Color
        DirVecs
    end

    properties (Access = private)
        Type
        Lines
        Rect
        Thickness
    end

    methods
        function obj = FixationPoint(xy,diameter,color,fixptType,thickness,dirvecs)
            %FixationPoint Create a fixation point object.
            %   Detailed explanation goes here

            arguments
                xy (1,2) {mustBeNumeric}
                diameter (1,:) {mustBeNumeric}
                color (1,3) {mustBeNumeric}
                fixptType char {mustBeMember(fixptType, 'o+')} = 'o'
                thickness (1,1) {mustBeNumeric} = 4
                dirvecs {myMustBeMatrix} = []
            end

            obj.XY = xy;
            obj.Diameter = diameter;
            obj.Color = color;
            obj.DirVecs = dirvecs;
            if isscalar(obj.Diameter)
                xdiam = obj.Diameter;
                ydiam = obj.Diameter;
            else
                xdiam = obj.Diameter(1);
                ydiam = obj.Diameter(2);
            end                        

            obj.Type = fixptType;
            switch obj.Type
                case 'o'
                    % make a rectangle that contains the oval
                    obj.Rect = CenterRectOnPoint(SetRect(0, 0, xdiam, ydiam), obj.XY(1), obj.XY(2));
                case '+'
                    % Lines for the fixation "+" sign. The array fixLines has x,y values in
                    % rows, one column for each line segment.
                    obj.Lines = [ ...
                        obj.XY(1) + xdiam/2, obj.XY(2); ...
                        obj.XY(1) - xdiam/2, obj.XY(2); ...
                        obj.XY(1), obj.XY(2) + ydiam/2; ...
                        obj.XY(1), obj.XY(2) - ydiam/2
                        ]';
                    obj.Thickness = thickness;
                otherwise
                    error('Unhandled fixpt type');
            end

        end

        function draw(obj,w,cue)
            %DRAW draw the fixpt currently configured in window w.
            %   Detailed explanation goes here

            arguments
                obj FixationPoint
                w (1,1) {mustBeNumeric}
                cue  {myMustBeCharOrInt} = 'n'
            end

            switch obj.Type
                case 'o'
                    Screen('FillOval', w, obj.Color, obj.Rect);
                    if cue ~='n'
                        warning('Cannot draw cue with oval fixation point.');
                    end
                case '+'
                    Screen('DrawLines', w, obj.Lines, obj.Thickness, obj.Color);

                    % see if we should draw cue
                    if ischar(cue)
                        if cue ~= 'n'
                            switch cue
                                case 'l'
                                    dirvec = [-1,0];
                                case 'r'
                                    dirvec = [1,0];
                                case 'u'
                                    dirvec = [0,1];
                                case 'd'
                                    dirvec = [0,-1];
                            end
                            [~,segments] = getChevrons(obj.XY, dirvec, obj.Diameter/2, 5, obj.Diameter/4, obj.Diameter/4, 1);
                            Screen('DrawLines', w, segments, obj.Thickness, obj.Color);
                        end
                    else
                        if cue > 0
                            if isempty(obj.DirVecs)
                                error('Cannot draw integer cue unless FixationPoint is instantiated with direction vectors.');
                            elseif cue < 0 || cue > size(obj.DirVecs, 1)
                                error('Integer cue value (%d) is not a valid index into direction vectors', cue);
                            else
                                dirvec = obj.DirVecs(cue,:);
                                [~,segments] = getChevrons(obj.XY, dirvec, obj.Diameter/2, 5, obj.Diameter/4, obj.Diameter/4, 1);
                                Screen('DrawLines', w, segments, obj.Thickness, obj.Color);
                            end
                        end
                    end

                otherwise
                    error('Unhandled fixpt type');
            end
        end
    end
end

function myMustBeMatrix(x)
    if ~ismatrix(x)
        error('Must be a matrix.');
    end
end

function myMustBeCharOrInt(x)
    if ischar(x)
        if ~ismember(x,'lrudn')
            error('Char cue must be one of lrudn');
        end
    elseif isnumeric(x)
            mustBeInteger(x);
    end
end