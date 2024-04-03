%%Load the pretrained network
load('trainedModel.mat', 'net');

%%Load the test images
TestX = uint8(zeros(227,227,3,200)); %(height, width, channel, index)- initializing
testingData = dir('dataset\test\*.png');
for i = 1:length(testingData) %length= 200
    img = imread(fullfile(testingData(i).folder, testingData(i).name));
    TestX(:, :, :, i) = imresize(img, [227, 227]);%resize current image to 227X227 pixels and assign to TestX array
end

%%Load the test ground truth
groundDataTest = fopen('dataset\TestY.txt', 'r'); %open file in read mode
TestY = fscanf(groundDataTest, '%d'); %read integers and store in 1D array
fclose(groundDataTest); %close file

%%Predict the counts
%%Don't forget to unnormalize and round the prediction. 
%%The output should be in the range of 0 ~ 10
PredY = predict(net, double(TestX)/ 255); 
PredY = PredY* max(TestY); %unnormalizing
PredY = round(PredY); %round PredY to nearest int
PredY = max(0, min(PredY, 10));

%%Report the accuracy
accuracy = mean(PredY == TestY);
accuracy = accuracy* 100;
disp([num2str(accuracy), '%']);
