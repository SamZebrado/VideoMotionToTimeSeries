function bool_ind = fc_rects_to_indices(rect,bg_size)
%%
% Inputs:
%       rect: [x, y, w, h] of one rectangle
%       bg_size: [width, height] size of the background image
% Output:
%       bool_ind: boolean indices (2D) of elements within the rectangle on the background
[x,y,w,h] = deal(rect(1),rect(2),rect(3),rect(4));

[bg_X,bg_Y] = meshgrid(1:bg_size(1),1:bg_size(2));

bool_ind = bg_X>=x&...
    bg_X<=(x+w)&...
    bg_Y>=y&...
    bg_Y<=(y+h);


end