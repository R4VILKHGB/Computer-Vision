function [u, v] = lucas_kanade_multires(frame1, frame2, num_levels, window_size, sigma)
    frame1 = double(frame1);
    frame2 = double(frame2);
    pyramid1 = build_gaussian_pyramid(frame1, num_levels, sigma);
    pyramid2 = build_gaussian_pyramid(frame2, num_levels, sigma);
    u = zeros(size(pyramid1{1}));
    v = zeros(size(pyramid1{1}));
    %flow_at_levels = cell(1, num_levels);

    for level = num_levels:-1:1
        %disp(['Processing level ' num2str(level) '...']);
        %disp(['Current size of u and v: ' num2str(size(u))]);
        u = imresize(u, size(pyramid1{level}));
        v = imresize(v, size(pyramid1{level}));
        %disp(['Resized u and v to ' num2str(size(u))]);
        u = 2 * imresize(u, size(pyramid1{level}), 'bilinear');
        v = 2 * imresize(v, size(pyramid1{level}), 'bilinear');
        [u, v] = lucas_kanade(pyramid1{level}, pyramid2{level}, window_size, u, v);
        %flow_at_levels{level} = cat(3, u, v);

        %figure;
        %imshow(frame1);
        %hold on;
        %quiver(flow_at_levels{level}(:,:,1), flow_at_levels{level}(:,:,2), 5, 'color', 'r'); %flow vectors
        %hold off;
        %title(['Optical Flow at Level ' num2str(level)]);
    end
end

function [pyramid] = build_gaussian_pyramid(image, num_levels, sigma)
    pyramid = cell(1, num_levels);
    pyramid{1} = image;
    for level = 2:num_levels
        image = imgaussfilt(image, sigma); %Gaussian smoothing
        image = imresize(image, 0.5);
        pyramid{level} = image;
    end
end

function [u, v] = lucas_kanade(frame1, frame2, window_size, u, v) %single scale
    [Ix, Iy] = gradient(frame1);
    It = frame2 - frame1;
    half_window = floor(window_size / 2);
    for i = half_window + 1 : size(frame1, 1) - half_window
        for j = half_window + 1 : size(frame1, 2) - half_window
            Ix_window = Ix(i - half_window : i + half_window, j - half_window : j + half_window);
            Iy_window = Iy(i - half_window : i + half_window, j - half_window : j + half_window);
            It_window = -It(i - half_window : i + half_window, j - half_window : j + half_window);
            A = [Ix_window(:), Iy_window(:)];
            uv = pinv(A) * It_window(:);
            u(i, j) = uv(1);
            v(i, j) = uv(2);
        end
    end
end
