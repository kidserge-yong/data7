clear all; close all; clc
%%
% cd('E:\MATLAB\data7_EMG_Opti')
% filename = 'testround1.mat';
% 
% EMG = DataSee(filename);
ob = EMG(:,:,1);
ob(all(~ob,2),:) = [];
subplot(1,3,1); stackedplot(ob(:,1:16));
subplot(1,3,2); stackedplot(ob(:,17:32));

%%
% trial dependent variables
datatype = 'EMG';
remov_arr = [3 4 5 6 7 8 10 11 12 13 14 15 20 21 22 24 28 29 30 32];
[ReConX, Syn] = SynDerive(EMG,datatype,remov_arr);
subplot(1,3,3); stackedplot(ReConX);
%%
Y = zeros(1000,6);
%%%%%%%
%temporary for the problem of angle1
for testset_temporary = 1:1
    ccc = load('E:\MATLAB\data7_EMG_Opti\testround2.mat');
    EMG2 = double(ccc.EMG_array); clear ccc;
    if(strcmp(datatype,'EMG'))
        channels = setdiff(1:32,remov_arr);
        Femg2 = zeros(size(EMG2,1),length(channels));
        for EMG_channel = 1:length(channels)
            Femg2(:,EMG_channel) = YDFilter(abs(EMG2(:,channels(EMG_channel))),200,2,'low',2);
        end
    end; clear EMG2 EMG_channel channels
    ReConX2 = SynMagComputation(Syn,Femg2);
    clear Femg2
end; clear testset_temporary
%%%%%%%

%%
filename = 'testround2.csv';
[wristangle, armangle] = AngleDerive(filename);
%%
% trial dependent variables
mov = {'grip','open','flexion','extension','pronation','supination'};
EMG_Srate = 244;
Angle_Srate = 200;
EMG_init = round(270*Angle_Srate/EMG_Srate);
EMG_end = round(9000*Angle_Srate/EMG_Srate);
Angle_init = 14;
Angle_end = 7013;

clear InterpEMG
time1 = (0:length(ReConX2)-1)/EMG_Srate';
for channels = 1:size(ReConX2,2)
    InterpEMG(:,channels) = interp1(time1,ReConX2(:,channels),(0:1/Angle_Srate:time1(end)));
end
Comp = InterpEMG(EMG_init:EMG_end,:); Comp(:,end+1) = wristangle(Angle_init:Angle_init+EMG_end-EMG_init); 
normP = max(ReConX2);
for i =1:6
    Comp(:,i) = Comp(:,i)./normP(i);
end
mov_label = [];
tmp = strfind(mov,'flexion');
for i =1:length(move_type)
    if(sum(cell2mat(tmp(i))))
        if(i == 1)
            flex_num = 1;
        else
            flex_num = move_type(i-1);
        end
        mov_label = [mov_label i];
    end
end
tmp = strfind(mov,'extension');
for i =1:length(move_type)
    if(sum(cell2mat(tmp(i))))
        ext_num = move_type(i);
        mov_label = [mov_label i];
    end
end
wristrange = flex_num:ext_num;
wrist = regress(Comp(wristrange,end) , [ones(length(wristrange),1), Comp(wristrange,mov_label)]);
% plot(estimateEqPoint(Hparam, Comp(:,Hu_label)));hold on;

plot(YDFilter([ones(size(Comp,1),1), Comp(:,mov_label)]*wrist,200,2,'low',5)); hold on;
plot(Comp(:,end)); hold off;