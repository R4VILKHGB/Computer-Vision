function [u, v] = lucas_kanade(frame1, frame2, window_size)
    frame1 = double(frame1);
    frame2 = double(frame2);

    %Calculate gradients
    [Ix, Iy] = gradient(frame1);
    It = frame2 - frame1;
    
    half_window = floor(window_size / 2);
    u = zeros(size(frame1));
    v = zeros(size(frame1));

    for i = half_window + 1 : size(frame1, 1) - half_window
        for j = half_window + 1 : size(frame1, 2) - half_window
            Ix_window = Ix(i - half_window : i + half_window, j - half_window : j + half_window); %Get the local region for each pixel
            Iy_window = Iy(i - half_window : i + half_window, j - half_window : j + half_window);
            It_window = -It(i - half_window : i + half_window, j - half_window : j + half_window);
            A = [Ix_window(:), Iy_window(:)]; %Compute optical flow
            uv = pinv(A) * It_window(:);
            u(i, j) = uv(1);
            v(i, j) = uv(2);
        end
    end
end
