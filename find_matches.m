function [pos2]=find_matches(I1, pos1, I2)
I1 = rgb2gray(I1);
I2 = rgb2gray(I2);

%returns points, containing information features detected in the 2-D grayscale input image I1&I2.
imagePoints = detectSURFFeatures(I1);
scenePoints = detectSURFFeatures(I2);

%extracted feature descriptors at the interest points in both images.
[imageFeatures, imagePoints] = extractFeatures(I1, imagePoints);
[sceneFeatures, scenePoints] = extractFeatures(I2, scenePoints);

%matching features by descriptors
matchPairs = matchFeatures(imageFeatures, sceneFeatures);

%Retrieve locations of corresponding points for each image.
matchedPoints = imagePoints(matchPairs(:, 1), :);
matchedScenePoints = scenePoints(matchPairs(:, 2), :);

%calculates the transformation relating the matched points, while
%eliminating outliers & localize the object in the scene
[tform, inlierIdx] = estimateGeometricTransform2D(matchedPoints, matchedScenePoints, 'affine', 'Confidence', 50, 'MaxDistance', 5);

%applies the forward transformation of 2-D geometric 
%transformation tform to the input coordinate matrix to generate pos2
pos2=transformPointsForward(tform,pos1);

%Retrieve locations of corresponding points for each image
inlierImagePoints   = matchedPoints(inlierIdx, :);
inlierScenePoints = matchedScenePoints(inlierIdx, :);

figure;
showMatchedFeatures(I1, I2, inlierImagePoints, ...
    inlierScenePoints, 'montage');
title('Matched Points (Inliers Only)');
end