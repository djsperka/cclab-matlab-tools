function [basenames, mean_imcolorFINAL, mean_imcolortextureFINAL, mean_imbwFINAL, mean_imbwtextureFINAL] = cclabConv(inputFolder, outputFolderRoot, options)
%cclabConv Image processing and conversion for cclab ethological salience
%expt. 
%   All files in the input folder with the 'inputExtension' are assumed
%to be input. Subfolders named 'color', 'color-texture', 'bw', and
%'bw-texture' are created under the 'outputFolderRoot' (no warnings if
%these folders exist, and no warnings if files are overwritten). The
%raw color images are assumed to be 256x256.
%
%Raw color -> histeq -> FINAL color image (saved to 'color' folder)
%FINAL color -> rgb2gray ->FINAL bw image 
%
%For the texture processing, each plane (r,g,b) of the color image is
%separately processed to produce texture for each color plane. The
%color planes are recombined and the resulting image is saved in the
%'color-texture' folder. This texture files is then sent through rgb2gray
%to produce the final bw-texture image. 
%
%FINAL color -> RED   -> textureProcessing -> textureSynthesis -> R-tex
%            -> BLUE  -> textureProcessing -> textureSynthesis -> G-tex
%            -> GREEN -> textureProcessing -> textureSynthesis -> B-tex
%
%FINAL color texture = (R-tex, G-tex, B-tex)
%FINAL bw texture = rgb2gray(FINAL color texture)
%

    arguments
        inputFolder char {mustBeFolder},
        outputFolderRoot char {mustBeFolder},
        options.inputExtension char = 'bmp',
        options.doHisteq {mustBeNumericOrLogical} = 0,
        options.testfile char = ''              % use 'file.ext'
        options.nFiles (1,1) {mustBeNumeric} = 0 % cannot use this and testfile
    end


    % if doHisteq is true, we will process raw image using histeq.
    % if not, deal is a no-op
    if options.doHisteq
        onLoadFunc = @histeq;
    else
        onLoadFunc = @deal;
    end


    % Create subfolders beneath 'outputFolderRoot'.
    % Make a little function to catch warn msgs that happen if dir exists.
    % The cellfun does the trick.

    folders = fullfile(outputFolderRoot, {'color','color-tex','bw','bw-tex'});
    function [status] = mymkdir(x)
        [status, ~, ~] = mkdir(x);
    end
    if ~all(cellfun(@(x) mymkdir(x), folders))
        error('Cannot create folders for output files.');
    end
    
    destSize = [256, 256];
    randomSeed = 9999;
    outputExtension = 'bmp';
    if isempty(options.testfile)
        zfile = fullfile(inputFolder, ['*.', options.inputExtension]);
    else
        zfile = fullfile(inputFolder, options.testfile);
    end        
    inputFiles = dir(zfile);
    nFiles = length(inputFiles);
    fprintf('Found %d files matching %s\n', nFiles, zfile);

    % nFiles
    if options.nFiles && isempty(options.testfile)
        nFiles = min(nFiles, options.nFiles);
        fprintf('Will process %d files\n', nFiles);
    end

    % outputs.
    mean_imcolorFINAL = zeros(nFiles, 1);
    mean_imcolortextureFINAL = zeros(nFiles, 1);
    mean_imbwFINAL = zeros(nFiles, 1);
    mean_imbwtextureFINAL = zeros(nFiles, 1);
    basenames = cell(nFiles, 1);
    
    for i=1:nFiles
        fprintf('%d: %s ', i, inputFiles(i).name);
        filename = fullfile(inputFiles(i).folder, inputFiles(i).name);
        [~, basename, ~] = fileparts(filename);  % basename will be used to form output filename
        outputBasename = [basename, '.', outputExtension];
        basenames{i} = basename;
        
        % Read the COLOR image and do a histeq. This (imEq) is the starting
        % point, and will be the image we use as the 'color' image.
        % The destination size is imposed HERE, so all subsequent
        % operations will result in same size images. 
        fprintf('load...');
        im0 = onLoadFunc(imread(filename));
        imcolorFINAL = imresize(im0, destSize);

        % Convert imEq to bw - this is the FINAL
        fprintf('gen bw...');
        imbwFINAL = rgb2gray(imcolorFINAL);

        % do texture analysis separately for each plane r,g,b, so get a
        % single-plane image using each.
        [imRed, imGreen, imBlue] = imsplit(double(imcolorFINAL));
        
        % Texture analysis parameters
        Nsc = 4; % Number of scales
        Nor = 4; % Number of orientations
        Na = 7;  % Spatial neighborhood is Na x Na coefficients, must be odd

        % get analysis params for each plane
        fprintf('analyze R...');
        paramsRed = textureAnalysis(imRed, Nsc, Nor, Na);
        fprintf('G...');
        paramsGreen = textureAnalysis(imGreen, Nsc, Nor, Na);
        fprintf('B...');
        paramsBlue = textureAnalysis(imBlue, Nsc, Nor, Na);
        
        % Generate each plane's texture
        
        Niter = 25;	% Number of iterations of synthesis loop
        Nsx = destSize(1);	% Size of synthetic image is Nsy x Nsx
        Nsy = destSize(2);	% WARNING: Both dimensions must be multiple of 2^(Nsc+2)

        % generate textures for each plane here, and create a combined
        % image
        fprintf('synthesize R...');
        imRedTexture = uint8(textureSynthesis(paramsRed, [Nsx, Nsy, randomSeed], Niter, [], []));
        fprintf('G...');
        imGreenTexture = uint8(textureSynthesis(paramsGreen, [Nsx, Nsy, randomSeed], Niter, [], []));
        fprintf('B...');
        imBlueTexture = uint8(textureSynthesis(paramsBlue, [Nsx, Nsy, randomSeed], Niter, [], []));
        fprintf('create color texture...');
        imcolortextureFINAL = cat(3, imRedTexture, imGreenTexture, imBlueTexture);

        % make bw texture using the color texture
        fprintf('create bw texture...');
        imbwtextureFINAL = rgb2gray(imcolortextureFINAL);

        % Save color image
        fprintf('saving files...\n');
        imwrite(imcolorFINAL, fullfile(folders{1}, outputBasename));

        % Save colortexture image
        imwrite(imcolortextureFINAL, fullfile(folders{2}, outputBasename));

        % Save bw image
        imwrite(imbwFINAL, fullfile(folders{3}, outputBasename));

        % Save bwtexture image
        imwrite(imbwtextureFINAL, fullfile(folders{4}, outputBasename));

        % MATLAB conversion to rgb uses nearly identical formula to that
        % used for computing luminance. See MATLAB docs for rgb2gray and
        % (referred to in rgb2gray doc):
        % https://www.itu.int/dms_pubrec/itu-r/rec/bt/r-rec-bt.601-7-201103-i!!pdf-e.pdf
        % (section 2.5.1).
        % L = 0.299 * R + 0.587 * G + 0.114 * B
        mean_imcolorFINAL(i) = mean(0.299*imRed(:) + 0.587*imGreen(:) + 0.114*imBlue(:));
        mean_imcolortextureFINAL(i) = mean(0.299*imRedTexture(:) + 0.587*imGreenTexture(:) + 0.114*imBlueTexture(:));
        mean_imbwFINAL(i) = mean(imbwFINAL(:));
        mean_imbwtextureFINAL(i) = mean(imbwtextureFINAL(:));

        fprintf('%d:col    = %s\n', i, fullfile(folders{1}, outputBasename));
        fprintf('%d:coltex = %s\n', i, fullfile(folders{2}, outputBasename));
        fprintf('%d:bw     = %s\n', i, fullfile(folders{3}, outputBasename));
        fprintf('%d:bwtex  = %s\n', i, fullfile(folders{4}, outputBasename));
    end

    figure;
    subplot(2,2,1);
    histogram((mean_imcolorFINAL-mean_imcolortextureFINAL)./mean_imcolorFINAL, [-.05:.01:.05]);
    title('color-colortexture');
    subplot(2,2,2);
    histogram((mean_imcolorFINAL-mean_imbwFINAL)./mean_imcolorFINAL, [-.05:.01:.05]);
    title('color-bw');
    subplot(2,2,3);
    histogram((mean_imbwFINAL-mean_imbwtextureFINAL)./mean_imbwFINAL, [-.05:.01:.05]);
    title('bw-bwtexture');
    subplot(2,2,4);
    histogram((mean_imbwFINAL-mean_imcolortextureFINAL)./mean_imbwFINAL, [-.05:.01:.05]);
    title('bw-colortexture');
end