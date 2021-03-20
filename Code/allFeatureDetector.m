function [ptsObj1,ptsScene1]=allFeatureDetector(imgObj,imgScene,indx) 
switch upper(indx)
    case 1
        [ptsObj1,ptsScene1]=SurfDetector(imgObj,imgScene,150);
    case 2
        [ptsObj1,ptsScene1]=SiftDetector(imgObj,imgScene);
    case 3
        [ptsObj1,ptsScene1]=feature_detector(imgObj,imgScene,'KAZE');
    case 4
        [ptsObj1,ptsScene1]=feature_detector(imgObj,imgScene,'AKAZE');
    case 5
        [ptsObj1,ptsScene1]=feature_detector(imgObj,imgScene,'ORB');
    case 6
        [ptsObj1,ptsScene1]=feature_detector(imgObj,imgScene,'BRISK');
    otherwise
        error('unrecognized feature: %s', OPTS_FEATURE)
end
end 