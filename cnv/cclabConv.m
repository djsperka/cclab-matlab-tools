function [basenames, mean_imcolorFINAL, mean_imcolortextureFINAL, mean_imbwFINAL, mean_imbwtextureFINAL] = cclabConv(inputFolder, outputFolderRoot, inputExtension)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    arguments
        inputFolder char {mustBeFolder},
        outputFolderRoot char {mustBeFolder},
        inputExtension char = 'bmp'
    end


    % Create subfolders beneath 'outputFolderRoot'.
    % Make a little function to catch warn msgs that happen if dir exists.
    % The cellfun does the trick.

    folders = fullfile(outputFolderRoot, {'color','color-texture','bw','bw-texture'});
    function [status] = mymkdir(x)
        [status, ~, ~] = mkdir(x);
    end
    if ~all(cellfun(@(x) mymkdir(x), folders))
        error('Cannot create folders for output files.');
    end
    
    destSize = [256, 256];
    randomSeed = 9999;
    outputExtension = 'bmp';
    zfile = fullfile(inputFolder, ['*.', inputExtension]);
    inputFiles = dir(zfile);
    nFiles = length(inputFiles);
    fprintf('Found %d files matching %s\n', nFiles, zfile);

    % outputs.
    mean_imcolorFINAL = zeros(nFiles, 1);
    mean_imcolortextureFINAL = zeros(nFiles, 1);
    mean_imbwFINAL = zeros(nFiles, 1);
    mean_imbwtextureFINAL = zeros(nFiles, 1);
    basenames = cell(nFiles, 1);
    
    for i=1:nFiles
        fprintf('%d: %s\n', i, inputFiles(i).name);
        filename = fullfile(inputFiles(i).folder, inputFiles(i).name);
        [~, basename, ~] = fileparts(filename);  % basename will be used to form output filename
        outputBasename = [basename, '.', outputExtension];
        basenames{i} = basename;
        
        % Read the COLOR image and do a histeq. This (imEq) is the starting
        % point, and will be the image we use as the 'color' image.
        % The destination size is imposed HERE, so all subsequent
        % operations will result in same size images. 
        im0 = imread(filename);
        imcolorFINAL = imresize(histeq(im0), destSize);

        % Convert imEq to bw - this is the FINAL
        imbwFINAL = rgb2gray(imcolorFINAL);

        % do texture analysis separately for each plane r,g,b, so get a
        % single-plane image using each.
        imRed = double(squeeze(imcolorFINAL(:,:,1)));
        imGreen = double(squeeze(imcolorFINAL(:,:,2)));
        imBlue = double(squeeze(imcolorFINAL(:,:,3)));
        
        % Texture analysis parameters
        Nsc = 4; % Number of scales
        Nor = 4; % Number of orientations
        Na = 7;  % Spatial neighborhood is Na x Na coefficients, must be odd

        % get analysis params for each plane
        paramsRed = textureAnalysis(imRed, Nsc, Nor, Na);
        paramsGreen = textureAnalysis(imGreen, Nsc, Nor, Na);
        paramsBlue = textureAnalysis(imBlue, Nsc, Nor, Na);
        
        % Generate each plane's texture
        
        Niter = 25;	% Number of iterations of synthesis loop
        Nsx = destSize(1);	% Size of synthetic image is Nsy x Nsx
        Nsy = destSize(2);	% WARNING: Both dimensions must be multiple of 2^(Nsc+2)

        % generate textures for each plane here, and create a combined
        % image
        imRedTexture = uint8(textureSynthesis(paramsRed, [Nsx, Nsy, randomSeed], Niter));
        imGreenTexture = uint8(textureSynthesis(paramsGreen, [Nsx, Nsy, randomSeed], Niter));
        imBlueTexture = uint8(textureSynthesis(paramsBlue, [Nsx, Nsy, randomSeed], Niter));
        imcolortextureFINAL = cat(3, imRedTexture, imGreenTexture, imBlueTexture);

        % make bw texture using the color texture
        imbwtextureFINAL = rgb2gray(imcolortextureFINAL);

        % Save color image
        mean_imcolorFINAL(i) = mean(imcolorFINAL(:));
        imwrite(imcolorFINAL, fullfile(folders{1}, outputBasename));

        % Save colortexture image
        mean_imcolortextureFINAL(i) = mean(imcolortextureFINAL(:));
        imwrite(imcolortextureFINAL, fullfile(folders{2}, outputBasename));

        % Save bw image
        mean_imbwFINAL(i) = mean(imbwFINAL(:));
        imwrite(imbwFINAL, fullfile(folders{3}, outputBasename));

        % Save bwtexture image
        mean_imbwtextureFINAL(i) = mean(imbwtextureFINAL(:));
        imwrite(imbwtextureFINAL, fullfile(folders{4}, outputBasename));

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