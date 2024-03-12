%Process every 15th frame and display the results, pause

function processVideo(filename)
    video= VideoReader(filename); %videoreader object
    frameInterval= 15;
    frameCounter= 0;

    %Process each frame:
    while hasFrame(video)
        frame= readFrame(video);
        frameCounter= frameCounter +1;
        %Process the frame with findCheckerBoard_students function
        if mod(frameCounter, frameInterval) == 0
            figure, imshow(frame), title('Original Video');
            findCheckerBoard_students(frame);
        end
    end
end


