clear;
clc;

s = smkData();

s.check_setting();

pause(0.5);

s.max_setting();
% In order to transfer all EMG channel, max_setting is needed 
pause(0.5);

s = s.startEMG();
% Start transfer EMG data, setting will effect this
pause(0.5);




t_max = 10;     % collect data for 10 second
t0 = clock;
max_i = t_max * 2000; % << Please increase this number if you want very long experiment
i=1;
uart = cell(max_i,1);
while etime(clock, t0) < t_max
    if i < max_i
        temp = s.getUART();
        if length(temp) > 1
            uart{i} = temp;
            i = i + 1;
        end
    end
    pause(0.01);
end

s = s.stop();

uart_array = [];
for n = 1:length(uart)
    uart_array = [uart_array, uart{n}];
end

uart_str = string(char(uart_array));
C = strsplit(uart_str, string(char([0,0,0,116]))); % cut by 0,0,0,116 (3 trigger and start bit for EMG (116))

EMG_array = s.translate2EMG(C);
