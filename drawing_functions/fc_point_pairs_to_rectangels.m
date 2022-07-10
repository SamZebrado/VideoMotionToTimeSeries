function rect = fc_point_pairs_to_rectangels(xy2)
%%
% Input:
%   x2,y2: x,y coordinates of several points, every two points will be used
%   to define a rectangle (assuming they are the diagonal of the
%   rectangle).
%
%   If there are odd number of rows, the last row will be removed; if there
%   are fewer than 2 rows, an error will be returned
%
% Output:
%   [x,y,w,h]: lower-left point coordinates, width and heights of
%   rectangles (one row for one rectangle)
%
assert(length(xy2(:))>2,'number of points have to be larger than 2')
if mod(size(xy2,1),2)
    xy2 = xy2(1:end-1,:);
end
x2 = reshape(xy2(:,1),2,[]);
y2 = reshape(xy2(:,2),2,[]);

x = min(x2,[],1);
y = min(y2,[],1);

w = max(x2,[],1)-x;
h = max(y2,[],1)-y;

rect = [x;y;w;h]';
end