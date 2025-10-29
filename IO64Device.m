classdef IO64Device < handle
    %IO64Device Encapsulate IO64 object
    %   Avoids usage of global, otherwise same as functions and a global.

    properties
        IOObj
        Address
    end

    methods
        function obj = IO64Device(address)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            obj.IOObj = io64();
            obj.Address = address;
            if io64(obj.IOObj) ~= 0
                error('Cannot install IO64 tool. Check that io64.mex is in your path');
            end
        end

        function delete(obj)
            clear obj.IOObj;
        end

        function outp(obj, byte)
            io64(obj.IOObj, obj.Address, byte);
        end

        function [byte] = inp(obj)
            byte = io64(obj.IOObj, obj.Address);
        end

    end
end