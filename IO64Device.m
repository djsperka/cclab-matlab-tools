classdef IO64Device < handle
    %IO64Device Encapsulate IO64 object
    %   Avoids usage of global, otherwise same as functions and a global.

    properties
        IOObj
    end

    methods
        function obj = IO64Device()
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            obj.IOObj = io64();
            if io64(obj.IOObj) ~= 0
                error('Cannot install IO64 tool. Check that io64.mex is in your path');
            end
        end

        function delete(obj)
            clear obj.IOObj;
        end

        function outp(obj, address, byte)
            io64(obj.IOObj, address, byte);
        end

        function [byte] = inp(obj, address)
            byte = io64(obj.IOObj, address);
        end

    end
end