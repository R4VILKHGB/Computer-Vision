## Lucas Kanade Optical Flow Estimation
I implemented Lucas Kanale optical flow estimation (single scale) and applied on images. 

### Single-scale Lucas Kanade Optical Flow Estimation
![Lucas Kanade](https://github.com/R4VILKHGB/Computer-Vision/blob/c41f7e0f8568462573c0db92b072e707fb69fb82/Lucas-Kanade/Part1_Result_Dog.png)
![Lucas Kanade](https://github.com/R4VILKHGB/Computer-Vision/blob/c41f7e0f8568462573c0db92b072e707fb69fb82/Lucas-Kanade/Part1_Result_Humanwalking.png)

## Multi-resolution Lucas Kanade Optical Flow Estimation
I implemented Lucas Kanale optical flow estimation algorithm in a multi-resolution Gaussian pyramid framework. The local window size, Gaussian smoothing parameter, and level numbers can be adjusted depending on the objective and the original images provided. 

### Single-scale Lucas Kanade Optical Flow Estimation
![Lucas Kanade Multi-resolution](https://github.com/R4VILKHGB/Computer-Vision/blob/c41f7e0f8568462573c0db92b072e707fb69fb82/Lucas-Kanade/Part2_Result_Dog.png)
![Lucas Kanade Multi-resolution](https://github.com/R4VILKHGB/Computer-Vision/blob/c41f7e0f8568462573c0db92b072e707fb69fb82/Lucas-Kanade/Part2_Result_Humanwalking.png)

## Comparison
Using a multi-resolution Gaussian pyramid framework shows the motion dynamics (both global and local) in the picture with more accuracy. More details are observed in the images that were obtained using the Gaussian pyramid framework, as seen above. And the vector density is more.
