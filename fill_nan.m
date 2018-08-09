function [ x ] = fill_nan( x )
x = squeeze(x);
nanx = isnan(x);
t    = 1:numel(x);
x(nanx) = interp1(t(~nanx), x(~nanx), t(nanx));
end

