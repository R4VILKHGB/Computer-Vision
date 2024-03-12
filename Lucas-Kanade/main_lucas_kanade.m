frame1 = imread('other-gray-allframes\other-data-gray\Walking\frame07.png');
frame2 = imread('other-gray-allframes\other-data-gray\Walking\frame14.png');

if size(frame1, 3) > 1 %to grayscale
    frame1 = rgb2gray(frame1);
    frame2 = rgb2gray(frame2);
end
window_size = 5;
num_levels = 3;
[u, v] = lucas_kanade(frame1, frame2, window_size);

figure;
imshow(frame1);
hold on;
quiver(u, v, 5, 'color', 'r');
hold off;
title('Optical Flow');
