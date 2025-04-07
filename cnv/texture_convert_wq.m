clear
close all
addpath('D:\Wenqing\Code\matlabPyrTools-master\MEX')
addpath('D:\Wenqing\Code\textureSynth-master')
addpath('D:\Wenqing\Code\matlabPyrTools-master')
addpath('D:\Wenqing\Code\matlabPyrTools-master\MEX')
mex -O D:\Wenqing\Code\matlabPyrTools-master\MEX\pointOp.c

% Set the original folder and destination folder
%OriFolder='D:\Wenqing\ImgBank\FreeView\Plant\naturalTMatch\';
OriFolder='D:\Wenqing\ImgBank\04012025\naturalTMatch\';
%DestFolder='D:\Wenqing\ImgBank\FreeView\Plant\texturegreyMatch\';
DestFolder='D:\Wenqing\ImgBank\04012025\naturalTMatchText\';
DestFolder2='D:\Wenqing\ImgBank\04012025\naturalTMatchEq\';
mkdir(DestFolder)
mkdir(DestFolder2)

cd (OriFolder)
noise_image=true;
random_seed=1;
des_size=[256,256];
% Run through the image, note the sequence of reading files may not be
% the same with the image number, therefore this is for reference of total
% number of image files
files=dir('*.bmp');

% Loop: read the original image by image number,convert the bmp to pgm or
% similar format, resize the image to 320X320 pixels so it fits the setting
% in the paper, the other parameters follows the paper setting too. After
% the iterations and synthesis, resize the final result image to 256X256 to
% fit the experiment, write the final result into the destination folder. 
for i=1:length(files)
    try
    [X,~,~]=imread([OriFolder,files(i).name]);
    
    %X_grey=rgb2gray(X);
    X_eq=histeq(X);
    imwrite( X_eq,[DestFolder2,files(i).name])
    im0 = double(squeeze(X_eq(:,:,1)));
    im0=imresize(im0,des_size);
    
      im1 = double(squeeze(X_eq(:,:,2)));
    im1=imresize(im1,des_size);

      im2 = double(squeeze(X_eq(:,:,3)));
    im2=imresize(im2,des_size);
    % im0 = pgmRead('myImage1.pgm');	% im0 is a double float matrix!

    Nsc = 4; % Number of scales
    Nor = 4; % Number of orientations
    Na = 7;  % Spatial neighborhood is Na x Na coefficients
    % It must be an odd number!

    params = textureAnalysis(im0, Nsc, Nor, Na);

    Niter = 25;	% Number of iterations of synthesis loop
    Nsx = size(im0,1);	% Size of synthetic image is Nsy x Nsx
    Nsy = size(im0,2);	% WARNING: Both dimensions must be multiple of 2^(Nsc+2)

    res = textureSynthesis(params, [Nsy Nsx], Niter,[],[],random_seed);
    ImageNatural=uint8(res);
    im_mx0=ImageNatural;
    im_mx0=imresize(im_mx0,des_size);
   

    params1 = textureAnalysis(im1, Nsc, Nor, Na);

     Nsx1 = size(im1,1);	% Size of synthetic image is Nsy x Nsx
    Nsy1 = size(im1,2);	% WARNING: Both dimensions must be multiple of 2^(Nsc+2)

    res1 = textureSynthesis(params1, [Nsy1 Nsx1], Niter,[],[],random_seed);
    ImageNatural1=uint8(res1);
    im_mx1=ImageNatural1;
    im_mx1=imresize(im_mx1,des_size);

    params2 = textureAnalysis(im2, Nsc, Nor, Na);

     Nsx2 = size(im2,1);	% Size of synthetic image is Nsy x Nsx
    Nsy2 = size(im2,2);	% WARNING: Both dimensions must be multiple of 2^(Nsc+2)

    res2 = textureSynthesis(params2, [Nsy2 Nsx2], Niter,[],[],random_seed);
    ImageNatural2=uint8(res2);
    im_mx2=ImageNatural2;
    im_mx2=imresize(im_mx2,des_size);
   imwrite(cat(3,im_mx0,im_mx1,im_mx2),[DestFolder,files(i).name]);
%      imwrite(im_mx0,[DestFolder,files(i).name]);

%     close all
%     figure(1)
%     showIm(im0, 'auto', 1, 'Original texture');
%     figure(2)
%     showIm(res, 'auto', 1, 'Synthesized texture');
    catch
        fprintf('Error %s occurred:', files(i).name);
        continue
    end
end
%%
% Loop: read the original image and texture image to see if the mean lumin
% is close enough. 
for i=1:length(files)
    [X,~,~]=imread([OriFolder,files(i).name]);
    [Y,~,~]=imread([DestFolder,files(i).name]);
  % imwrite( imresize(Y,[256 256]),[DestFolder,files(i).name]);
    lum_ori(i)=mean(X(:));
    lum_text(i)=mean(Y(:));
end
% %%
% % Specify the folder path containing the images
% folder = 'D:\Wenqing\images_selected';
% 
% % Get a list of image files in the folder
% fileList = dir(fullfile(folder, 'result*.bmp'));
% 
% % Loop through the files and rename them
% for i = 1:numel(fileList)
%     % Get the current file name
%     currentFileName = fileList(i).name;
%     
%     % Construct the new file name
%     newFileName = strrep(currentFileName, 'result', 'Image');
%     
%     % Rename the file
%     movefile(fullfile(folder, currentFileName), fullfile(folder, newFileName));
% end

% Specify the directory containing the JPG files
% jpgDirectory = 'D:\Wenqing\Foraging\SLMV2\Natural'; % Replace with the directory path
% 
% % List all the JPG files in the directory
% jpgFiles = dir(fullfile(jpgDirectory, '*.jpg'));
% 
% % Loop through each JPG file
% for i = 1:numel(jpgFiles)
%     % Read the current JPG file
%     jpgFileName = fullfile(jpgDirectory, jpgFiles(i).name);
%     image = imread(jpgFileName);
%     
%     % Create the BMP file name
%     [~, name, ~] = fileparts(jpgFiles(i).name);
%     bmpFileName = fullfile(jpgDirectory, [name, '.bmp']);
%     
%     % Save the image as a BMP file
%     imwrite(image, bmpFileName, 'bmp');
% end
%%


%%
OriFolder='D:\Wenqing\ImgBank\04012025\naturalTMatch\';
%DestFolder='D:\Wenqing\ImgBank\FreeView\Plant\texturegreyMatch\';
DestFolder='D:\Wenqing\ImgBank\04012025\naturalTMatchText\';
cd (OriFolder)
files1=dir('*.bmp');

for i=1:length(files1)
    [X,~,~]=imread([OriFolder,files1(i).name]);
    [Y,~,~]=imread([DestFolder,files1(i).name]);
    lum_ori(i)=mean(mean(mean(squeeze(X(:,:,:)))));
    lum_text(i)=mean(mean(mean(squeeze(Y(:,:,:)))));
  %  X_eq=histeq(X);
   % imwrite( X_eq,[OriFolder,files(i).name])
   contrast1(i) = double(max(X(:)) - min(X(:)));
   contrast2(i) = double(max(Y(:)) - min(Y(:)));
   variance1(i) = var(double(X(:)));
   variance2(i) = var(double(Y(:)));


end