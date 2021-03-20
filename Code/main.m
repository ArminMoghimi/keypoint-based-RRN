 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
 % The MATLAB code implements the fully automatic Relative Radiometric Normalization (RNN)           %
 % of unregisterd satellite image pairs. This code and its functions are related to the              % 
 % manuscript entitled "A Comparative Analysis of Feature Point Detection and Matching Methods in    % 
 % Relative Radiometric Normalization". They are presented for evaluation by journal editors         %
 % and peer reviewers.                                                                               % 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
 %% (c) Copyright 2021                                                                               %
 % Armin Moghimi                                                                                     %  
 % moghimi.armin@gmail.com,                                                                          %
 % 24 Jan 2021                                                                                       % 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
clc
clear all
close all
%------------------------------------Set path
fp = mfilename('fullpath');
rootdir = fileparts(fp);
p{1} = fullfile(rootdir,'vlfeat-0.9.21');
p{2} = fullfile(rootdir,'Images');

for i = 1:2
addpath(rootdir,p{i});
end
%%__________Relative normalization
[name,path] = uigetfile('*.tif','Select an Sub. image',...
               'Subject');
imgObj1= ((imread([path,name])));
[name,path] = uigetfile('*.tif','Select an Ref. image',...
               'reference');
imgScene1 =((imread([path,name])));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Mask_no_covrage=imgScene1(:,:,1)>0;
imgScene1=uint8(double(imgScene1(:,:,1:size(imgObj1,3))).*Mask_no_covrage);
%%_____________________________________________
%% Select detector-discriptor method
list={'SURF','SIFT','KAZE','AKAZE','ORB','BRISK'};
[indx,tf] = listdlg('ListString',list,'SelectionMode','single');
tic
%%_____________________________________________
%% step 1: Feature Detection and Matching sterategy
for i=1:size(imgObj1,3)
%% Image Enhancement    
imgObj=imadjust((imgObj1(:,:,i)));
imgScene=imadjust((imgScene1(:,:,i)));
%%_____________________________________________
%% Feature Detection and Matching sterategy based on type of detector-discriptor methods 
[ptsObj1{i,1},ptsScene1{i,1}]=allFeatureDetector(imgObj,imgScene,indx);
%%_____________________________________________
%% find the unique points
[ptsObj1{i,1} com_ref]=unique(round(ptsObj1{i,1}),'rows', 'stable'); 
ptsScene1{i,1}=round(ptsScene1{i,1}(com_ref,:));
%%_____________________________________________
%% When the Matched set is empty, we consider a wrong point (to prevent error in progeram).
if size(ptsScene1{i,1},2)==0
    ptsScene1{i,1}=[10 10];
    ptsObj1{i,1}=[30 30];
end
end
%% combine the matches from spectral bandse 
com_sub=(cell2mat(ptsObj1));
com_ref=(cell2mat(ptsScene1));
%%_____________________________________________
%% find the unique Matches from combained matches 
[ucom_sub idx]=unique(com_sub,'rows', 'stable'); 
ucom_ref=com_ref(idx,:);
%%_____________________________________________
%% Remove Wrong Matches from TIN_based local strategy 
[ucom_sub,ucom_ref] = sgTestGeoMetricTest(double(ucom_sub),double(ucom_ref),30,1);
%%_____________________________________________
%% step 2 & 3:Detecting Radiometric Control Set (RCS), and RRN Model parameter estimation
[Normalized_Image,R_2,B,M,ptsObj2,ptsScene2,t_score]=RCS_Regression(round(ucom_ref),round(ucom_sub),double(imgObj1),double(imgScene1));
%%_____________________________________________
toc 
appendimages(imgObj1(:,:,3),imgScene1(:,:,3),ptsObj2,ptsScene2);
figure,imshow(uint8(imgObj1(:,:,1:3)))
title('Subject Image')
figure,imshow(uint8(imgScene1(:,:,1:3)))
title('Reference Image')
figure,imshow(uint8(Normalized_Image(:,:,1:3)))
title('Normalize Subject Image')
%%_____________________________________________
%% Registeration_for_validation by the NTG and RMSE
tform = fitgeotrans(ucom_sub,ucom_ref,'affine');
Jregistered_Normalized_Image = imwarp(Normalized_Image,tform,'OutputView',imref2d(size(imgScene1)));
Mask1=imgScene1(:,:,1)>0;
Mask=Jregistered_Normalized_Image(:,:,1)>0;
Mask=Mask1.*Mask;
imgScene1=Mask.*(double(imgScene1)+0.025);
Jregistered_Normalized_Image=Mask.*(double(Jregistered_Normalized_Image)+0.025);
[NTG,RMSE]=score_index((imgScene1),(Jregistered_Normalized_Image));
for i=1:size(imgScene1,3)
    resulty(1,2*i-1)=NTG(1,i);
    resulty(1,2*i)=RMSE(1,i);
end
%% validation for only dataset 3 (after cloud detection)
% tform = fitgeotrans(ucom_sub,ucom_ref,'affine');
% Jregistered_Normalized_Image = imwarp(Normalized_Image,tform,'OutputView',imref2d(size(imgScene1)));
% load('Mask_cloud.mat')
% Mask_cloud_r = imwarp(Mask_cloud,tform,'OutputView',imref2d(size(imgScene1)));
% Mask1=imgScene1(:,:,1)>0;
% Mask=Jregistered_Normalized_Image(:,:,1)>0;
% Mask=Mask1.*Mask;
% imgScene1=Mask.*(double(imgScene1)+0.025).*imcomplement(Mask_cloud_r);
% Jregistered_Normalized_Image=Mask.*(double(Jregistered_Normalized_Image)+0.025).*imcomplement(Mask_cloud_r);
% [NTG,RMSE]=score_index((imgScene1),(Jregistered_Normalized_Image));
%%_____________________________________________
%% Cross-Correlation (CC) ranges for inliers
corr_range=[max(size(nonzeros(t_score<0.5))),max(size(nonzeros((t_score>=0.5).*(t_score<0.75)))), max(size(nonzeros((t_score>=0.75).*(t_score<0.90)))),max(size(nonzeros(t_score>=0.9)))];
