function [PwrapFinal,PrefFinal] = sgTestGeoMetricTest(pWrap,pRef,MaxThreshold,MinThreshold)
% [PwrapFinal,PrefFinal,Idremain] = sgTestGeoMetricTest(pWrap,pRef,MaxThreshold,MinThreshold);
% Input
%   pWrap       - Subject image
%   pRef     - Reference image
%   MaxThreshold         - Maximum Shift
%   MinThreshold         - Minimum Shift
% Output
%   PwrapFinal  - the correct matches positions in the subject image 
%   PrefFinal   - the correct matches positions in the reference image

% MATLAB implementation for paper  "Q.  Chen,  S.  Wang,  B.  Wang,  and  M.  Sun,  
% “Automaticregistration  method  for  fusion  of  zy-1-02c  satellite  images,”
% Remote Sensing, vol. 6, no. 1, pp. 157–179, 2014." 
% Created on 24 Jan 2021, @author: Armin Moghimi
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
warning off
if nargin<3
    MaxThreshold = 30;
    MinThreshold = 3;
end
movingPoints = pWrap;
fixedPoints = pRef;
Dt = delaunayTriangulation(movingPoints);
triangu = Dt.ConnectivityList;
Pwrap = Dt.Points;
Pref = [];
l = 1;
ll = 1;
Threshold = MaxThreshold;
all=[];
while Threshold>MinThreshold
    if size(Pwrap,1)>5
        for i=1:size(Pwrap,1)
            [p,q]=find(triangu==i);
            X = triangu(p,:);
            X = X(:);
            for j=1:size(X,1)
                [p1,q1]=find(triangu==X(j,1));
                x = triangu(p1,:);
                X = [X;x(:)];
            end
            
            X = unique(X);
            pointsWrap = Pwrap(X,:);
            for k=1:size(pointsWrap,1)
                [p2,q2] = find(movingPoints(:,1)==pointsWrap(k,1)...
                    &movingPoints(:,2)==pointsWrap(k,2));
                pointsRef(k,:) = fixedPoints(p2(1,1),:);
            end
            [p3,q3] = find(X==i);
            Co1 = pointsWrap(p3,:);
            Co2 = pointsRef(p3,:);
            pointsWrap(p3(1,1),:)=[];
            pointsRef(p3(1,1),:)=[];
                    if size(pointsWrap,1)<3
            pointsWrap=[10 10;20 20;30 30];
            pointsRef=[20 20;40 30;20 50];;
        end
            
            tform = fitgeotrans(pointsWrap,pointsRef,'affine');
            newPos = tform.transformPointsForward(Co1);
            D = sqrt((newPos(1,1)-Co2(1,1))^2+(newPos(1,2)-Co2(1,2))^2);
            if D>Threshold
                all(l,1)=i;
                all(l,2)=D;
                all(l,3:4)=Co1;
                all(l,5:6)=Co2;
                l=l+1;
            end
            X = [];
            pointsRef = [];
            pointsWrap =[];
            
        end
        
        if size(all,1)~=0
            Pwrap(all(:,1),:)=[];
            Threshold = Threshold/1.5;
            all=[];
        else
            Threshold = Threshold/1.5;
        end
        l=1;
        ll=ll+1;
        Dt = delaunayTriangulation(Pwrap);
        triangu = Dt.ConnectivityList;
        Pwrap = Dt.Points;
    else
        Threshold=0;
    end
end

if size(Pwrap,1)~=0
    PwrapFinal = Pwrap;
    for iii=1:size(PwrapFinal,1)
        D2 = pdist2(PwrapFinal(iii,:),pWrap);
        q3 = find(D2==0);
        PrefFinal(iii,:) = pRef(q3(1,1),:);
    end
else
    PwrapFinal =[];
    PrefFinal=[];
end
Idremain =[];
for i=1:size(PwrapFinal,1)
    id = find(pWrap(:,1)==PwrapFinal(i,1) & pWrap(:,2)==PwrapFinal(i,2));
    Idremain = [Idremain;id];
end
    
end



