
clear all; close all;
im=imread('shapes23.png');
if size(im,3)>1
    im=rgb2gray(im);
end
im=double(im);

%algorithm parameters
sigma=1;
thresh=1000; 
radius=4;
alpha=0.04;

% Use sobel operators
% Derivative masks

%students fill this code
dx= [-1 -1 -1; 0 0 0; 1 1 1];  
dy= dx';

% Calculate the derivatives
% use correlation with dx and dy
Ix= imfilter(im,dx,'same'); 
Iy= imfilter(im,dy,'same');

% Create Gaussian filter of size 6*sigma (+/- 3sigma) 
% and of minimum size 1x1.
g= fspecial('gaussian', round(6*sigma), sigma);

% Generate the Smoothed image derivatives Ix^2,Iy^2, and Ixy
Ix2 = conv2(Ix.^2, g); 
Iy2 = conv2(Iy.^2, g);
Ixy = conv2(Ix.*Iy, g);
   
%Calculate cornerness measure R
% try Harris and Szelski methods
R = (Ix2 .* Iy2 - Ixy.^2) - alpha * (Ix2 + Iy2).^2;   % Harris measure
R(isnan(R)) = 0; % replace NaN with 0 (NaN from division by 0 above)

% Threshold R
corners = R > thresh; %pixels with a higher response than 
% the threshold are to be corners
%Lmax = imregionalmax(R);
	
% find all corners above a certain thresh
%[r,c] = find(Lmax);                  % Find row,col coords.

%Part 1.2 in the assignment
%refine the code to here to extract local maxima 
%by performing a grey scale morphological dilation 
%and then finding points in the corner strength image that
% match the dilated image and are also greater than the threshold.

% Threshold R and find local maxima
N = 2 * radius + 1;                 % Size of mask.
Rdilated = imdilate(R, strel('disk',N));  % Grey-scale dilate.
finalCorners = corners & (R == Rdilated); % Find local maxima.

[rFinal, cFinal] = find(finalCorners);

% overlay corners on original image
figure, imagesc(im), axis image, colormap(gray), hold on
	    plot(cFinal - 3, rFinal - 3, 'r*'), title('Corners Detected');
