clear;
clc;

% s = smkData();
% s.check_setting();

% pause(0.5);
% 
% s.max_setting();
% 
% pause(0.5);

lib = lsl_loadlib();



% result = {};
% while isempty(result)
%     result = lsl_resolve_byprop(lib,'type','Mocap'); end
% optitract_inlet = lsl_inlet(result{1});

result = {};
while isempty(result)
    result = lsl_resolve_byprop(lib,'type','EMG'); end
smk_inlet = lsl_inlet(result{1});

cellmax = 100000;


iEMGarray = cell(cellmax, 1);
iEMGcount = 0;
vecarray = cell(cellmax, 1);
veccount = 0;
i = 1;
j=1;
EMG = zeros(10000,35,4);
for trial = 1:4
iEMGarray = cell(cellmax, 1);
fprintf("start collect data on trial %d \n\r", trial);
t0 = clock;
while etime(clock, t0) < 5
    %[vec,ts] = optitract_inlet.pull_chunk();
    
    veccount = veccount + 1;
    %[s, EMG, iEMG] = s.getEMG();
    temp = smk_inlet.pull_chunk();
    iEMGcount = iEMGcount + 1;
%     if (i <= cellmax) && (~isempty(vec))
%         vecarray{i} = vec;
%         i = i + 1;
%     end
    if (j <= cellmax)  && (~isempty(temp))
        %iEMGarray{j} = iEMG;
        iEMGarray{j} = temp;
        j = j + 1;
    end
    pause(0.01);
end
fprintf("finish collect data\r\n");
tmp = cell2mat(iEMGarray')';
EMG(1:size(tmp,1),:,trial) = tmp; clear tmp;
end

%% PostAnalysis
ob = EMG(:,:,1);
ob(all(~ob,2),:) = [];
ob = [ob ; EMG(:,:,2)];
ob(all(~ob,2),:) = [];
ob = [ob ; EMG(:,:,3)];
ob(all(~ob,2),:) = [];
ob = [ob ; EMG(:,:,4)];
ob(all(~ob,2),:) = [];
subplot(1,3,1); stackedplot(ob(:,1:16));
subplot(1,3,2); stackedplot(ob(:,17:32));
%% derive synergy
datatype = 'EMG';
% remov_arr = [3 11 13 21 29]; %exclude
remov_arr = setdiff(1:32,[1 4 5 6 8 9 12 14 16 17 18 19 20 24 25 26 27 28 32]); %include
channels = setdiff(1:32,remov_arr);

[ReConX, Syn,rt] = SynDerive(EMG,datatype,remov_arr);
NSyn = Syn.*max(ReConX);
subplot(1,3,3); stackedplot(ReConX);
%% second phase
qb = qbrobot();
qb.activate(true);
%%%%%%%%%%%%%%%%%%%%%%%5
%%
Y = zeros(1000,4);

close all; 

temp = smk_inlet.pull_chunk();
iEMGarray = zeros(cellmax/10,35);
iEMGcell = cell(cellmax,1);

j=1;
figure('units','normalized','position',[0.1 0.05 0.85 0.85])
h = line(0,0);
h2 = line(0,0,'color','r');
set(gca,'ylim',1*[-1 1]);
grid on
grid minor
angle = zeros(cellmax,2);
t0 = clock;
while etime(clock, t0) < 30
    iEMGarray = smk_inlet.pull_chunk();
    iEMGcell{j} = iEMGarray;
    if etime(clock, t0) < 1
    else
        if(~isempty(iEMGarray))
            j = j+1;
            [iEMGs, rt] = rt.filtered_sample(abs(iEMGarray(channels,end)'));
            angle(j,:) = RT_synergy(NSyn,iEMGs,Y);
            set(h,'Xdata',1:j,'YData',angle(1:j,1));
            set(h2,'Xdata',1:j,'YData',angle(1:j,2));
            drawnow;
%             qb.setPS(1,(1 + angle(j,1)) * 9000);
%             qb.setPS(2,angle(j,2) * 5000,1000);
        end
    end
end
%% Post analysis
qb.setPS(1,0);
qb.setPS(2,0,10000);

figure();
tmp = cell2mat(iEMGcell')';
% subplot(1,3,1); stackedplot(tmp(:,1:16));
% subplot(1,3,2); stackedplot(tmp(:,17:32));
%tmp = rt.filtered_chunk(abs(tmp(:,channels)));
tmp = koikefilter(abs(tmp(:,channels)));
[ReConX2, ~] = SynMagComputation(Syn,tmp);
subplot(1,3,3); stackedplot(ReConX2);
% max(abs(tmp))./ max(abs(ob))

%%%%%%%%%%%%%%%%%%%%%%%5
%%
clc
% set(gca,'ylim',[-0.2 0.2]);
angle = zeros(cellmax,2);
t0 = clock;
while etime(clock, t0) < 10
    iEMGarray = smk_inlet.pull_chunk();
    iEMGcell{j} = iEMGarray;
    if etime(clock, t0) < 1
    else
        if(~isempty(iEMGarray))
            j = j+1;
            if j == 1
                [iEMGs, z] = koikefilter(abs(iEMGarray(channels,end)'));
            else
                [iEMGs, z] = koikefilter(abs(iEMGarray(channels,end)'), z);
            end
            %[iEMGs, rt] = rt.filtered_sample(abs(iEMGarray(channels,end)'));
            angle(j,:) = RT_synergy(NSyn,iEMGs,Y);
            drawnow;
        end
    end
end
tmp = cell2mat(iEMGcell')';
save(datestr(now,'yyyymmdd_HHMM_SS'),'tmp')
display('complete')
%% Post analysis
figure();
tmp = cell2mat(iEMGcell')';
% subplot(1,3,1); stackedplot(tmp(:,1:16));
% subplot(1,3,2); stackedplot(tmp(:,17:32));
tmp = rt.filtered_chunk(abs(tmp(:,channels)));
[ReConX2, ~] = SynMagComputation(Syn,tmp);
subplot(1,3,3); stackedplot(ReConX2);
% max(abs(tmp))./ max(abs(ob))


%% for testing
femg = rt.filtered_chunk(abs(tmp(:,channels)));
kemg = koikefilter(abs(tmp));
rtkemg = nan(size(tmp));
[~, z] = koikefilter(abs(tmp(1,:)));
for i=1:size(tmp,1)
    [rtkemg(i,:), z] = koikefilter(abs(tmp(i,:)), z);
end

%% Stop
s = s.stop();