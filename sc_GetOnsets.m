%% 
% For each trial, there will be one visual stimulus and one or more
% vibrating stimuli. 
% I'm going to use the visual stimulus (the last AOI here) as a reference
% for sectioning the data, and try to find the closest onset of any
% vibrating channels.
ind_ref = 9; % index of the AOI for the reference stimuli
ind_signal = 1:8; % other channels
%% load SD time series
D = load('testTimeSeriesSD');% computed using sc_GetTimeSeries.m
sd_tS = D.sd_tS;

sd_tS_combined = cell2mat(sd_tS(:));

%% get the onset in the reference channel
ref_tS = sd_tS_combined(:,ind_ref);

% Parameters for onset in the reference channel (determined by eye)
thres = 2e13;

ref_st = find(diff([false;ref_tS(:)>=thres])==1);% changing from <thres into >thres

n_trial = length(ref_st);
%%
% Parameters for valid range around the onset of the reference channel
n_frame_preOnset = 240;
n_frame_postOnset = 240; % 1 second for 240 Hz

% Parameter for onset detection in other channels
amp_threshold = 1;
wtc_frequency = 8;% might shift for different channel, and for different segment length (determined by the valid range defined above)
wtc_sigma_thres = 1;
iSolution = 1;
min_n_sample = 15;
min_duration = 20;
qPreviewPlot = false;
%% Onset Detection
tS_signal = sd_tS_combined(:,ind_signal);
st_ind = cell(n_trial,length(ind_signal));
for i_trial = 1:n_trial
    n_frame_Onset = ref_st(i_trial);
    tS = num2cell(...
        tS_signal((n_frame_Onset-n_frame_preOnset):(n_frame_Onset+n_frame_postOnset),:),...
        1);
    st_ind(i_trial,:) = cellfun(@(signal)fc_find_start_point_wtc(signal,...
        amp_threshold,...
        wtc_frequency,wtc_sigma_thres,...
        min_n_sample,min_duration,...
        iSolution,qPreviewPlot),tS,'UniformOutput',false);
    fprintf('Trial %i / %i Done\n ', i_trial, n_trial)
end

%% Re-arrange data
st_ind(cellfun(@isempty,st_ind)) = {nan};
st = cell2mat(st_ind);
unique(sum(~isnan(st),2));

%% Transform the onsets' unit as second
% sampling frequency
sf = 240; % Hz
% computing
onset_delays = (nanmean(st,2)-n_frame_preOnset)/240;
%
onset_delays = onset_delays(~isnan(onset_delays));
% stats
fprintf('Mean delay: %.5f s, SD: %.5f s, from %i trials\n',mean(onset_delays),std(onset_delays),length(onset_delays));
