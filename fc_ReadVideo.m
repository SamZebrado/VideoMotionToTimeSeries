function v = fc_ReadVideo()
%% a wrapper for getting handle of the video


%% File Information
fname = 'VID_20220708_155119_HSR_240.mp4';

%% Read file
v = VideoReader(fname);
end