t = linspace(-pi,pi,100);
rng default  %initialize random number generator
signal(:,1) = sin(t) + 0.25*rand(size(t));
t = linspace(-pi/2,pi,100);
signal(:,2) = sin(t) + 0.25*rand(size(t));
t = linspace(-pi,pi/2,100);
signal(:,3) = sin(t) + 0.25*rand(size(t));

ch_num = size(signal,2);
sample_num = size(signal,1);

rt = rtfilter(3, 25); % [channel, cutoff in Hz]
fdata = rt.filtered_chunk(signal);

rt_signal = NaN(size(signal));
for i = 1:sample_num
    [rt_signal(i,:), rt] = rt.filtered_sample(signal(i,:));
end

plot(rt_signal(:,1))
hold on;
plot(signal(:,1))

% % function filtedData = realtimefilter(data)
% % data is raw data with time x channel
% % filtedData is the output of the fikter
% 
% t = linspace(-pi,pi,100);
% rng default  %initialize random number generator
% x(:,1) = sin(t) + 0.25*rand(size(t));
% t = linspace(-pi/2,pi,100);
% x(:,2) = sin(t) + 0.25*rand(size(t));
% t = linspace(-pi,pi/2,100);
% x(:,3) = sin(t) + 0.25*rand(size(t));
% 
% ch_num = size(x,2);
% sample_num = size(x,1);
% signal = x;
% [b, a]    = butter(3, 0.5);
% filter_signal = filter(b,a,signal);
% 
% plot(signal)
% hold on
% plot(filter_signal)
% legend('Input Data','Filtered Data')
% 
% realt_signal = NaN(size(signal));
% z = zeros(size(x,2), max(length(a),length(b))-1);
% for ch_i = 1:ch_num
%     for sample_i = 1:sample_num
%         [realt_signal(sample_i, ch_i), z(ch_i, :)] = filter(b, a, signal(sample_i, ch_i), z(ch_i, :));
%     end
% end
% % end

%%%%



