function [ptsObj1,ptsScene1]=SiftDetector(imgObj,imgScene)

% [ptsObj1,ptsScene1]=SiftDetector(imgObj,imgScene);
% Input
%   imgObj       - Subject image
%   imgScene     - Reference image
% Output
%   ptsObj1     - the matches positions in the subject image 
%   ptsScene1   - the matches positions in the reference image

%This code is writted based on the "Vlfeat" and "OpenCV-3.4.1" as open source libraries  

% (c) Copyright 2021
% The VLFeat open source library implements popular computer vision algorithms 
% specializing in image understanding and local features extraction and matching. 
% Algorithms include Fisher Vector, VLAD, SIFT, MSER, k-means, hierarchical k-means, 
% agglomerative information bottleneck, SLIC superpixels, quick shift superpixels, 
% large scale SVM training, and many others. It is written in C for efficiency and compatibility, 
% with interfaces in MATLAB for ease of use, and detailed documentation throughout. 
% It supports Windows, Mac OS X, and Linux. The latest version of VLFeat is 0.9.21.
% "Vlfeat" is available at https://www.vlfeat.org/
% Author = A. Vedaldi and B. Fulkerson,
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the "OpenCV-3.4.1" is available at https://opencv.org/releases/
% 24 Jan 2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% feature extraction and matching based on the SIFT
[fa, da] = vl_sift(single(imgObj),'EdgeThresh',9,'PeakThresh',1);
[fb, db] = vl_sift(single(imgScene),'EdgeThresh',9,'PeakThresh',1);
[matches, scores] = vl_ubcmatch(da,db,1.5);
x1=fa(1,matches(1,:));
y1=fa(2,matches(1,:));
x2=fb(1,matches(2,:));
y2=fb(2,matches(2,:));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Ransac for outlier removal
ptsObj1=[x1;y1];
ptsScene1=[x2;y2];
a=ptsObj1';b=ptsScene1';
if size(a,1)>=4
[H,inliers] = cv.findHomography(a,b,'Method','Ransac');
if isempty(H)==1
 ptsScene1=b;
ptsObj1=a;   
else
inliers = logical(inliers);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 ptsObj=a;
 ptsScene=b;
 clear ptsObj1 ptsScene1
for i=1:min(size(ptsObj))
 ptsObj1(:,1)=nonzeros(ptsObj(:,1).*inliers);
 ptsObj1(:,2)=nonzeros(ptsObj(:,2).*inliers); 
end
for i=1:min(size(ptsScene))
 ptsScene1(:,1)=nonzeros(ptsScene(:,1).*inliers);
 ptsScene1(:,2)=nonzeros(ptsScene(:,2).*inliers); 
end
end
else
ptsScene1=b;
ptsObj1=a;
end