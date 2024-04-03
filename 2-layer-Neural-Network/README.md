# 2-Layer Neural Network
The network is trained with images for the model to count rectangles in a given image.
The dataset folder has 2 folders for [training](https://github.com/R4VILKHGB/Computer-Vision/tree/5efa61b9afcbde696c9f35a8f7b500b3d373ce81/2-layer-Neural-Network/dataset/train) and [testing](https://github.com/R4VILKHGB/Computer-Vision/tree/5efa61b9afcbde696c9f35a8f7b500b3d373ce81/2-layer-Neural-Network/dataset/test) images and 2 text files: [TrainY.txt](https://github.com/R4VILKHGB/Computer-Vision/blob/ecc30fc1079098f61353070c32fb0223f5a765fe/2-layer-Neural-Network/dataset/TrainY.txt) and [TestY.txt](https://github.com/R4VILKHGB/Computer-Vision/blob/ecc30fc1079098f61353070c32fb0223f5a765fe/2-layer-Neural-Network/dataset/TestY.txt) for training and testing the ground-truth. 

The [training script](https://github.com/R4VILKHGB/Computer-Vision/blob/ecc30fc1079098f61353070c32fb0223f5a765fe/2-layer-Neural-Network/train.m) loads the images and stores them in a 4D array, (height, width, channel, index)--> Channel is 3 for RGB. The ground-truth is and the input data are normalized. The input array is flattened prior to training the neural network. Additionally, regression layer is used instead of a classification layer because the max. num. of rectangles is unknown.

The testing script loads the model and predicts the num. of rectangles in the test images along with computing the prediction accuracy.

