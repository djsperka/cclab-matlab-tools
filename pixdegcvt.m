classdef pixdegcvt
    %pixdegcvt Class for converting between pixels and visual degrees.
    %   Detailed explanation goes here

%    properties (Access = private)
    properties (SetAccess = immutable)
        PPD
        PPMM
        Wpix
        Hpix
        Wphys
        Hphys
        Dphys
        Type
        NoWarn
    end
    
    methods
        function obj = pixdegcvt(rect, screenwh, screendistance, type, options)
            arguments
                rect (1,4) {mustBeNumeric}
                screenwh (1,2) {mustBeNumeric}
                screendistance (1,1) {mustBeNumeric}
                type char {mustBeMember(type, {'onedeg','fullwidth','accurate'})} = 'fullwidth'
                options.dowarn (1,1) logical = false
            end

            obj.Wpix = rect(3) - rect(1);
            obj.Hpix = rect(4) - rect(2);
            obj.Wphys = screenwh(1);
            obj.Hphys = screenwh(2);
            obj.Dphys = screendistance;
            obj.Type = type;
            obj.NoWarn = options.nowarn;

            switch obj.Type
                case 'onedeg'
                    obj.PPD = obj.Dphys * obj.Wpix * tan(pi/180) / obj.Wphys;
                    obj.PPMM = obj.Wpix / obj.Wphys;
                case 'fullwidth'
                    thetaDEG = atan2(0.5*obj.Wphys, obj.Dphys) * 180 / pi;
                    obj.PPD = 0.5 * obj.Wpix / thetaDEG;
                    obj.PPMM = obj.Wpix / obj.Wphys;
                case 'accurate'
                    obj.PPD = 0;
                    obj.PPMM = 0;
            end
        end
        
        function PIX = deg2pix(obj, DEG)
            %deg2pix Convert values from degrees to pixels. 
            %   Use this for lengths, e.g. diameter, not coordinates. See deg2scr for x,y pairs.
            if ~isscalar(DEG) && ~obj.NoWarn
                warning('Using deg2pix on a non-scalar object. Use this method for lengths, use deg2scr to get screen coordinates.');
            end
            if ~strcmp(obj.Type,'accurate')
                PIX = arrayfun(@(deg) obj.PPD*deg, DEG);
            else
                PIX = arrayfun(@(deg) obj.Dphys*tan(deg*pi/180)*obj.Wpix/obj.Wphys, DEG);
            end
        end

        function MM = deg2mm(obj, DEG)
            %deg2mm Convert values from degrees to mm. Only works when this
            %object created with w,h. When created with fovx, will warn bu
            %take a guess. 
            pix = obj.deg2pix(DEG);
            ppmm = obj.PPMM;
            if isnan(obj.PPMM)
                ppmm = 3;
                warning('pixdegconverter is just guessing at the pixel size.')
            end
            MM = arrayfun(@(p) p/ppmm, pix);
        end
        
        function SCRPAIRS = deg2scr(obj, DEGPAIRS)
            %deg2scr Convert eye coord degrees x,y pairs to PTB screen
            %coords. Input must be nx2.            
            if size(DEGPAIRS, 2) ~= 2
                error('deg2scr inputs must be Nx2');
            end
            if ~strcmp(obj.Type,'accurate')
                SRCX = arrayfun(@(xdeg) obj.PPD*xdeg+obj.Wpix/2, DEGPAIRS(:,1));
                SRCY = arrayfun(@(ydeg) -obj.PPD*ydeg+obj.Hpix/2, DEGPAIRS(:,2));
            else
                SRCX = arrayfun(@(xdeg) obj.deg2pix(xdeg)+obj.Wpix/2, DEGPAIRS(:,1));
                SRCY = arrayfun(@(ydeg) -obj.deg2pix(ydeg)+obj.Hpix/2, DEGPAIRS(:,2));
            end
            SCRPAIRS = horzcat(SRCX, SRCY); 
        end
        
        function DEG = pix2deg(obj, PIX)
            %deg2pix Summary of this method goes here
            %   Detailed explanation goes here            

            if ~isscalar(PIX) && ~obj.NoWarn
                warning('Using pix2deg on a non-scalar object. Use this method for lengths, not coordinates.');
            end

            if ~strcmp(obj.Type,'accurate')
                % convert the pixels to a distance from (0,0)
                DEG = arrayfun(@(pix) pix/obj.PPD, PIX);
            else
                DEG = arrayfun(@(pix) 180/pi*atan2(pix*obj.Wphys/obj.Wpix, obj.Dphys), PIX);
            end
        end
    end
end
