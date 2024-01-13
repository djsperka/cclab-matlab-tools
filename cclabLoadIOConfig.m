function [cConfig] = cclabLoadIOConfig(varargin)
%cclabLoadIOConfig Load a config file telling us how to configure cclab io
%to enable cclabReward, cclabPulse, cclabJoystick stuff. 
%   Detailed explanation goes here

    if nargin ~= 1
        error('Need just one arg');
    end

    % Form some potential filenames. 
    % It is assumed that there is a folder named 'cfg' in the same folder
    % where the current file is found. 
    % Pass a full pathname 
    % or 
    % just the basename (e.g. 'rig-right-adio') of a file (with .txt 
    % extension) in the cfg folder
    % or 'dummy' for a config that will work (sort of)

    filename = varargin{1};
    currentFile = mfilename("fullpath");
    containingFolder = fileparts(currentFile);
    defaultConfigFile = fullfile(containingFolder, 'cfg', 'rig-right.txt');
    dummyConfigFile = fullfile(containingFolder, 'cfg', 'dummy.txt');
    maybeBasenameFile = fullfile(containingFolder, 'cfg', strcat(filename, '.txt'))

    % Check whether a filename was passed as an arg
    % if not, check if a basename was passed, 
    % if not, was it 'dummy'?
    % if not, use the default
    cConfig = [];
    if isfile(filename)
        fid = fopen(filename);
        cConfig = textscan(fid, "%s\t%s\t%s\t%s");
        fprintf('loaded from passed filename %s\n', filename);
    elseif isfile(maybeBasenameFile)
        fid = fopen(maybeBasenameFile);
        cConfig = textscan(fid, "%s\t%s\t%s\t%s");
        fprintf('loaded from passed basename %s\n', maybeBasenameFile);
    elseif contains(filename, 'dummy', 'IgnoreCase', true)
        fid = fopen(dummyConfigFile);
        cConfig = textscan(fid, "%s\t%s\t%s\t%s");
        fprintf('loaded dummy config %s\n', dummyConfigFile);
    else
        fid = fopen(defaultConfigFile);
        cConfig = textscan(fid, "%s\t%s\t%s\t%s");
        fprintf('loaded default config %s\n', defaultConfigFile);
    end        
    fclose(fid);
end