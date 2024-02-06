function [tform_1_2, indices, rmsErr] = homographyRansac(...
    keypts1, ...    % image 1 keypoints, size 4xN
    keypts2, ...    % image 2 keypoints, size 4xN
    maxIterations, ...  % don't do more than this many iterations
    Ps,  ... % desired confidence level (prob of success); value from 0..1
    I1, I2, ...          % show images (for visualization only)
    RANSACDistanceThreshold ... %ransac distance threshold
   )



tform_1_2 = [];
indices = [];
rmsErr = [];

N = size(keypts1,2);    % Number of corresponding point pairs
if N<4
    fprintf('Can''t fit a homography using less than 4 point pairs\n');
    return;
end

pts1 = keypts1(1:2, :);                  % Get x,y coordinates from image 1, size is (2,N)
pts2 = keypts2(1:2, :);                 % Get x,y coordinates from image 2, size is (2,N)

% Estimate the uncertainty of point locations.  
% Points found in higher scales will have proportionally larger errors.
% Create a 2xN matrix of sigmas for each point, where each column is the
% sigmax, sigmay values for that point.  Assume uncertainty is the same for
% x and y.
sigs = [ RANSACDistanceThreshold*keypts2(3,:);  RANSACDistanceThreshold*keypts2(3,:)]; 

%assume fraction of inliers to be low say 20%
fraction_inliers=0.2;
inlierFraction = 0.2;
p=fraction_inliers^4;
[H,W] = size(I1);
pOutlier = 1/max(W,H);

% Calculate number of iterations
%Students write your code here 
nIterations = ceil(log(1 - Ps) / log(1 - p));
fprintf('Initial estimated number of iterations needed: %d\n', nIterations);
pause
pBest = -Inf;       % Best probability found so far (actually, the log)
for sample_count = 1:1:nIterations
    if sample_count>maxIterations
        break;
    end
    
        
    % Grab 4 matching points at random
    
    randomI = randperm(N);
    p1 = pts1(:, randomI(1:4)); 
    p2 = pts2(:, randomI(1:4));
    

    try
        tform_1_2 = fitgeotrans(p1', p2', 'projective');
    catch
        continue;
    end
    warning('on', 'all');
    
   
    % Use that homography to transform all pts1 to pts2
    pts2map = transformPointsForward(tform_1_2, pts1');
    
    % Look at the residual errors of all the points
    dp = (pts2map' - pts2);      % Size is 2xN
    dp = dp ./ sigs;      % Scale by the sigmas
    rsq = dp(1,:).^2+dp(2,:).^2;      % residual squared distance errors
    numerator = exp(-rsq/2);   
    denominator = 2*pi*sigs(1,:).*sigs(2,:);    
    pInlier = numerator./denominator;
    
    
    indicesInliers = (pInlier > pOutlier); % inlier threshold
    nInlier = sum(indicesInliers);

        
    % Net probability of the data (actually, the log of the probability).
    p = sum(log(pInlier(indicesInliers))) + (N-nInlier)*log(pOutlier);
    
    % Keep this solution if probability is better than the best so far.
    if p>pBest
        pBest = p;
        indices = indicesInliers;
        fprintf(' (Iteration %d): best so far with %d inliers', ...
            sample_count, nInlier);
        
        % Show inliers
        if ~isempty(I1) && ~isempty(I2)
            figure(100), imshow([I1,I2],[]);
            o = size(I1,2) ;
            for i=1:size(pts1,2)
                x1 = pts1(1,i);
                y1 = pts1(2,i);
                x2 = pts2(1,i);
                y2 = pts2(2,i);

                if indicesInliers(i)
                    text(x1,y1,sprintf('%d',i), 'Color', 'g');
                    text(x2+o,y2,sprintf('%d',i), 'Color', 'g');
                else
                    text(x1,y1,sprintf('%d',i), 'Color', 'r');
                    text(x2+o,y2,sprintf('%d',i), 'Color', 'r');
                end
            end
        end
        p1 = pts1(:,indices);
        p2 = pts2(:,indices);
        % use fitgeotrans function to infer the geometric  transformation 
        tform_1_2 = fitgeotrans(p1', p2', 'projective');
        test=imwarp(I2,tform_1_2);
        
        figure(777), imshow(test,[]);
          
          %pause;
        [H,W] = size(I1);
        outputView = imref2d([H W*2],[-W W], [1 H]); 
        
        out = imwarp(I1, tform_1_2, 'OutputView', outputView);  % notice how we used the invert
        for i=1:H
           for j=1:W
              if(out(i,j+W) > 0)
                 out(i,j+W) = (I2(i,j) + out(i,j+W))/2;
              else
                  out(i,j+W) = I2(i,j);
              end
           end
        end
        figure; imshow(out, []);
        pause
    end
    

end
    
fprintf('Final number of iterations used: %d\n', sample_count);
if sum(indices) < 4
    return      % Couldn't find a fit
end
fprintf('Final calculated inlier fraction: %f\n', inlierFraction);

% Ok, refit homography using all the inliers.
p1 = pts1(:,indices);
p2 = pts2(:,indices);

% Show inliers
        if ~isempty(I1) && ~isempty(I2)
            figure(100), title('yellow is inliers, blue is outliers'),imshow([I1,I2],[]);
            o = size(I1,2) ;
            for i=1:size(pts1,2)
                x1 = pts1(1,i);
                y1 = pts1(2,i);
                x2 = pts2(1,i);
                y2 = pts2(2,i);
                
                if indices(i)
                    text(x1,y1,sprintf('%d',i), 'Color', 'y');
                    text(x2+o,y2,sprintf('%d',i), 'Color', 'y');
                    line([x1;x2+o], [y1;y2],'Color','red') ;
                else
                    text(x1,y1,sprintf('%d',i), 'Color', 'b');
                    text(x2+o,y2,sprintf('%d',i), 'Color', 'b');   
                end                              
            end
        end

 
tform_1_2 = fitgeotrans(p1', p2', 'projective');

% applies the forward transformation of 2-D geometric transformation tform to
% the points specified by p1'
p2map = transformPointsForward(tform_1_2, p1');        % Transform all p1 to p2

% Look at the residual errors of all the points.
%Students write your code here 
dp = (p2map - p2');
rsq = dp(1,:).^2+dp(2,:).^2;  % residual squared distance errors

rmsErr = sqrt( sum(rsq)/length(rsq) );
disp('RMS error: '), disp(rmsErr);

% Fuse the two images.
        [H,W] = size(I1);
        outputView = imref2d([H, W*2],[-W W], [1 H]); 
        Ioutput = imwarp(I1, tform_1_2,'OutputView',outputView);  % notice how we used the invert

        % average overlapping values to blend image
        for i=1:H
           for j=1:W
              if(Ioutput(i,j+W) > 0)
                 Ioutput(i,j+W) = (I2(i,j) + out(i,j+W))/2;
              else
                  Ioutput(i,j+W) = I2(i,j);
              end
           end
        end
        figure; imshow(Ioutput, []);

figure(40), imshow(Ioutput, []);

return
