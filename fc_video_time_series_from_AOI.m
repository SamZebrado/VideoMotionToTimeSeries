function [sd_tS,raw_AOI_tS] = fc_video_time_series_from_AOI(v,AOI_indices,frame_list,channel_number)
%% Helper function
fc_into_a_vector = @(x)x(:);
fc_diff_ratio_to_y = @(x,y)(x-y)./(y+eps);% eps: avoid dividing by zero
fc_median_norm_along_column = @(x)fc_diff_ratio_to_y(x,ones(size(x,1),1)*median(x,1));% to avoid computing the mean multiple times

fc_cross_column_sd = @(x)std(x,[],2);


n_AOI = length(AOI_indices(:));
%% Get Time Series
raw_AOI_tS = repmat({nan(length(frame_list),1)},size(AOI_indices));% time series data
i_data_point = 0;
for i_frame = frame_list
    vidFrame = read(v,i_frame);
    i_data_point = i_data_point + 1;
    if mod(i_data_point,1000)==0
        fprintf('Number of data points: %i\n',i_data_point);
    end
    for i_AOI = 1:n_AOI
        tmp = vidFrame(:,:,channel_number);
        tmp_tS = fc_into_a_vector(tmp(AOI_indices{i_AOI}));
        raw_AOI_tS{i_AOI}(i_data_point,1:length(tmp_tS)) = tmp_tS;
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
end