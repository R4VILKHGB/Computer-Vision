function p = fProject(x, P_M, K) %3D to 2D projection

% Extract pose parameters (theta and t) from the passed parameter x
ax= x(1); ay= x(2); az= x(3);
tx= x(4); ty= x(5); tz= x(6);

% Calculate Rx, Ry, Rz using yaw-pitch-roll notation
Rx= [1 0 0; 0 cos(ax) -sin(ax); 0 sin(ax) cos(ax)];
Ry= [cos(ay) 0 sin(ay); 0 1 0; -sin(ay) 0 cos(ay)];
Rz= [cos(az) -sin(az) 0; sin(az) cos(az) 0; 0 0 1];

% Calculate R_m_c1 = Rz * Ry * Rx
R_m_c1= Rz* Ry* Rx;

% Define Pmorg_c = [tx; ty; tz]
Pmorg_c= [tx; ty; tz];

% Calculate the Extrinsic camera matrix from R_m_c1 and Pmorg_c - call it Mext
Mext= [R_m_c1, Pmorg_c];

% Project the real-life point by multiplying P_M by K and Mext - call the projected points ph
ph= K* Mext* P_M ;

% Convert back to the Euclidean coordinate system by dividing through the 3rd element of each column
ph(1,:)= ph(1,:)./ph(3,:);
ph(2,:)= ph(2,:)./ph(3,:);

% Get rid of the 3rd row
ph= ph(1:2, :);

% Reshape into a 2Nx1 vector
p= reshape(ph, [], 1);

end