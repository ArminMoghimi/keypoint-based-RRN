function [NTG,RMSE]=score_index(Iref,I)
%
% [NTG,RMSE]=score_index(Iref,I);
%
% Calculate Root Mean squer Error (RMSE) and Normalized Total Gradient (NTG) Relative Radiometric Normalization (RRN) of image pair
%
% Input
%   Iref       - Reference image;
%    I         - Subject image;
%            Iref and I must be samae size with either
%
% Output
%   NTG- 
%   RMSE-

% (c) Copyright 2021
% Armin Moghimi
% moghimi.armin@gmail.com,
% 24 Jan 2021

for i=1:size(I,3)
[Gx,Gy] = imgradientxy(I(:,:,i)-Iref(:,:,i));
matL1x = norm(Gx(:),1);
matL1y = norm(Gy(:),1);
[Gxx_I,Gyy_I] = imgradientxy(I(:,:,i));
matL1xx = norm(Gxx_I(:),1);
matL1yy = norm(Gyy_I(:),1);
[Gxx_Iref,Gyy_Iref] = imgradientxy(Iref(:,:,i));
matL1xxx = norm(Gxx_Iref(:),1);
matL1yyy = norm(Gyy_Iref(:),1);
NTG(1,i)=(matL1x+matL1y)/((matL1xx+matL1xxx)+(matL1yyy+matL1yyy));
V1=nonzeros(I(:,:,i));
V2=nonzeros(Iref(:,:,i));
RMSE(1,i)=RMSE_vec(V1,V2);
end

function [RMSE]=RMSE_vec(V1,V2)
RMSE = sqrt(mean((V1-V2).^2));
end
end
