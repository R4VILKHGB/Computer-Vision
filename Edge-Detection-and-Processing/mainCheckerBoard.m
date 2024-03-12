%mainScript for Image:

%Load image
inputImage= imread('test1.JPG');
if size(inputImage,2)>640 %checks if the width of the inputImage is greater than 640 pixels
   inputImage = imresize(inputImage, 640/size(inputImage,2));
end
%if width> 640 pixels, resizes image to have a width of 640 pixels, while maintaining the original aspect ratio

figure(1), imshow(inputImage), title('Original Image');
%Call the checkerboard detection function
findCheckerBoard(inputImage);

%mainScript for Video:
%videoFilename= 'Movie1.MOV';
%processVideo(videoFilename);
