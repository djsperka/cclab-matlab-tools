classdef imageset
    %imageset Create textures for display on a PTB screen, from a set of 
    % images. The images can be in a single or multiple folders. Images may
    % be modified when loaded, or prior to creation of texture. User must
    % free generated textures by calling Screen('Close', textureID). Images
    % can be loaded from any number of subfolders (relative to the root
    % folder).
    % Each image is given a unique key. The basename of the image file
    % forms part of the key. When images are loaded from subfolders, a
    % folder key is prepended to the key. This is useful when you have
    % multiple groups of images, all with the same basename, but in
    % different folders. Each folder may have different processing, for
    % example. 
    % In ethosal experiment, we use images that have two types of
    % processing: black and white, and a texturized version. The black and
    % white images are in a subfolder called 'bw', and the texturized images
    % are in a subfolder called 'tex'. The subfolders argument used is
    % {'H','bw';'L','texture'}. The images loaded from the 'bw' folder have
    % "H/" as a prefix. An image named "99.bmp" in this folder would have
    % the key "H/99". The image named "99.bmp" in the 'texture' folder
    % would have the key "L/99". 
    % Images with the same key (including folder key) are not allowed.
    % All images are read and saved unless the 'Lazy' flag is
    % set to true (it is false by default).
    
    properties
        Extensions
        Root
        Name
        ParamsFunc
        Subfolders
        OnLoadFunc
        IsBalanced
        BalancedFileKeys
        MissingKeys
        Bkgd
        IsUniform
        UniformOrFirstRect
        MaskParameters
    end

    properties (Access = private)
        TextureParser
        Images
        ShowName
        Lazy
    end

    methods
        function obj = imageset(varargin)
            %imageset Load images from a set of folders. Each folder has a
            %key prefix. Full key for each file is prefix + '/' + basename.
            %   Detailed explanation goes here
            
            % arguments
            %     root {mustBeFolder}
            %     options.ParamsFunc {mustBeText} = ''
            %     options.SubFolders {mustBeProperSubfolderCell} = {}
            %     options.Extensions {mustBeText} = {'.bmp', '.jpg', '.png'};
            %     options.OnLoad
            % 
            % 

            p = inputParser;
            %addRequired(p, 'Root', @(x) ischar(x) && isdir(x));
            addRequired(p, 'Root');
            addOptional(p,'ParamsFunc','', @(x) ischar(x));
            addParameter(p, 'Subfolders', {'', '.'}, @(x) (isempty(x) || (iscell(x) && size(x, 2)==2 && all(cellfun(@(y) (ischar(y) || iscellstr(y)), x), 'all'))));
            addParameter(p, 'Extensions', {'.bmp', '.jpg', '.png'});
            addParameter(p, 'OnLoad', [], @(x) isempty(x) || isa(x, 'function_handle'));  % check if isempty()
            addParameter(p, 'MaskParameters', [], @(x) isnumeric(x) && ismember(length(x), [1 3 4])); % This and 'OnLoad' cannot happen at same time
            addParameter(p, 'Bkgd', [.5; .5; .5], @(x) isnumeric(x) && iscolumn(x) && length(x)==3);
            addParameter(p, 'ShowName', false, @(x) islogical(x));
            addParameter(p, 'Lazy', false, @(x) islogical(x));
            
            p.parse(varargin{:});


            % Test params func arg.
            % if ~isfile(fullfile(p.Results.Root,[p.Results.ParamsFunc,'.m']))
            %     error('Cannot find params func for this imageset: %s', fullfile(p.Results.Root,[p.Results.ParamsFunc,'.m']));
            % end
            obj.Root = p.Results.Root;
            obj.ParamsFunc = p.Results.ParamsFunc;

            % last folder of Root is the imageset name
            c=split(strip(obj.Root,filesep),filesep);
            obj.Name = c{end};


            % If a params func is used, load it and assign values. 
            % If the filename looks at all like a pathname, then we assume
            % the intention is to run the script in that location.
            % If no params func argument given, look for a 'params.m' file
            % in the root folder.
            if ~isempty(p.Results.ParamsFunc)
                [path, base, ~] = fileparts(p.Results.ParamsFunc);
                if isempty(path)
                    currentDir=pwd;
                    cd(p.Results.Root);
                    Y=eval(base);
                    cd(currentDir);
                else
                    currentDir=pwd;
                    cd(obj.Root);
                    Y=eval(base);
                    cd(currentDir);
                end
            else
                Y=struct;
            end

            if isfield(Y,'Subfolders')
                obj.Subfolders = Y.Subfolders;
            else
                obj.Subfolders = p.Results.Subfolders;
            end
            if isfield(Y,'Extensions')
                obj.Extensions = Y.Extensions;
            else
                obj.Extensions = p.Results.Extensions;
            end
            if isfield(Y,'OnLoadFunc')
                obj.OnLoadFunc = Y.OnLoadFunc;
            else
                obj.OnLoadFunc = p.Results.OnLoad;
            end
            if isfield(Y,'Bkgd')
                obj.Bkgd = Y.Bkgd;
            else
                obj.Bkgd = p.Results.Bkgd;
            end
            if isfield(Y,'ShowName')
                obj.ShowName = Y.ShowName;
            else
                obj.ShowName = p.Results.ShowName;
            end
            if isfield(Y,'Lazy')
                obj.Lazy = Y.IsLazy;
            else
                obj.Lazy = p.Results.Lazy;
            end
            if isfield(Y,'MaskParameters')
                obj.MaskParameters = Y.MaskParameters;
            else
                obj.MaskParameters = p.Results.MaskParameters;
            end
            if obj.ShowName
                if exist('insertText', 'file')~=2
                    warning('Cannot use ShowName=true on this machine. Cannot find insertText() - must have Computer Vision Toolbox installed. Will continue without this setting.');
                    obj.ShowName = false;
                end
            end

            % Cannot have OnLoadFunc and MaskParameters at same
            % time.
            if ~isempty(obj.OnLoadFunc) && ~isempty(obj.MaskParameters)
                error('Cannot have more than one of OnLoadFunc, MaskParameters!');
            elseif isempty(obj.OnLoadFunc) && ~isempty(obj.MaskParameters)
                switch length(obj.MaskParameters)
                    case 1
                        obj.OnLoadFunc = @(x) imresize(x, [obj.MaskParameters(1), obj.MaskParameters(1)]);
                    case 3
                        m=obj.MaskParameters;
                        M = makeGaussianEdgeMask(m(1), m(2), m(3));
                        obj.OnLoadFunc = @(x) uint8(((double(x)-128) .* M) + 128);
                    case 4
                        m=obj.MaskParameters;
                        M = makeGaussianEdgeMask(m(2), m(3), m(4));
                        obj.OnLoadFunc = @(x) uint8(((double(imresize(x, [m(1), m(1)]))-128) .* M) + 128);
                end
            end

            % Holds images after loading.
            obj.Images = containers.Map;
            
            % create parser for texture() function
            obj.TextureParser = inputParser;
            addRequired(obj.TextureParser, 'Window', @(x) isscalar(x));
            %addRequired(obj.TextureParser, 'Key', @(x) (ischar(x) && obj.Images.isKey(x)) || (isstring(x) && all(obj.Images.isKey(x))));
            addRequired(obj.TextureParser, 'Key', @(x) (ischar(x) && obj.Images.isKey(x)) || (isstring(x) && all(obj.Images.isKey(x))) || (iscellstr(x) && all(obj.Images.isKey(x))));
            addOptional(obj.TextureParser, 'PreProcessFunc', [], @(x) isempty(x) || isa(x, 'function_handle') || (iscell(x) && all(cellfun(@(x)isa(x,'function_handle'), x))));

            % now process files. Each row of the cell array is two elements
            % - the key and the subfolder. The subfolder arg itself can be
            % a cell array; multiple subfolders can be incorporated (but
            % duplicate filenames are not allowed)
            for i=1:size(obj.Subfolders, 1)
                if ~iscell(obj.Subfolders{i,2})
                    useSubFolderName = obj.Subfolders{i,2};
                    c = add_images_from_folder(obj, fullfile(obj.Root, useSubFolderName), obj.Subfolders{i,1});
                    fprintf('Found %d images in ''%s'' folder %s\n', c, obj.Subfolders{i,1}, fullfile(obj.Root, useSubFolderName));
                else
                    folderCell = obj.Subfolders{i,2};
                    for j=1:length(folderCell)
                        useSubFolderName = folderCell{j};
                        c = add_images_from_folder(obj, fullfile(obj.Root, useSubFolderName), obj.Subfolders{i,1});
                        fprintf('Found %d images in ''%s'' folder %s\n', c, obj.Subfolders{i,1}, fullfile(obj.Root, useSubFolderName));
                    end
                end
                % if iscell(obj.Subfolders{i,2})
                %     z=cellfun(@(x) isfolder(fullfile(obj.Root, x)), obj.Subfolders{i,2});
                %     if isscalar(find(z))
                %         useSubFolderName = obj.Subfolders{i,2}{z};
                %     else
                %         exception = MException('imageset:imageset:BadInput', sprintf('No suitable subfolders found for key %s\n', obj.Subfolders{i,1}));
                %         throw(exception);
                %     end
                % end
                % c = add_images_from_folder(obj, fullfile(obj.Root, useSubFolderName), obj.Subfolders{i,1});
                % fprintf('Found %d images in ''%s'' folder %s\n', c, obj.Subfolders{i,1}, fullfile(obj.Root, useSubFolderName));
            end
            
            % check key balance
            [obj.IsBalanced, obj.BalancedFileKeys, obj.MissingKeys] = check_key_balance(obj);

            % check for uniform size, make background image, add with key
            % BKGD

            if ~obj.Lazy
                [obj.IsUniform, obj.UniformOrFirstRect] = check_sizes(obj);
                image = ones(obj.UniformOrFirstRect(4), obj.UniformOrFirstRect(3), 3).*reshape(obj.Bkgd, 1, 1, 3);
                obj.Images('BKGD') = struct('fname', 'NO_FILENAME', 'image', image);
            else
                obj.IsUniform = false;
                obj.UniformOrFirstRect = [];
                obj.Images('BKGD') = struct('fname', 'NO_FILENAME', 'image', []);
            end

        end
        
        
        function textureID = texture(obj, varargin)
            %texture call MakeTexture for this image, with opt. contrast
            %[0,1]
            %   Detailed explanation goes here
            
            
            % parse
            obj.TextureParser.parse(varargin{:});
            w = obj.TextureParser.Results.Window;
            key = obj.TextureParser.Results.Key;

            % Generate textures, depends on whether key is a cell array or
            % not, and whether preprocess func is cell or not. 
            if ~iscell(key)
                if isempty(obj.TextureParser.Results.PreProcessFunc)
                    textureID = Screen('MakeTexture', w, obj.get_image(key));
                else
                    textureID = Screen('MakeTexture', w, obj.TextureParser.Results.PreProcessFunc(obj.get_image(key)));
                end
            else
                % if preprocessfunc is empty, use @deal
                % if its a single function, apply it to all images. 
                % if its a cell array of same size() as the keys, then use
                % cellfun 
                ppfunc = obj.TextureParser.Results.PreProcessFunc;
                if isempty(ppfunc)
                    ppfunc = @deal;
                end
                if isa(ppfunc, 'function_handle')
                    textureID = cellfun(@(k) Screen('MakeTexture', w, ppfunc(obj.get_image(k))), key);
                else
                    textureID = cellfun(@(k,f) Screen('MakeTexture', w, f(obj.get_image(k))), key, ppfunc);
                end              
            end
        end
        
        function [r, isUniform] = rect(obj, k)
            % Return rect that contains the image with key 'k'. If 'k' is
            % omitted or empty, then returns the rect for all images in the
            % imageset. 'isUniform' tells whether all images in this set
            % have the same size. If an imageset is NOT uniform, the rect
            % returned for "all images" is the rect of the first image
            % read, so good luck.
         
            arguments
                obj (1,1) imageset
                k {mustBeTextScalar} = ''
            end
            isUniform = obj.IsUniform;
            if strlength(k) > 0
                key = obj.parse_key(k);
                r = [0 0 size(obj.get_image(key), 1:2)];
            else
                r = obj.UniformOrFirstRect;
            end
        end
        
        function flip(obj, varargin)
            try
                obj.TextureParser.parse(varargin{:});
                w = obj.TextureParser.Results.Window;
                if Screen('WindowKind', w)==1
                    Screen('FillRect', w, [.5 .5 .5]);
                    tex = obj.texture(varargin{:});
                    Screen('DrawTexture', w, tex);
                    Screen('Flip', w);
                    Screen('Close', tex);
                else
                    warning('flip requires a valid window pointer');
                end
            catch ME
                warning('Cannot parse args to flip().');
                fprintf(2, '%s\n', getReport(ME));
            end
        end

        function mflip(obj, varargin)
            if nargin < 3
                error('Not enough args: mflip(obj, w, keys[, funcs]).');
            end
            w = varargin{1};
            keys = varargin{2};
            bHaveFuncs = nargin>3;  % nargin counts obj arg regardless of how call is made

            screenRect=Screen('Rect', w);

            % warn if not uniform
            if ~obj.IsUniform
                warning('Images in this imageset are not uniform size');
            end

            % divvy up into however many pieces are needed. Note - the
            % returned rects are in rows!
            divviedRects = ArrangeRects(length(keys), obj.UniformOrFirstRect, screenRect);

            % Find the center of each rect, thenclear center rect on that point
            % for the image itself. Use columnar-rects for RectCenter
            [ctrX, ctrY] = RectCenter(divviedRects');
            textureRects = CenterRectOnPoint(obj.UniformOrFirstRect, ctrX', ctrY');
            if bHaveFuncs
                textures = cellfun(@(k,f) obj.texture(w,k,f), keys, varargin{3});
            else
                textures = cellfun(@(k) obj.texture(w,k), keys);
            end
            Screen('FillRect', w, obj.Bkgd);
            Screen('DrawTextures', w, textures, [], textureRects');
            Screen('Flip', w);
            Screen('Close', textures);
        end


        function fname = filename(obj, k)
            % keys expected folder,file
            key = obj.parse_key(k);
            fname = obj.Images(key).fname;
        end

        function image = get_image(obj, k)
            key=obj.parse_key(k);
            if isempty(obj.Images(key).image)
                % read the image and replace the struct 
                fname = obj.Images(key).fname;
                fprintf('Lazy-loading image %s from %s\n', key, fname);
                %obj.Images(key).image = obj.read_image_file(obj.Images(key).fname, key);
                obj.Images(key) = struct('fname', fname, 'image', obj.read_image_file(fname, key));
            end
            image = obj.Images(key).image;
        end

        function tf = is_key(obj, k)
            if ischar(k)
                tf = obj.Images.isKey(k);
            elseif iscellstr(k)
                tf = cellfun(@(x) obj.Images.isKey(x), k);
            else 
                error('is_key requires string or cellstr');
            end
        end

        function keys = keys(obj, regex)
            arguments
                obj (1,1) imageset
                regex {mustBeText} = ''
            end
            if isempty(regex)
                keys = obj.Images.keys();
            else
                allkeys = obj.Images.keys();
                istart = regexp(allkeys, regex);
                keyind = cellfun(@(x) ~isempty(x), istart);
                keys = allkeys(keyind);
            end
        end
    end

    methods (Static)
        function key = make_key(folder_key, file_key)
            if isempty(folder_key)
                key = file_key;
            elseif strcmp(folder_key,'*')
                key = 'BKGD';
            else
                key = strcat(folder_key, '/', file_key);
            end
        end

        function [keys] = make_keys(folder_keys, file_keys)
            if ~iscell(folder_keys) || ~iscell(file_keys)
                me = MException('imageset:bad_input', 'Both args must be cell arrays.');
                throw(me);
            end
            keys = strcat(folder_keys, '/', file_keys);

            % corrections for blank folder keys
            blanks = matches(folder_keys, '');
            if any(blanks)
                keys(blanks) = file_keys(blanks);
            end

            % corrections for bkgd
            bkgds = matches(folder_keys, '*');
            if any(bkgds)
                keys(bkgds) = {'BKGD'};
            end
        end

        function [folder_key, file_key] = split_key(key)
            folder_key='';
            if contains(key, '/')
                k = split(key, '/');
                folder_key = k{1};
                file_key = k{2};
            else
                file_key = key;
            end
        end

        function J = contrast(I, c)
            J = im2uint8((im2double(I)-0.5)*c + 0.5);
        end
            
    end
    
    methods (Access = private)
    
        function key = parse_key(obj, k)
            if ~ischar(k) && ~isstring(k)
                exception = MException('imageset:parse_key:wrongType', 'Wrong type, expecting char or string');
                throw(exception);
            elseif ~obj.Images.isKey(k)
                exception = MException('imageset:parse_key:NotAKey', ['Not a key: ' k]);
                throw(exception);
            else
                key = k;
            end
        end

        function [isUniformSize, rectUniformOrFirst] = check_sizes(obj)
            isUniformSize = true;
            rectUniformOrFirst = [];
            haveFirstSize = false;
            allKeys = obj.Images.keys;
            for i=1:length(allKeys)
                r = obj.rect(allKeys{i});
                if ~isequal(r, rectUniformOrFirst)
                    if haveFirstSize
                        isUniformSize = false;  % sorry, dude
                    else
                        rectUniformOrFirst = r;
                        haveFirstSize = true;
                    end
                end
            end
        end


        function [isBalanced, balancedFileKeys, missingKeys] = check_key_balance(obj)
            %check_key_balance Tests whether each file key has an image for
            %each folder key. Returns unique filel keys found. If any 
            %unbalanced keys are found, they are returned in nonUniqueKeys.
            
            allKeys = obj.Images.keys;
            allFileKeys = cell(length(allKeys),1);
            for i=1:length(allKeys)
                [~,fil] = imageset.split_key(allKeys{i});
                allFileKeys{i} = fil;
            end
            uniqueFileKeys = unique(allFileKeys);
            
            % now check each folder for each key. Each row in
            % obj.Subfolders refers to a subfolder (and a folder key)
            m = cell(length(uniqueFileKeys) * size(obj.Subfolders, 1), 1);
            mcount = 0;
            b = cell(length(uniqueFileKeys), 1);            
            bcount = 0;

            for ikey=1:length(uniqueFileKeys)
                kfail = false;
                for itype = 1:size(obj.Subfolders, 1)
                    k=imageset.make_key(obj.Subfolders{itype, 1}, uniqueFileKeys{ikey});
                    if ~obj.Images.isKey(k)
                        mcount = mcount + 1;
                        m{mcount} = k;
                        kfail = true; 
                    end
                end
                
                % if kfail is false, then each subfolder had an image 
                % with that basename. 
                if ~kfail 
                    bcount = bcount + 1;
                    b{bcount} = uniqueFileKeys{ikey};
                end
            end
            balancedFileKeys = b(1:bcount);
            missingKeys = m(i:mcount);
            isBalanced = isempty(missingKeys);
        end


        function image = read_image_file(obj, filename, key)
        %read_image_file Read image file. Apply OnLoadFunc (if defined),
        %and also add text if ShowName is true.
            if isempty(obj.OnLoadFunc)
                image = imread(filename);
            else
                image = obj.OnLoadFunc(imread(filename));
            end

            if obj.ShowName
                image = insertText(image, size(image, [1,2])/2, key,FontSize=floor(size(image,1)/6),AnchorPoint="center");
            end
        end

        function add_image(obj, filename, key)
            if obj.Images.isKey(key)
                exception = MException('imageset:add_image:duplicateKey', sprintf('Adding a duplicate key %s with filename %s\n', key, filename));
                throw(exception);
            end
            try
                if ~obj.Lazy
                    obj.Images(key) = struct('fname', filename, 'image', obj.read_image_file(filename, key));
                else
                    % when Lazy is set, do not load the image.
                    obj.Images(key) = struct('fname', filename, 'image', []);
                end
            catch ME
                fprintf('Error reading file %s\n', filename);
                rethrow(ME);
            end
        end
        
        function count = add_images_from_folder(obj, folder, folder_key)
            % look at all files in the folder
            if ~isfolder(folder)
                exception = MException('imageset:add_images_from_folder:NotAFolder', sprintf('This is not a folder: %s\n', folder));
                throw(exception);
            end
            d=dir(folder);
            count = 0;
            for i=1:height(d)
                fname = fullfile(d(i).folder, d(i).name);
                if isfile(fname)
                    [~,base,ext] = fileparts(fname);

                    % Check file extension
                    if any(strcmpi(ext, obj.Extensions))
                    
                        key = imageset.make_key(folder_key, base);                        
                        obj.add_image(fname, key);
                        count = count + 1;

                    else
                        fprintf('imageset - skipping file %s\n', fname);
                    end
                end
            end
        end
    end
        
end


function mustBeProperSubfolderCell(x)
    if ~iscell(x)
        error('imageset:BadSubfolders', 'Subfolders arg must be Mx2 cellstr');
    elseif ~isempty(x) && size(x, 2) == 2
        error('imageset:BadSubfolders', 'Subfolders arg must be Mx2 cellstr');
    end
end

