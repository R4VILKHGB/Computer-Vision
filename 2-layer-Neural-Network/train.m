%%load training images into 4-D array
%%initializing the arrays
TrainX = uint8(zeros(227,227,3,1000)); %height, width, channel, index in the dataset
TrainY = zeros(1,1000); %1D array of 0s with 1000 elements (will be overwritten)

%%load all the training images
trainingData= dir('dataset\train\*.png');
for i = 1:length(trainingData) %length= 1000
    img = imread(fullfile(trainingData(i).folder, trainingData(i).name)); %full path to image
    TrainX(:, :, :, i) = imresize(img, [227, 227]); %resize current image to 227X227 pixels and assign to TrainX array
end

%%load the ground-truth data
groundDataTrain = fopen('dataset\TrainY.txt', 'r'); %open file in read mode
TrainY = fscanf(groundDataTrain, '%d'); %read integers and store in 1D array
fclose(groundDataTrain); %close file

%Normalize ground-truth
TrainY = TrainY / max(TrainY);

%%Normalizing the input range from 0 to 1 helps the training converge faster
%%normalize the input images
TrainX = double(TrainX);
TrainX = TrainX / 255;

%%Create two-layers fully connected network 
%%(you can increase the number of layers if it gives you better test accuracy)
%%define the network architecture
layers = [ ...
    imageInputLayer([227 227 3]) %input layer- 227x227 pixels with 3 channels (for RGB)
    fullyConnectedLayer(512) %hidden layer with 512 neurons
    reluLayer %ReLU activation function
    fullyConnectedLayer(1) %output layer for regression
    regressionLayer]; %regression: don't know max num. of rectangles

%%define the training options- can manipulate the values
opts = trainingOptions('sgdm', ...
    'InitialLearnRate', 0.001, ...
    'MiniBatchSize', 32, ...
    'MaxEpochs',40, ...
    'Verbose',true,...
    'Plots','training-progress');

%%display info. for debugging
%disp(size(layers));
%disp(size(TrainX));
%disp(size(TrainY));

%%flatten the input array
%%neural network expects the input data to be in 2D array format
flatTrainX = reshape(TrainX, [], size(TrainX, 4)); %reshape 4D array to 2D
    %TrainX=> 4D array, flatTrainX=> 2D array
    %[]=> calculate size of corresponding dimension based on the total number of elements in 4D array and dimension sizes
    %(TrainX, 4)=> get size of 4th dimension of TrainX and specifies second dimension of reshaped array
    %in FlatTrainX=> rows= num. of pixels in every image (height* width* channel), columns= num. of images in training data set
    %each column represents flattened image 

%%train the network
net = trainNetwork(TrainX,TrainY,layers,opts);
save('trainedModel.mat', 'net');
