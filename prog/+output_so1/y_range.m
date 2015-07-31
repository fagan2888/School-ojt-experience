function [yMin, yMax] = y_range(dataM, missVal)
% given a data matrix, find the best y axis range
% --------------------------------------------------

xV = dataM(dataM ~= missVal);

yMin = ceil((min(xV(:)) - 0.1) .* 10) ./ 10;
yMax = floor((max(xV(:)) + 0.1) .* 10) ./ 10;

end