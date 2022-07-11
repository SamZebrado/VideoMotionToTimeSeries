pathList = {'drawing_functions'};
addpath(pathList{:})

%% Parameters

index_frame_AOI = 8614; % index of the frame to define areas of interest

hdl_drawing_panel = figure(100);% figure handle of drawing


%% Read in the video if not already done
if ~exist('v','var')
    v = fc_ReadVideo;
end

%% Define Areas of Interest (AOIs)

base_frame = v.read(index_frame_AOI);

%
figure(hdl_drawing_panel)

fc_refresh_bg = @()imagesc(base_frame);% refresh the background

title_str = sprintf('Left-click to define areas.\nRight-click to cancel one left-click.\nDoubl-click the same point to stop collection');
% collect clicks
qStart = true; % starting point or ending point
pointList = [];

qContinue = 1;

while qContinue
    hold off;
    fc_refresh_bg();
    axis equal;
    title(title_str);
    nPoint = size(pointList,1);
    if nPoint
        hold on
        plot(pointList(:,1),pointList(:,2),'bx','LineWidth',2)
        if nPoint>1 % at least one pair collected
            hold on;
            AOI_rects = fc_point_pairs_to_rectangels(pointList);
            fc_draw_rectangles(AOI_rects,'k','LineWidth',2);
        end
    end
    [x,y,whichButton] = ginput(1);
    switch whichButton
        case 1
            pointList(end+1,:) = [x,y];
            if nPoint>1&&isequal(pointList(end,:),pointList(end-1,:))
                qContinue = 0;% stop looping
            end
        otherwise % cancel the last point
            if nPoint>0
                pointList(end,:) = [];
            end
    end
end
save_name = ['AOI-rects-',datestr(now,'dd-mmm-yyyy-HH:MM:SS')];
save(save_name,"AOI_rects");
%% clear up

rmpath(pathList{:})