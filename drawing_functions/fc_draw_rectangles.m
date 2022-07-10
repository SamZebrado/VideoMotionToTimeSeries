function hdls = fc_draw_rectangles(rect,varargin)
%% 
% Input: 
%   rect: [x, y, width, height] of one or more rectangle (one row for one
%   rectangle)
%   varargin: will be passed to function plot(x,y,varargin{:})
% Output:
%   hdls: handle collection of all rectangles; one row for each rectangle

% transform [x, y, width, height] to five coordinates (1-2-3-4-1) for the
% rectangle in each row
x = rect(:,1);
y = rect(:,2);
w = rect(:,3);
h = rect(:,4);

X = [x  , x, x+w, x+w];
Y = [y+h, y,   y, y+h];

ind5 = [1:4,1];

hdls = plot(X(:,ind5)',Y(:,ind5)',varargin{:});
end
