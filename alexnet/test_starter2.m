%%Load the pretrained network
load trainedAlex.mat;

%%Load the test images
testData = dir('dataset2\test\*.png');
numImages = numel(testData);
TestX = uint8(zeros(227,227,3,200)); %200= num. of images
for i = 1:numImages
    img = imread(fullfile(testData(i).folder, testData(i).name));
    TestX(:, :, :, i) = imresize(img, [227, 227]);
end

%%Load the test ground truth
fGroundTruth2 = fopen('dataset2\TestY.txt', 'r');
TestY = fscanf(fGroundTruth2, '%f');
fclose(fGroundTruth2);

%%Predict the counts
%%Don't forget to unnormalize and round the prediction. 
%%The output should be in the range of 0 ~ 10
YPred = predict(trainedAlex, double(TestX) / 255); %normalize to the range [0, 1]
YPred = YPred * max(TestY); %scale 
YPred = round(YPred); %round
YPred = max(0, min(10, YPred)); %in the range of 0 to 10

%%Report the accuracy
accuracy = mean(YPred == TestY);
accuracy = accuracy*100;
fprintf('Prediction accuracy: %.2f%%\n', accuracy);