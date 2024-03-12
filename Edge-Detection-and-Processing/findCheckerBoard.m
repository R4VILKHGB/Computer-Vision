% Find a 8x8 checkerboard in the image I.

function findCheckerBoard(I)
    if size(I,3)>1
        I = rgb2gray(I);
    end
    
    % Do edge detection using canny.
    %try different thresholds (0.5thresh - 5 thresh) to get clean edges
    
    % use E as the name of edge image
    E= edge(I, 'canny', [0.1 0.5]); %adjust the threshold as needed, returns all edges stronger than threshold 

    figure(10), imshow(E), title('Edges');
    pause
    
    % Do Hough transform to find lines.
    [H,thetaValues,rhoValues] = hough(E);
    
    % Extract peaks from the Hough array H. Parameters for this:
    % houghThresh: Minimum value to be considered a peak. Default
    % is 0.5*max(H(:))
        
    %try different number of peaks and different thresholds 

    numPeaks = 40; %adjust the number of peaks as needed
    houghThresh = ceil(0.2 * max(H(:))); %adjust the threshold as needed
    peaks = houghpeaks(H, numPeaks, 'Threshold', houghThresh);
    
    %Display Hough array and draw peaks on Hough array.
    figure(11), imshow(H, []), title('Hough'), impixelinfo;
    for i=1:size(peaks,1)
        rectangle('Position', ...
        [peaks(i,2)-3, peaks(i,1)-3, ...
        7, 7], 'EdgeColor', 'r');
    end
    pause
    
    % Show all lines.
    figure(10), imshow(E), title('All lines');
    drawLines( ...
    rhoValues(peaks(:,1)), ... % rhos for the lines
    thetaValues(peaks(:,2)), ... % thetas for the lines
    size(E), ... % size of image being displayed
    'y'); % color of line to display
    pause
    
    
    % Find two sets of orthogonal lines.
    [lines1, lines2] = findOrthogonalLines( ...
    rhoValues(peaks(:,1)), ... % rhos for the lines
    thetaValues(peaks(:,2))); % thetas for the lines
    pause

    % Sort the lines, from top to bottom (for horizontal lines) and left to
    % right (for vertical lines).
    lines1 = sortLines(lines1);
    lines2 = sortLines(lines2);
    
    % Show the two sets of lines.
    figure(12), imshow(E), title('Orthogonal lines');
    drawLines( lines1(2,:), ... % rhos for the lines
        lines1(1,:), ... % thetas for the lines
        size(E), ... % size of image being displayed
        'g'); % color of line to display
    
    drawLines( lines2(2,:), ... % rhos for the lines
        lines2(1,:), ... % thetas for the lines
        size(E), ... % size of image being displayed
        'r'); % color of line to display

    %find the outer pair of lines
    lines11=[lines1(:,1) lines1(:,end)];
    lines22=[lines2(:,1) lines2(:,end)];

    % Intersect the outer pair of lines, one from set 1 and one from set 2.
    % Output is the x,y coordinates of the intersections:
    % xIntersections(i1,i2): x coord of intersection of i1 and i2
    % yIntersections(i1,i2): y coord of intersection of i1 and i2
    [xIntersections, yIntersections] = findIntersections(lines11, lines22);
    
    % Plot outer lines and intersection points.
    figure(1), 
    hold on
    drawLines( lines11(2,:), ... % rhos for the lines
        lines11(1,:), ... % thetas for the lines
        size(E), ... % size of image being displayed
        'g'); % color of line to display
    
    drawLines( lines22(2,:), ... % rhos for the lines
        lines22(1,:), ... % thetas for the lines
        size(E), ... % size of image being displayed
        'r'); % color of line to display
    
    plot(xIntersections(:),yIntersections(:),'s', 'MarkerSize',10, 'MarkerFaceColor','r');
    hold off

end

function drawLines(rhos, thetas, imageSize, color)
% This function draws lines on whatever image is being displayed.
% Input parameters:
% rhos,thetas: representation of the line (theta in degrees)
% imageSize: [height,width] of image being displayed
% color: color of line to draw
% Equation of the line is rho = x cos(theta) + y sin(theta), or
% y = (rho - x*cos(theta))/sin(theta)

for i=1:length(thetas)
%if majority of angles are >45 then line is is mostly horizontal. 
%Pick two values of x, and solve for y = (-ax-c)/b
%else the line is is mostly horizontal. Pick two values of y,
% and solve for x

t= thetas(i);
r= rhos(i);

    if t> 45 %mostly horizontal
        %Pick two values of x and solve for y= (-ax-c)/b
        x0= 1;
        x1= imageSize(2);
        y0= (r- x0* cosd(t))/ sind(t);
        y1= (r- x1* cosd(t))/ sind(t);
    else 
        %mostly vertical
        %Pick two values of y and solve for x= (-ax-c)/b
        y0= 1;
        y1= imageSize(1);
        x0= (r- y0* sind(t))/ cosd(t);
        x1= (r- y1* sind(t))/ cosd(t);
    end

%Draw the line on the image:
line([x0 x1], [y0 y1], 'Color', color);
text(x0,y0,sprintf('%d', i), 'Color', color);
end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find two sets of orthogonal lines.
% Outputs:
% lines1, lines2: the two sets of lines, each stored as a 2xN array,
% where each column is [theta;rho]

function [lines1, lines2] = findOrthogonalLines( ...
rhoValues, ... % rhos for the lines
thetaValues) % thetas for the lines

% Find the largest two modes in the distribution of angles.
%create a set of angles in an array called bins from -90 to 90 with step 10
%then use histcounts to get the histogram
%sort and the first angle corresponds to the largest histogram count.
% The 2nd angle corresponds to the next largest count.


Bins= -90:10:90; %array Bins with angles from -90 to 90 with a step size of 10 degrees. 
[count, bins]= histcounts(thetaValues, Bins); %histogram of angle distribution
[~, indices]= sort(count, 'descend'); %sort the histogram counts, descending
a1= bins(indices(1)); %largest hist. count
a2= bins(indices(2)); %second hist. count

fprintf('Most common angles: %f and %f\n', a1, a2);

% Get the two sets of lines corresponding to the two angles. Lines will
% be a 2xN array, where

lines1 = [];
lines2 = [];
for i=1:length(rhoValues)
% Extract rho, theta for this line
r = rhoValues(i);
t = thetaValues(i);
% Check if the line is close to one of the two angles.
D = 25; % threshold difference in angle
if abs(t-a1) < D || abs(t-180-a1) < D || abs(t+180-a1) < D
    lines1 = [lines1 [t;r]];
elseif abs(t-a2) < D || abs(t-180-a2) < D || abs(t+180-a2) < D
    lines2 = [lines2 [t;r]];
end
end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sort the lines.

function lines = sortLines(lines)

t = lines(1,:); % Get all thetas
r = lines(2,:); % Get all rhos
% If most angles are between -45 .. +45 degrees, lines are mostly
% vertical.
nLines = size(lines,2);
nVertical = sum(abs(t)<=45);
if nVertical/nLines >= 0.5
% Mostly vertical lines. r=x*cos(t)+y*sin(t) 
% we need x assuming y =1 
dist = (-sind(t)*1 + r)./cosd(t); % horizontal distance
else
% Mostly horizontal lines. 
% we need y assuming x=1
dist = (-cosd(t)*1 + r)./sind(t); % vertical distance
end
[~,indices] = sort(dist, 'ascend');
lines = lines(:,indices);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Intersect pairs of lines, one from set 1 and one from set 2.
% Output arrays contain the x,y coordinates of the intersections of lines.
% xIntersections(i1,i2): x coord of intersection of i1 and i2
% yIntersections(i1,i2): y coord of intersection of i1 and i2
function [xIntersections, yIntersections] = findIntersections(lines1, lines2)
    N1 = size(lines1,2);
    N2 = size(lines2,2);
    xIntersections = zeros(N1,N2);
    yIntersections = zeros(N1,N2);
 
    %see Szeliski book section 2.1.1
    % A line is represented in homogenous coordiante system by (a,b,c), 
    % where ax+by+c=0.
    % We have r = x cos(t) + y sin(t), or x cos(t) + y sin(t) - r = 0
    % Two lines l1 and l2 intersect at a point p where p = l1 cross l2
    
    for i1=1:N1
        %Extract rho and theta for line1:
        r1= lines1(2, i1);
        t1= lines1(1, i1);

        %Find matrix representation of line1:
        l1= [cosd(t1); sind(t1); -r1]; %in homogeneous coordinates

        
        for i2=1:N2
            
            %Extract rho and theta for line2:
            r2= lines2(2, i2);
            t2= lines2(1, i2);

            %Find matrix representation of line2:
            l2= [cosd(t2); sind(t2); -r2];

            %Calculate intersection point
            p= cross(l1, l2); 
            % cross-product of the homogeneous representations of the lines gives their intersection

            %bring point back from homogenous coord to the 2D coord
            p = p/p(3);
            xIntersections(i1,i2) = p(1);
            yIntersections(i1,i2) = p(2);
        end
    end
end

