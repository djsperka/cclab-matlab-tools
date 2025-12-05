classdef Rectangle
    %Rectangle Summary of this class goes here
    %   Detailed explanation goes here

    properties
        X
        Y
        Width
        Height
        Color
        Filled
        PenWidth
    end

    properties (Dependent)
        Rect
        XY
    end

    methods
        function obj = Rectangle(options)
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                options.rect (1,4) {mustBeNumeric} = [NaN, NaN, NaN, NaN]
                options.xy (1,2) {mustBeNumeric} = [NaN, NaN]
                options.width (1,1) {mustBeNumeric} = [NaN]
                options.height (1,1) {mustBeNumeric} = [NaN]
                options.color (1,3) {mustBeNumeric} = [.5,.5,.5];
                options.penwidth (1,1) {mustBeNumeric} = 4
                options.filled (1,1) {mustBeNumericOrLogical} = false
            end

            % must have rect or xy&width&height
            if ~any(isnan(options.rect))
                obj.Rect = options.rect;
            elseif ~any(isnan(options.xy)) && ~isnan(options.width) && ~isnan(options.height)
                obj.XY = options.xy;
                obj.Width = options.width;
                obj.Height = options.height;
            else
                error('Must specify rect or all three of (xy, width, height)');
            end
            obj.Color = options.color;
            obj.Filled = options.filled;
            obj.PenWidth = options.penwidth;
        end

        function rect = get.Rect(obj)
            rect = CenterRectOnPoint(SetRect(0,0,obj.Width,obj.Height), obj.X, obj.Y);
        end

        function obj = set.Rect(obj, rect)
            [obj.X, obj.Y] = RectCenter(rect);
            [obj.Width, obj.Height] = RectSize(rect);
        end

        function xy = get.XY(obj)
            xy = [obj.X, obj.Y];
        end

        function obj = set.XY(obj, xyval)
            arguments
                obj Rectangle
                xyval (1,2) {mustBeNumeric}
            end
            obj.X = xyval(1);
            obj.Y = xyval(2);
        end
                
        function draw(obj,w)
            %DRAW draw the rectangle currently configured in window w.
            %   Detailed explanation goes here

            arguments
                obj Rectangle
                w (1,1) {mustBeNumeric}
            end

            if obj.Filled
                Screen('FillRect', w, obj.Color, obj.Rect);
            else
                Screen('FrameRect', w, obj.Color, obj.Rect, obj.PenWidth);
            end
        end
    end
end