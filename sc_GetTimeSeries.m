% a developing version using a subportion of the data
%% Parameters
% input file
fname_AOI = 'AOI-rects-10-Jul-2022-19:03:31';

% video frame selection
sample_frame = 8590;
st_frame = 8000;
step_frame = 1;
ed_frame = v.NumFrames;

n_frame_per_section = 10000;
%
channel_number = 2; % RGB channel

% plotting-related
hdl_drawing_panel = 102;

%% Read in the video if not already done
if ~exist('v','var')
    v = fc_ReadVideo;
end

%% Load AOI Data
if ~exist('AOI_rects','var')
    D = load(fname_AOI);
    AOI_rects = D.AOI_rects;
end
%% AOI to indices
AOI_indices = cellfun(@(rect)fc_rects_to_indices(rect,[v.Width,v.Height,]),...
    num2cell(AOI_rects,2),'UniformOutput',false); % one cell per AOI will contain indices of all pixels of the AOI

%% Check AOIs
n_AOI = size(AOI_rects,1);
vidFrame = read(v,sample_frame);
for i_AOI = 1:n_AOI
    tmp = vidFrame.*repmat(uint8(AOI_indices{i_AOI}),1,1,3);
    imagesc(tmp)
    pause(0.5);
end

%% AOI to time series

frame_lists = arrayfun(@(st)st:step_frame:min(ed_frame,st+n_frame_per_section-1),...
    st_frame:n_frame_per_section:ed_frame,'UniformOutput',false);

sd_tS = cell(size(frame_lists));
n_fl = length(frame_lists);
for i_framelist = 1:n_fl
    fprintf('processing time section %i\n',i_framelist)
    sd_tS{i_framelist} = fc_video_time_series_from_AOI(v,AOI_indices,frame_lists{i_framelist},channel_number);
end
% cell function works just like for loop if provided with this function
% sd_tS = cellfun(@(frame_list)fc_video_time_series_from_AOI(v,AOI_indices,frame_list,channel_number),frame_lists,'UniformOutput',false);

sd_tS_combined = cell2mat(sd_tS(:));
%% Visualize
figure(hdl_drawing_panel)
plot(sd_tS_combined);
legend(arrayfun(@num2str,(1:n_AOI)','UniformOutput',false))