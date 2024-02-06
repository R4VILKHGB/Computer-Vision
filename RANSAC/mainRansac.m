clear variables
close all

rng(0);     % Reset random number generator

% Define image file names.
fileNames = { 'building2.PNG', 'building3.PNG'};
% run('vlfeat-0.9.21/toolbox/vl_setup');
% run('vlfeat-0.9.21-bin\vlfeat-0.9.21\toolbox\vl_setup')
% Get the first image.
I1c = imread(fileNames{1});

% Get second image.
I2c = imread(fileNames{2});

% Convert to grayscale
if (size(I1c,3)>1)
    I1 = rgb2gray(I1c);
else
    I1 = I1c;
end
if (size(I2c,3)>1)
    I2 = rgb2gray(I2c);
else
    I2 = I2c;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract SIFT features.
% These parameters limit the number of features detected
peak_thresh = 0;    % increase to limit; default is 0
edge_thresh = 10;   % decrease to limit; default is 10

% First image
I1 = single(I1);  % Convert to single precision floating point
figure(1), imshow(I1,[]);

[f1,d1] = vl_sift(I1, ...
    'PeakThresh', peak_thresh, ...
    'edgethresh', edge_thresh );
fprintf('Number of features detected: %d\n', size(f1,2));

% Show all SIFT features detected
h = vl_plotframe(f1) ;
set(h,'color','y','linewidth',1.0) ;


% Second image
I2 = single(I2);
figure(2), imshow(I2,[]);

[f2,d2] = vl_sift(I2, ...
    'PeakThresh', peak_thresh, ...
    'edgethresh', edge_thresh );
fprintf('Number of features detected: %d\n', size(f2,2));

% Show all SIFT features detected
h   = vl_plotframe(f2) ;
set(h,'color','y','linewidth',1.0) ;

%pause

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Match features
% The index of the original match and the closest descriptor is stored in
% each column of matches and the distance between the pair is stored in
% scores.

% Define threshold for matching. Descriptor D1 is matched to a descriptor
% D2 only if the distance d(D1,D2) multiplied by THRESH is not greater than
% the distance of D1 to all other descriptors
thresh = 1.5;   % default = 1.5; increase to limit matches
[matches, scores] = vl_ubcmatch(d1, d2, thresh);
fprintf('Number of matching features: %d\n', size(matches,2));

indices1 = matches(1,:);        % Get matching features
f1match = f1(:,indices1);
d1match = d1(:,indices1);

indices2 = matches(2,:);
f2match = f2(:,indices2);
d2match = d2(:,indices2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Show matches
figure(3), imshow([I1,I2],[]);
o = size(I1,2) ;
line([f1match(1,:);f2match(1,:)+o], ...
    [f1match(2,:);f2match(2,:)]) ;
for i=1:size(f1match,2)
    x = f1match(1,i);
    y = f1match(2,i);
    text(x,y,sprintf('%d',i), 'Color', 'r');
end
for i=1:size(f2match,2)
    x = f2match(1,i);
    y = f2match(2,i);
    text(x+o,y,sprintf('%d',i), 'Color', 'r');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N = size(f1match,2);    % Number of corresponding point pairs

sigma = 1;    % Sigma of errors of points found in lowest scale

% Let's say that we want to get a good sample with this probability.
confidence = 0.99;

% Try to fit a homography from the points in image 1, to the points in
% image 2. Returns:
%   indices:  the indices of the original points, that are inliers
%   rmsErr:  root mean squared error of the inliers (in pixels)
%   tform_1_2:  a "projective2d" object, computed by "fitgeotrans".
% Note: if you want to get the 3x3 homography matrix such that p2 = H*p1,
% do Hom_1_2 = tform_1_2.T'.
[tform_1_2, indices, rmsErr] = homographyRansac( ...
    f1match, ...    % image 1 keypoints, size 4xN
    f2match, ...    % image 2 keypoints, size 4xN
    1000, ...       % don't go above this many iterations
    confidence,  ... % desired confidence level, 0..1
    I1, I2, ...,      % for visualization (use [],[] if not needed)
    sigma ...
    );




