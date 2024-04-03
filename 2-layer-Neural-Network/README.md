# 2-Layer Neural Network
The network is trained with images for the model to count rectangles in a given image.
The dataset folder has 2 folders for training and testing images and 2 text files: TrainY.txt and TestY.txt for training and testing the ground-truth. 

The training script loads the images and stores them in a 4D array, (height, width, channel, index)--> Channel is 3 for RGB. The ground-truth is and the input data are normalized. The input array is flattened prior to training the neural network. Additionally, regression layer is used instead of a classification layer because the max. num. of rectangles is unknown.

The testing script loads the model and predicts the num. of rectangles in the test images along with computing the prediction accuracy.
