
bridge= imread('gateway_arch.jpg');
%imshow(bridge, []);

%E = edge(I, 'method' , THRESH , SIGMA); 
E= edge(bridge, 'canny',0.3,0.9);
%figure, imshow(E,[]);

%Choose parabola sizes to try 
C= 0.01:0.001:0.015;
c_length= numel(C); 
[M, N]= size(bridge);

%Accumulator array H(M,N,C) initialized with zeros 
H= zeros(M, N, c_length);

%Vote to fill H 
[y_edge, x_edge] = find(E); %Get edge points
for i = 1:length(x_edge)    %for all edge points
    for c_idx = 1:c_length  %for all c
        for a = 1:N
            b = round(y_edge(i) - C(c_idx) * (x_edge(i) - a)^2);
            if (b < M && b >= 1)
                H(b, a, c_idx) = H(b, a, c_idx) + 1;
            end
        end
    end
end

%Show only third slice of H 
%figure, imshow(H(:,:,3),[]);
%title(sprintf('Slice of H at C = %f', C(3)));

%Find local maxima using dilation
se= strel('disk', 5); 
H_dilated= imdilate(H, se);

%Find peaks in the dilated accumulator array
[peaksY, peaksX, peaksC]= ind2sub(size(H_dilated), find(H == H_dilated & H > 0));

pArray = [];

for k = 1:numel(peaksX) %Extract parameters for the parabola
    a = peaksX(k);
    b = round(peaksY(k));
    c_idx = peaksC(k);
    c = C(c_idx);

    %Store parameters in the array
    pArray= [pArray; a, b, c, H(b, a, c_idx)];
end

%Find the best-fitting parabola based on the highest vote count
[~, bestInd]= max(pArray(:, 4));

%Extract parameters for the best-fitting parabola
bestA= pArray(bestInd, 1);
bestB= pArray(bestInd, 2);
bestC= pArray(bestInd, 3);

%Draw the best-fitting parabola on the original image
figure, imshow(bridge, []); hold on;

x= 1:N;
y_best= bestB + bestC * (x - bestA).^2;

%Draw the best-fitting parabola on the image
plot(x, y_best, 'r', 'LineWidth', 2);

%Draw the peak point on the image
plot(bestA, bestB, 'go', 'MarkerSize', 10, 'LineWidth', 2);

hold off;
title('Best-fitting Parabola');
