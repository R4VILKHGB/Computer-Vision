frame1 = imread('other-gray-allframes\other-data-gray\Walking\frame07.png');
frame2 = imread('other-gray-allframes\other-data-gray\Walking\frame14.png');

if size(frame1, 3) > 1
    frame1 = rgb2gray(frame1);
    frame2 = rgb2gray(frame2);
end
num_levels = 5; %number of levels in the Gaussian pyramid
window_size = 6; %local window size (small-> more detailed but noise, large-> robust estimate, loss of accuracy)
sigma = 1.0; %Gaussian smoothing parameter  (small-> no global motion, yes details, large-> yes global/ rapid motion, loss of accuracy/ details)
[u_multires, v_multires] = lucas_kanade_multires(frame1, frame2, num_levels, window_size, sigma);

figure;
imshow(frame1);
hold on;
quiver(u_multires, v_multires, 5, 'color', 'r'); 
hold off;
title('Multi-Resolution Optical Flow');
