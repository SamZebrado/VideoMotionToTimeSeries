%% parameters
st_frame = 8590;
step_frame = 24;
hdl_drawing_panel = 101;
%% Read in the video if not already done
if ~exist('v','var')
    v = fc_ReadVideo;
end

%% Check Video frame by frame
figure(hdl_drawing_panel);
i_frame = st_frame;
while hasFrame(v)
    i_frame = i_frame + step_frame;
    try
    vidFrame = read(v,i_frame);
    imagesc(vidFrame);
    title(sprintf('Frame %i',i_frame))
    pause();
    catch e
        disp 'error!'
        disp(e)
    end
end