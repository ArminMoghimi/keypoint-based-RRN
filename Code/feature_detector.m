function [ptsObj1,ptsScene1]=feature_detector(imgObj,imgScene,OPTS_FEATURE)
%% [ptsObj1,ptsScene1]=feature_detector(imgObj,imgScene,OPTS_FEATURE)%%
% Input
%   imgObj       - Subject image
%   imgScene     - Reference image
%   OPTS_FEATURE - feature detector type
% Output
%   ptsObj1     - the matches positions in the subject image 
%   ptsScene1   - the matches positions in the reference image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The KAZE, AKAZE, ORB and BRISK based on the "OpenCV-3.4.1".
% The "OpenCV-3.4.1" is available at https://opencv.org/releases/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OPTS_FLANN = true;       % matcher: FLANN or Brute Force
OPTS_KNN_MATCH = false;  % matcher method: match or knnMatch (k=2)
%% Step 1: Detect the keypoints and extract descriptors using feature detector-descriptors used
switch upper(OPTS_FEATURE)
    case 'ORB'
        detector = cv.ORB('MaxFeatures',18000,'FastThreshold',20);
    case 'BRISK'
        detector = cv.BRISK('Threshold',37);
    case 'AKAZE'
        detector = cv.AKAZE('Threshold',1e-05);
    case 'KAZE'
        detector = cv.KAZE('Threshold',2.922448979591837e-04);
    otherwise
        error('unrecognized feature: %s', OPTS_FEATURE)
end
display(detector)
%%
[keyObj,featObj] = detector.detectAndCompute(imgObj);
[keyScene,featScene] = detector.detectAndCompute(imgScene);
fprintf('object: %d keypoints\n', numel(keyObj));
fprintf('scene: %d keypoints\n', numel(keyScene));
% whos featObj featScene
% indexPairs = matchFeatures(featScene,featObj,'MatchThreshold',100,'Unique', true);

%% Step 2: Matching descriptor vectors using FLANN matcher
if OPTS_FLANN
    if ~isempty(strfind(detector.defaultNorm(), 'Hamming'))
        opts = {'LSH', 'TableNumber',6, 'KeySize',12, 'MultiProbeLevel',1};
    else
        opts = {'KDTree', 'Trees',5};
    end
    matcher = cv.DescriptorMatcher('FlannBasedMatcher', 'Index',opts);
else
    matcher = cv.DescriptorMatcher('BFMatcher', ...
        'NormType',detector.defaultNorm());
end

%%
if OPTS_KNN_MATCH
    matches = matcher.knnMatch(featObj, featScene, 2);
else
    matches = matcher.match(featObj, featScene);
end
% Filter matches and keep only "good" ones
if OPTS_KNN_MATCH
    % ratio test
    dists = cellfun(@(m) m(1).distance, matches);
    idx = cellfun(@(m) (numel(m) == 2) && ...
        (m(1).distance < 0.75 * m(2).distance), matches);
    matches = cellfun(@(m) m(1), matches(idx));
else
    % distance less than k*min_dist
    dists = [matches.distance];
    cutoff = 3 * min(dists);
    matches = matches(dists <= cutoff);
    fprintf('Min dist = %f\nMax dist = %f\nCutoff = %f\n', ...
        min(dists), max(dists), cutoff);
end
%%
% Get the keypoints from the good matches
% (Note: indices in C are zero-based while MATLAB are one-based)
ptsObj = cat(1, keyObj([matches.queryIdx]+1).pt);
ptsScene = cat(1, keyScene([matches.trainIdx]+1).pt);
%% Step 3: Compute homography and Ransac
assert(numel(matches) >= 4, 'not enough matches for homography estimation');
[H,inliers] = cv.findHomography(ptsObj, ptsScene, 'Method','Ransac');
assert(~isempty(H), 'homography estimation failed');
inliers = logical(inliers);
%%%%%%
for i=1:min(size(ptsObj))
 ptsObj1(:,1)=nonzeros(ptsObj(:,1).*inliers);
 ptsObj1(:,2)=nonzeros(ptsObj(:,2).*inliers); 
end
for i=1:min(size(ptsScene))
 ptsScene1(:,1)=nonzeros(ptsScene(:,1).*inliers);
 ptsScene1(:,2)=nonzeros(ptsScene(:,2).*inliers); 
end