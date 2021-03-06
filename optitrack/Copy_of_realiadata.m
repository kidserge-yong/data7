clear
clc
%% Load data
foldername = 'optitrack/xdfdata/';
filename = '2021-03-09run3.xdf';



% table = readtable([foldername filename],'NumHeaderLines',6);
xdf = load_xdf([foldername filename]);

%% Separate Optitrack and EMG data
for i = 1:size(xdf,2)
    if xdf{1, i}.info.type == "Mocap"
        optitrack_xdf = xdf{1, i};
    elseif xdf{1, i}.info.type == "EMG"
        emg_xdf = xdf{1, i};
    end
end

    

marker = optitrack_xdf.time_series(1:30,:);
rigidb_marker = optitrack_xdf.time_series(31:60,:);
rigidb = optitrack_xdf.time_series(61:end,:);
time = optitrack_xdf.time_stamps;

num = size(time,2);

rigid_num = size(rigidb,1)/8; % 5+3 marker + 2 rollpitchyoll + 2 rigid body

rigid_arr = cell(rigid_num,1); % 'position' X, Y, Z, 'quaternion' R_A, R_B, R_C, R_D, 'Confidence'

for i = 1:rigid_num
    rigid_arr{i} = rigidb((i-1)*8+1:i*8,:)';
end

%% reconstruction
% for i = 1:rigid_num
%     rigid_arr{i} = reconstruct(rigid_arr{i}, 0.08);
% end

%% Check the rigid location
% plot3(rigid_arr{1}(:,1), rigid_arr{1}(:,2), rigid_arr{1}(:,3))
% hold on;
% plot3(rigid_arr{2}(:,1), rigid_arr{2}(:,2), rigid_arr{2}(:,3))
% plot3(rigid_arr{3}(:,1), rigid_arr{3}(:,2), rigid_arr{3}(:,3))
% legend
% Check the finger hand and arm

%% calculate angle
fw = fingerWristAngleCal(rigid_arr{1}, rigid_arr{2}, rigid_arr{3});
rcfw = reconstruct(fw, 0.1);

figure;
subplot(2,1,1)
plot(rcfw)
title("Post analysis and reconstruction, gripOpen (blue), flexExte (red), pronSupi (Yellow)")

%% testing realtime function
rg1 = rigid_arr{1};
rg2 = rigid_arr{2};
rg3 = rigid_arr{3};
sample_num = size(rg1, 1);
rtfw = zeros(sample_num, 3);
initrg1 = rg1(1,:);
initrg2 = rg2(1,:);
initrg3 = rg3(1,:);
for i = 1:sample_num
    realtimerg1 = [initrg1; rg1(i,:)];
    realtimerg2 = [initrg2; rg2(i,:)];
    realtimerg3 = [initrg3; rg3(i,:)];
    rtfw(i,:) = fingerWristAngleCal(realtimerg1, realtimerg2, realtimerg3);
end

subplot(2,1,2)
plot(rtfw,'DisplayName','rtfw')
title("Realtime, gripOpen (blue), flexExte (red), pronSupi (Yellow)")

% finger_pos = rigid_arr{3}(:, 1:3);
% hand_pos = rigid_arr{2}(:, 1:3);
% arm_pos = rigid_arr{1}(:, 1:3);
% rigidR1 = rigid_arr{1, 1}(:,4:7);
% rigidR2 = rigid_arr{2, 1}(:,4:7);
% rigidR3 = rigid_arr{3, 1}(:,4:7);
% 
% wristQangle = inframeQuat(rigidR1, rigidR2);
% fingerQangle = inframeQuat(rigidR1, rigidR3);
% 
% wristangle = quat2eul(wristQangle);
% fingerangle = quat2eul(fingerQangle);
% fingerangle = fingerangle - wristangle;
% 
% rcwristangle = reconstruct(wristangle, 0.1);
% rcfingerangle = reconstruct(fingerangle, 0.1);
% eul1 = quat2eul(rigidR1);
% eul2 = quat2eul(rigidR2);
% eul3 = quat2eul(rigidR3);
% eul1(eul1<0) = eul1(eul1<0) + pi*3;
% tem = eul3(:,1);
% tem(tem<0) = tem(tem<0) + pi*3;
% 
% fingerangle = tem;
% wristangle = cal3Pangle(arm_pos, hand_pos, finger_pos);
% armangle = rigid_arr{2}(:,4);




