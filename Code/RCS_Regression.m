function[im_new,R_2,B,M,ptsObj2,ptsScene2,t_score]=RCS_Regression(ptsScene1,ptsObj1,imgObj,imgScene)
%
% [im_new,R_2,B,M,ptsObj2,ptsScene2,t_score]=RCS_Regression(ptsScene1,ptsObj1,imgObj,imgScene);
%
% Calculate the normalized subject images through Ordinary linear regression based on the RCS 
%
% Input
%   ptsScene1       - inliers positions in the reference image;
%    ptsObj1         - inliers positions in the subject image;
%    imgObj - subject image 
%    imgScene - reference images
%
% Output
%   im_new - Normalized subject image
%    R_2 - R-Squared
%     B - intercept 
%     M - slop
%    ptsObj2 - RSC positions in the Reference image  
%    ptsScene2 - RSC positions in the subject image 
%    t_score - cross-correlation values for inliers

% (c) Copyright 2021
% Armin Moghimi
% moghimi.armin@gmail.com,
% 24 Jan 2021

[m1 m2 m3]=size(imgObj);   
for k=1:m3
for i=1:max(size(ptsObj1))
S_DN(i,k)=imgObj(ptsObj1(i,2),ptsObj1(i,1),k);
end
end
%%
for k=1:m3
for i=1:max(size(ptsScene1))
R_DN(i,k)=imgScene(ptsScene1(i,2),ptsScene1(i,1),k);
end
end

for i=1:size(R_DN,2)
Mask(:,i)=R_DN(:,i)>0;
end
Mask_kol1=sum(Mask,2)==size(R_DN,2);
for i=1:size(S_DN,2)
Mask(:,i)=S_DN(:,i)>0;
end
Mask_kol2=sum(Mask,2)==size(R_DN,2);
Mask_kol=Mask_kol2.*Mask_kol1;
R_DN1=Mask_kol.*R_DN;
S_DN1=Mask_kol.*S_DN;
clear R_DN  S_DN
for i=1:size(R_DN1,2)
R_DN(:,i)=(R_DN1(:,i));
S_DN(:,i)=(S_DN1(:,i));
end
%% RCS selection based on the Pearson's Correlation Coefficient 
for i=1:size(R_DN,1)
    t_score(i,1)=corr2(R_DN(i,:),S_DN(i,:));
end
t_score(isnan(t_score))=0;
R_DN=(t_score>0.5).*R_DN;
S_DN=(t_score>0.5).*S_DN;

mACK=t_score>=0.5;
ptsScene1=mACK.*ptsScene1;
ptsScene2(:,1)=nonzeros(ptsScene1(:,1));
ptsScene2(:,2)=nonzeros(ptsScene1(:,2));
ptsObj1=mACK.*ptsObj1;
ptsObj2(:,1)=nonzeros(ptsObj1(:,1));
ptsObj2(:,2)=nonzeros(ptsObj1(:,2));

%% Linear Regression based on the RCS
for i=1:m3
mdl =fitlm((nonzeros(S_DN(:,i))),(nonzeros(R_DN(:,i))),'interactions','RobustOpts','off');
brob=table2array(mdl.Coefficients(:,1));
R_2(:,i)=mdl.Rsquared.Ordinary;
M(1,i)=brob(2);B(1,i)=brob(1);
im_new(:,:,i)=brob(1)+brob(2)*double(imgObj(:,:,i));
end