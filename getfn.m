function [F] = getfn(varargin)
%getfn Opens selection dialog, choose file(s), returns full path(s) to each
%file selected.
%   Convenience for getting full filenames of data files etc.

    p=inputParser;
    p.addRequired('InitialDir', @(x) isfolder(x));
    p.addOptional('Filter', {'*.mat'}, @(x) iscellstr(x));
    p.addOptional('Relative', false, @(x) islogical(x));
    p.addOptional('Prompt', 'Select data file(s)', @(x) ischar(x));
    p.parse(varargin{:});
    
    [files, location] = uigetfile(p.Results.Filter, p.Results.Prompt, p.Results.InitialDir, MultiSelect='on');
    
    F={};
    if ~isempty(files)
    
        if ~p.Results.Relative
            func = @(x) fullfile(location, x);
        else
            func = @(x) strrep(fullfile(location, x), p.Results.InitialDir, '');
        end
        if ischar(files)
            %F = fullfile(location, files);
            F = func(files);
        else
            %F = cellfun(@(x) fullfile(location, x), files', UniformOutput=false);
            F = cellfun(func, files', UniformOutput=false);
        end
    end

end