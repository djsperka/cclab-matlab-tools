classdef AnimMgr < handle
    %AnimMgr Manages simple animations on a PTB window.
    %   This class can be used to create short animations on a PTB window.
    %   When creating this object, supply a callback function that draws
    %   the animation steps. The basic usage looks like this:
    %   
    %   anim=AnimMgr([0 5],@callback,s);
    %   anim.start();
    %   while anim.animate(w) 
    %       Screen('Flip',w);
    %   end
    %   Screen('Flip',w);
    % 
    %   The job of the callback function is to draw the steps of the
    %   animation, and to clean up when done. The callback signature should
    %   look like this:
    %
    %   [tfContinue, D] = callback(n, t, minmax, w, userData)
    % 
    %   'n' is which step (1,2,...) in the animation has been reached, 't'
    %   is the time since start() was called. minmax is a 2-element vector,
    %   in seconds, of the time (measured from start()) when the callback
    %   function will be called. The callback will be called once after the
    %   max time is passed, with n==0. In this call, cleanup can be
    %   performed to restore the screen to a specific state if needed.
    %   During the animation period (when the callback is being called),
    %   if the callback returns true the process continues. If the callback
    %   returns false, however, the animation is stopped at that point (and
    %   no cleanup call is made to the callback function). 
    %   A piece of user data can be passed to the callback function. The
    %   second return arg is for the callback to return that same piece of
    %   data. The data is saved (and if the callback makes changes, then
    %   those changes will be preserved, and the updated data is passed to
    %   the callback on the next call.

    properties (Access = private)
        Callback
        CallbackCounter
        UserData
        MinMax
        Started
        TeeZero
    end

    methods
        function obj = AnimMgr(minmax, cbFnc, userData)
            %AnimMgr Manage one or more animations
            %   Each animator needs a [min,max], a callback, and an
            %   optional cell of user data.

            obj.MinMax = minmax;
            obj.Callback = cbFnc;
            obj.CallbackCounter = 0;
            obj.UserData = userData;
            obj.Started = false;
            obj.TeeZero = -1;
        end

        function start(obj, varargin)
            % Start the animation timer, can call animate() after this.
            obj.Started = true;
            obj.TeeZero = GetSecs;
            obj.CallbackCounter = 0;
            if nargin>1
                obj.UserData = varargin{1};
            end
        end

        function stop(obj)
            % Stop the animation. Callback function will not be called,
            % even if animate() is called after this.
            obj.Started = false;
            obj.TeeZero = -1;
        end

        function tf = animate(obj,w)
            %animate will call the callback function until either
            %   the max time is exceeded(*), or the callback function
            %   returns false. In both cases, the callback is called once
            %   more to allow cleanup.
            %   

            if ~obj.Started
                error('AnimMgr is not started. Call start()');
            end
            tf = false;
            t1 = GetSecs;
            t = t1 - obj.TeeZero;
            if t >= obj.MinMax(1) && t <= obj.MinMax(2)
                obj.CallbackCounter = obj.CallbackCounter + 1;
                [tfThisCallback, D] = obj.Callback(obj.CallbackCounter, t, obj.MinMax, w, obj.UserData);
                obj.UserData = D;
                if tfThisCallback
                    tf = true;
                end
            else
                % When the time has been exceeded, we will make one more
                % call (with the index=0) to tell the callback that it
                % should cleanup if that's necessary. Doing nothing is OK,
                % as that will get you a clean background screen, if that's
                % what you want. Restore whatever you need to:
                [~, D] = obj.Callback(0, t, obj.MinMax, w, obj.UserData);
                obj.UserData = D;
                obj.stop();   % this will make any calls to animate fail
                % ignore return value from callback, return false, 
                % because we're all done.
                tf = false;
            end
        end
    end
end