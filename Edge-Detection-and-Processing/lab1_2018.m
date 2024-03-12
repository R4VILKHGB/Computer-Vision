clear all
close all
I = imread('test1.jpg');

% Reduce image size; is faster and we don't need full size to find board.
if size(I,2)>640
   I = imresize(I, 640/size(I,2));
end

figure(1), imshow(I), title('original Pic');
% Find the checkerboard. Return the four outer corners as a 4x2 array,
% in the form [ [x1,y1]; [x2,y2]; ... ].
findCheckerBoard(I);
