%%Define Alexnet
net = alexnet;

%%Load the images
trainingData= dir('dataset2\train\*.png');
numImages = numel(trainingData); %1000
TrainX = zeros(227, 227, 3, numImages);
for i = 1:numImages
    img = imread(fullfile(trainingData(i).folder, trainingData(i).name));
    TrainX(:, :, :, i) = imresize(img, [227, 227]);
end

%%Load the ground truth counts
fGroundTruth = fopen('dataset2\TrainY.txt', 'r');
TrainY = fscanf(fGroundTruth, '%f');
fclose(fGroundTruth);

%%Modify the last 4 layers as stated in the PDF
%%You will need a regressionLayer
layers = net.Layers(1:end-3);
layers(end+1) = fullyConnectedLayer(1); %1 neuron
layers(end+1) = reluLayer;
layers(end+1) = batchNormalizationLayer;
layers(end+1) = regressionLayer;

%regression problem becasue we don't know max num. of rectangles (not a classification problem)

%gpuDevice()
%gpuDevice(1)

%%Define training options
%%You can manipulate this
option = trainingOptions('adam', ...
    'ExecutionEnvironment','cpu',...
    'InitialLearnRate', 0.001, ...
    'MiniBatchSize', 4, ... %reduced MiniBatchSize due to GPU memory
    'MaxEpochs',10, ...
    'Shuffle','every-epoch',...
    'Verbose',true,...
    'Plots','training-progress'...
    );

%%Train the network
net = trainNetwork(TrainX,TrainY,layers,option);

%%Save the trained model
trainedAlex = net;
%%save trainedAlex;
save('trainedAlex.mat', 'trainedAlex');

