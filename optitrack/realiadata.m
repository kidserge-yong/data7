clear
clc
%% Load data
foldername = 'optitrack/csvdata/';
filename = 'testround1.csv';


table = readtable([foldername filename],'NumHeaderLines',6);
frame = table{:, 'Frame'};
time = table{:, 'Time'};
num = size(table,1);

rigid_num = 12; % 5+3 marker + 2 rollpitchyoll + 2 rigid body

vari = table.Properties.VariableNames;
desc = table.Properties.VariableDescriptions;

RigidBody = table{:, 3:4*rigid_num+2};
Marker = table{:, 4*rigid_num+2+1:end};

torl = 0.001;

%% Signal analysis

Rigit_1 = table{:, 3:9};
Rigit_2 = table{:, 23:29};
Rigit_3 = table{:, 47:53};
Rigit_4 = table{:, 67:73};


plot3(Rigit_1(:,5), Rigit_1(:,6), Rigit_1(:,7))
hold on;
plot3(Rigit_2(:,5), Rigit_2(:,6), Rigit_2(:,7))
plot3(Rigit_3(:,5), Rigit_3(:,6), Rigit_3(:,7))
plot3(Rigit_4(:,5), Rigit_4(:,6), Rigit_4(:,7))

%% Signal clearning
Rigit_1 = reconstruct(Rigit_1, 0.08);
Rigit_2 = reconstruct(Rigit_2, 0.08);
Rigit_3 = reconstruct(Rigit_3, 0.08);
Rigit_4 = reconstruct(Rigit_4, 0.08);

%% find different
dif_x = Rigit_1(:,1) - Rigit_2(:,1);
dif_y = Rigit_1(:,2) - Rigit_2(:,2);
dif_z = Rigit_1(:,3) - Rigit_2(:,3);

%% calculate angle
finger_pos = [];
arm_pos = Rigit_1(:, 5:7);
hand_pos = Rigit_2(:, 5:7);

%fingerangle = cal3Pangle(arm_pos, hand_pos);
wristangle = cal3Pangle(arm_pos, hand_pos);
armangle = Rigit_2(:,1);




