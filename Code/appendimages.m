function  []=appendimages(image1, image2,correspond1,correspond2)
% [fhand,test]=appendimages(image1, image2,correspond1,correspond2);
%
% imshow matching results
%
% Input
%   image1      - Subject image
%   image2      - Reference image;
%   correspond1 - matches in the refernce image;
%   correspond2 - matches in the subject image;
%           
% Output
%   fhand- 
%   test-

% (c) Copyright 2021
% Armin Moghimi
% moghimi.armin@gmail.com,
% 24 Jan 2021

rows1 = size(image1,1);
rows2 = size(image2,1);

col1=size(image1,2);
col2=size(image2,2);

if (rows1 < rows2)
     image1(rows1+1:rows2,1:col1,:) = 0;
elseif(rows1 >rows2)
     image2(rows2+1:rows1,1:col2,:) = 0;
end

temp1=size(image1,3);
temp2=size(image2,3);
if(temp1==1 && temp2==3)
    image2=rgb2gray(image2);
elseif(temp1==3 && temp2==1)
    image1=rgb2gray(image1);
end
im3 = [image1 image2];
% fhand=figure;
% imshow(im3,'border','tight','initialmagnification','fit');
% imshow(im3,[])
% title(['left is the reference --- the number of pairs ',num2str(size(correspond1,1)),' --- right is the To be registered']);
% set(gcf,'Position',[0,0,size(im3,2) size(im3,1)]);
% axis normal;
colormap = {'b','r','m','y','g','c'};
figure,imshow(im3,[])
title(['left is the Subject --- the number of pairs ',num2str(size(correspond1,1)),' --- right is the reference']);

% title('Good Matches & Object detection')
hold on;
cols1 = size(image1,2);
for i = 1: size(correspond1,1)
    num=1;
    if(num==1)%red
%         line([correspond1(i,1) correspond2(i,1)+cols1], ...
%              [correspond1(i,2) correspond2(i,2)], 'Color', 'g','LineWidth',1);
              plot([correspond1(i,1) correspond2(i,1)+cols1], ...
             [correspond1(i,2) correspond2(i,2)],colormap{mod(i,6)+1},'Marker','o','Markersize',2.5,'LineWidth',1);
% title('Good Matches & Object detection')
%     plot([correspond1(i,1),correspond1(i,2)],[correspond2(i,1)+cols1,correspond2(i,2)],colormap{mod(i,6)+1});
%          plot(correspond1(i,1),correspond1(i,2),colormap{mod(i,6)+1})
%                   plot(correspond2(i,1)+cols1,correspond2(i,2),colormap{mod(i,6)+1})  
    elseif(num==2)%green
        line([correspond1(i,1) correspond2(i,1)+cols1], ...
             [correspond1(i,2) correspond2(i,2)], 'Color', 'g','LineWidth',1); 
    elseif(num==3)%blue
        line([correspond1(i,1) correspond2(i,1)+cols1], ...
             [correspond1(i,2) correspond2(i,2)], 'Color', 'b','LineWidth',1); 
    end
end

% test = getimage(h);
% line([p1(1,1),p1(2,1)],[p1(1,2),p1(2,2)], 'Color', 'g','LineWidth',3); 
% line([p1(2,1),p1(3,1)],[p1(2,2),p1(3,2)], 'Color', 'g','LineWidth',3); 
% line([p1(3,1),p1(4,1)],[p1(3,2),p1(4,2)], 'Color', 'g','LineWidth',3); 
% line([p1(4,1),p1(1,1)],[p1(4,2),p1(1,2)], 'Color', 'g','LineWidth',3); 
% hold off;
end






