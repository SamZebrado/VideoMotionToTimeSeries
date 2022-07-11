%% Parameters
fname_AOI = 'AOI-rects-10-Jul-2022-19:03:31';
sample_frame = 8590;
st_frame = 8000;
step_frame = 1;
hdl_drawing_panel = 102;
ed_frame = 10000;

channel_number = 2; % RGB channel
%% Helper function
fc_into_a_vector = @(x)x(:);
fc_diff_ratio_to_y = @(x,y)(x-y)./y;
fc_median_norm_along_column = @(x)fc_diff_ratio_to_y(x,ones(size(x,1),1)*median(x,1));% to avoid computing the mean multiple times

fc_cross_column_sd = @(x)std(x,[],2);

%% Read in the video if not already done
if ~exist('v','var')
    v = fc_ReadVideo;
end
%% Load AOI Data
if ~exist('AOI_rects','var')
    D = load(fname_AOI);
    AOI_rects = D.AOI_rects;
end
vidFrame = read(v,sample_frame);
AOI_indices = cellfun(@(rect)fc_rects_to_indices(rect,[v.Width,v.Height,]),...
    num2cell(AOI_rects,2),'UniformOutput',false); % one cell per AOI will contain indices of all pixels of the AOI
n_AOI = length(AOI_indices(:));
%% Check AOIs
for i_AOI = 1:n_AOI
    tmp = vidFrame.*repmat(uint8(AOI_indices{i_AOI}),1,1,3);
    imagesc(tmp)
    pause(0.5);
end
%% Get Time Series

frame_list = st_frame:step_frame:ed_frame;
raw_AOI_tS = repmat({nan(size(frame_list))},size(AOI_indices));% time series data
i_data_point = 0;
for i_frame = frame_list
    vidFrame = read(v,i_frame);
    i_data_point = i_data_point + 1;
    if mod(i_data_point,1000)==0
        fprintf('Number of data points: %i\n',i_data_point);
    end
    for i_AOI = 1:n_AOI
        tmp = vidFrame(:,:,channel_number);
        raw_AOI_tS{i_AOI}(i_data_point,:) = fc_into_a_vector(tmp(AOI_indices{i_AOI}));
    end
end
%% Preprocessing: make the changes more salient
proc_AOI_tS = raw_AOI_tS;% processed time series

for i_AOI = 1:n_AOI
    tmp = double(raw_AOI_tS{i_AOI}); % time by pixel; double can be subject to mean() and std()
    tmp = fc_median_norm_along_column(tmp); % transformed to percent change across time
    proc_AOI_tS{i_AOI} = tmp;
end

sd_AOIs = cellfun(fc_cross_column_sd,proc_AOI_tS(:)','UniformOutput',false);
sd_tS = fc_median_norm_along_column(cell2mat(sd_AOIs));
%% Visualize
figure(hdl_drawing_panel)
plot(sd_tS);
legend(arrayfun(@num2str,(1:n_AOI)','UniformOutput',false))