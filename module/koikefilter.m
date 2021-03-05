function [qt, z] = koikefilter(raw,z)
% Assume raw is time x channel


rectraw = abs(raw);
freq = 250;

a = 6.44;
b = 10.80;
c = 16.52;

T = 1/freq;
t = 0:T:0.5-T;
h = a*(exp(-b*t) - exp(-c*t)) / freq;

if nargin < 2   % no z given
    z = zeros(max(length(t),1)-1, size(raw, 2));
end

qt = zeros(size(raw));

for i = 1:size(raw,2)
    [qt(:,i), z(:,i)] = filter(h/sum(h), 1, rectraw(:,i), z(:,i));
end

%% testing
%a = 1;
