function [ptsObj1,ptsScene1]=SurfDetector(imgObj,imgScene,th)
% [ptsObj1,ptsScene1]=SurfDetector(imgObj,imgScene,th);
% Input
%   imgObj       - Subject image
%   imgScene     - Reference image
%     th         - SURF_MetricThreshold
% Output
%   ptsObj1     - the matches positions in the subject image 
%   ptsScene1   - the matches positions in the reference image

%This SURF is created based on the "MATLAB 2020a (Image Processing Toolbox™)" and inliers is given by "OpenCV-3.4.1" (open source libraries).  

% (c) Copyright 2021
% MATLAB 2020a (Image Processing Toolbox™) provides a comprehensive set of reference-standard algorithms and 
% workflow apps for image processing, analysis, visualization, and algorithm development.
% "Vlfeat" is available at https://www.mathworks.com/products/image.html
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the "OpenCV-3.4.1" is available at https://opencv.org/releases/
% 24 Jan 2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OPTS_FLANN = true;       % matcher: FLANN or Brute Force
OPTS_KNN_MATCH = false;  % matcher method: match or knnMatch (k=2)
detector = cv.KAZE(); %% To do SURF based on the OpenCV function not any things 
ptsOriginal  = detectSURFFeatures(imgScene,'NumOctaves',4,'MetricThreshold',th);
ptsDistorted = detectSURFFeatures(imgObj,'NumOctaves',4,'MetricThreshold',th);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[featScene,  validPtsOriginal]  = extractFeatures(imgScene,  ptsOriginal);
[featObj, validPtsDistorted] = extractFeatures(imgObj, ptsDistorted);
[keyObj]=stracture_matriX_build(ptsDistorted);
[keyScene]=stracture_matriX_build(ptsOriginal);
% fprintf('object: %d keypoints\n', numel(keyObj));
% fprintf('scene: %d keypoints\n', numel(keyScene));
% whos featObj featScene
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
% display(matcher)

%%
if OPTS_KNN_MATCH
    matches = matcher.knnMatch(featObj, featScene, 2);
else
    matches = matcher.match(featObj, featScene);
end
% fprintf('%d matches\n', numel(matches));
%%
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
%     fprintf('Min dist = %f\nMax dist = %f\nCutoff = %f\n', ...
%         min(dists), max(dists), cutoff);
end
% fprintf('%d good matches\n', numel(matches));

%%
% show original and filtered distances
% if ~mexopencv.isOctave()
%     %HACK: HISTOGRAM not implemented in Octave
%     figure
%     hh = histogram(dists); hold on
%     histogram([matches.distance], hh.BinEdges)
%     if OPTS_KNN_MATCH
%         legend({'All', 'Good'})
%     else
%         line([cutoff cutoff] + hh.BinWidth/2, ylim(), 'LineWidth',2, 'Color','r')
%         legend({'All', 'Good', 'cutoff'})
%     end
%     hold off
%     title('Distribution of match distances')
% end

%%
% Get the keypoints from the good matches
% (Note: indices in C are zero-based while MATLAB are one-based)
ptsObj = cat(1, keyObj([matches.queryIdx]+1).pt);
ptsScene = cat(1, keyScene([matches.trainIdx]+1).pt);
% whos ptsObj ptsScene

%% Step 3: Compute homography
assert(numel(matches) >= 4, 'not enough matches for homography estimation');
[H,inliers] = cv.findHomography(ptsObj, ptsScene, 'Method','Ransac');
assert(~isempty(H), 'homography estimation failed');
inliers = logical(inliers);
% display(H)
% fprintf('Num outliers reported by RANSAC = %d\n', nnz(~inliers));

%% Step 4: Localize the object
% get the corners from the first image (the object to be "detected")
% [h,w,~] = size(imgObj);
% corners = [0 0; w 0; w h; 0 h];
% display(corners)

% apply the homography to the corner points of the box
% p = cv.perspectiveTransform(corners, H);
% display(p)

%% Show results

% draw the final good matches
% imgMatches = cv.drawMatches(imgObj, keyObj, imgScene, keyScene, matches, ...
%     'NotDrawSinglePoints',true, 'MatchesMask',inliers);

% draw lines between the transformed corners (the mapped object in the scene)
% p(:,1) = p(:,1) + w;  % shift points for the montage image
% imgMatches = cv.polylines(imgMatches, p, 'Closed',true, ...
%     'Color',[0 255 0], 'Thickness',4, 'LineType','AA');
% figure, imshow(imgMatches)
% title('Good Matches & Object detection')
for i=1:min(size(ptsObj))
 ptsObj1(:,1)=nonzeros(ptsObj(:,1).*inliers);
 ptsObj1(:,2)=nonzeros(ptsObj(:,2).*inliers); 
end
for i=1:min(size(ptsScene))
 ptsScene1(:,1)=nonzeros(ptsScene(:,1).*inliers);
 ptsScene1(:,2)=nonzeros(ptsScene(:,2).*inliers); 
end

function [S]=stracture_matriX_build(K)
field1 = 'pt';
field2 = 'size';
field3 = 'angle';
field4 = 'response';
field5 = 'octave';
field6 = 'class_id';
for i=1:size(K.Location,1)
    value1{i,1} =K.Location(i,:);
end
for i=1:size(K.Location,1)
    value2{i,1} =K.Scale(i,:);
end
for i=1:size(K.Location,1)
    value3{i,1} =K.Orientation(i,:);
end
for i=1:size(K.Location,1)
    value4{i,1} =K.Metric(i,:);
end
for i=1:size(K.Location,1)
    value5{i,1} =K.SignOfLaplacian(i,:);
end
class=ones(size(K.Metric,1),size(K.Metric,2));
for i=1:size(K.Location,1)
    value6{i,1} =class(i,:);
end

S = struct(field1,value1,field2,value2,field3,value3,field4,value4,field5,value5,field6,value6);
end
end






















