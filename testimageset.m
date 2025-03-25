% Create imageset from a folder full of images. 
% 
% dan@bucky:~/work/cclab/cclab-images/test$ ls *.png
% B-0.png  B-2.png  B-4.png  B-6.png  B-8.png  G-0.png  G-2.png  G-4.png  G-6.png  G-8.png  R-0.png  R-2.png  R-4.png  R-6.png  R-8.png
% B-1.png  B-3.png  B-5.png  B-7.png  B-9.png  G-1.png  G-3.png  G-5.png  G-7.png  G-9.png  R-1.png  R-3.png  R-5.png  R-7.png  R-9.png
%
% There are 30 png images in this folder. To create an imageset using these
% images:
img=imageset('/home/dan/work/cclab/cclab-images/test');
%
% Create a window to view the images
[w,wr,mywr]=makeWindow([800,600],0,'center','right');

% Show a sample image from the directory. Use the base filename as file
% key:
img.flip(w,'B-1');