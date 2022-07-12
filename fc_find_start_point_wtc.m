function st_ind = fc_find_start_point_wtc(signal,...
    amp_threshold,...
    wtc_frequency,wtc_sigma_thres,...
    min_n_sample,min_duration,...
    iSolution,varargin)
%% function start_index = fc_find_start_point(signal, amp_threshold,min_n_sample,min_duration)
% signal: is assumed to be a time series that looks like a section rising
% from a noisy baseline.
%
% median(signal) will be subtracted from signal
%
% This function will first find the time when the signal start being higher
% than high_threshold
% the number of samples higher than the high_threshold should be larger
% than min_n_sample in the following N = min_duration samples.
%
% Then the function will try to go back from the first part and try to find
% its intersection with the baseline.
%
% Sam Z. Shan Mar 28 2022
if isempty(varargin)
    qValidPlot = false;
else
    qValidPlot= varargin{1};
end
signal = signal - median(signal);

ind_higher = signal>amp_threshold;
n = conv(ind_higher,ones(1,min_duration));
ind_higher_after_now = n(1:length(ind_higher)... this indexing will make the results look like filtered by let the filter starts at time 0
    )>min_n_sample;
% the qualified starting point
q_str = find(ind_higher_after_now,1,'first');

%% Go back to find its intersection with the baseline
% different algorithms could be applied as you like

switch(iSolution)
    case 0
        %% Solution 0: simple thresholding

        ind_baseline = signal<=amp_threshold;
        st_ind = find(ind_baseline(1:q_str),1,'last');% would be empty if there is no value

    case 1
        %% Solution 1: use the median of all data points with absolute value smaller than the high_threshold as the baseline
        v_baseline = median(signal(abs(signal)<amp_threshold));

        ind_baseline = signal<=v_baseline;
        st_ind = find(ind_baseline(1:q_str),1,'last');% would be empty if there is no value

    case 2
        %% Solution 2: use 25th - 75th percentile of all data points with absolute value smaller than the high_threshold as the baseline
        % also, we can set the minimum number of samples within the baseline around the starting point
        upper_bound = prctile(signal(signal<amp_threshold),75);
        lower_bound = prctile(signal(signal<amp_threshold),25);
        ind_baseline = signal<=upper_bound&signal>=lower_bound;
        st_ind = find(ind_baseline(1:q_str),1,'last');% would be empty if there is no value
    case 3
        %% Solution 3: Based on visually checking the wtc results, threshold using
        wtc_abs_signal = abs(cwt(signal,'morse',2500));
        selected_band = wtc_abs_signal(wtc_frequency,:);% this number comes from visually checking --> around 58 Hz
        band_thres = normcdf(wtc_sigma_thres,0,1)*100;

        ind_higher = selected_band>band_thres;
        ind_higher_after_now = n(1:length(ind_higher)... this indexing will make the results look like filtered by let the filter starts at time 0
            )>min_n_sample;

        % the qualified starting point
        q_str = find(ind_higher_after_now,1,'first');

        v_baseline = prctile(selected_band(signal<amp_threshold),band_thres);% (normcdf(2,0,2)*100)

        ind_baseline = selected_band<=v_baseline;

        st_ind = find(ind_baseline(1:q_str),1,'last');% would be empty if there is no value

        % {not implemented and not validated}
    case 13
        %% combination of 1 and 3
        wtc_abs_signal = abs(cwt(signal));
        selected_band = wtc_abs_signal(wtc_frequency,:);% this number comes from visually checking --> around 58 Hz
        band_thres = normcdf(wtc_sigma_thres,0,1)*100;
        v_baseline3 = prctile(selected_band(signal<amp_threshold),band_thres);% (normcdf(2,0,2)*100)


        v_baseline1 = median(signal(signal<amp_threshold));

        ind_baseline = selected_band(:)<=v_baseline3&signal(:)<=v_baseline1;

        st_ind = find(ind_baseline(1:q_str),1,'last');% would be empty if there is no value
    case 135
        %% combine {solution 13 using smoothed data}
        ind_higher = smooth(signal,20)>amp_threshold;
        n = conv(ind_higher,ones(1,min_duration));
        ind_higher_after_now = n(1:length(ind_higher)... this indexing will make the results look like filtered by let the filter starts at time 0
            )>min_n_sample;
        % the qualified starting point
        q_str = find(ind_higher_after_now,1,'first');
        
        % wtc
        wtc_abs_signal = abs(cwt(signal));
        % select band
        selected_band = wtc_abs_signal(wtc_frequency,:);
        % compute percentage corresponding to the given sigma
        band_thres = normcdf(wtc_sigma_thres,0,1)*100;
        % threshold to pick baseline
        v_baseline3 = prctile(selected_band(signal<amp_threshold),band_thres);% (normcdf(2,0,2)*100)


        v_baseline1 = median(signal(abs(signal)<amp_threshold));

        ind_baseline = abs(selected_band(:))<=abs(v_baseline3)&abs(signal(:))<=v_baseline1;

        st_ind = find(ind_baseline(1:q_str),1,'last');% would be empty if there is no value

end
%% Validation: visualise the process to validate it
if qValidPlot
    % figure;
    t = 1:length(signal);
    hold off;
    plot(signal,'b-');
    hold on;
    fc_overlap_with_ind = @(ind,varargin)plot(t(ind),signal(ind),varargin{:});
    fc_overlap_with_ind(ind_baseline,'g-')
    fc_overlap_with_ind(ind_higher,...
        'o',...
        'LineWidth',2,...
        'MarkerSize',2,...
        'MarkerEdgeColor','m',...
        'MarkerFaceColor',[0,0,0])
    fc_overlap_with_ind(ind_higher_after_now,'o',...
        'LineWidth',2,...
        'MarkerSize',2,...
        'MarkerEdgeColor','m',...
        'MarkerFaceColor','m')
    fc_overlap_with_ind(st_ind,'r*',...
        'LineWidth',2,...
        'MarkerSize',10)
    pause(0.2); % if you have PTB, you can use the more accurate WaitSecs(0.2);
    % ylim([-0.1,0.25])
    drawnow;
end
end