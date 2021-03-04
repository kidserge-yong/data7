clear;
clc;

s = smkData();
s.check_setting();

pause(0.5);

s.max_setting();

pause(0.5);

lib = lsl_loadlib();



result = {};
while isempty(result)
    result = lsl_resolve_byprop(lib,'type','Mocap'); end
inlet = lsl_inlet(result{1});

cellmax = 100000;


t0 = clock;
iEMGarray = cell(cellmax, 1);
iEMGcount = 0;
vecarray = cell(cellmax, 1);
veccount = 0;
i = 1;
j=1;


s = s.startIEMG();


while etime(clock, t0) < 10
    %[vec,ts] = inlet.pull_chunk();
    
    veccount = veccount + 1;
    %[s, EMG, iEMG] = s.getEMG();
    temp = s.getUART();
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

%% PostAnalysis


%% second phase
qb = qbrobot();
qb.activate(true);

temp = smk_inlet.pull_chunk();
iEMGarray = zeros(cellmax/10,35);
t0 = clock;
j=0;
while etime(clock, t0) < 10
    temp = smk_inlet.pull_chunk();
    if etime(clock, t0) < 1
    else
        angle = RT_synergy(koikefilter(iEMGarray(:,channels),freq),Y);
        
        set(h,'Xdata',1:length(angle),'YData',angle);
    end

end

%% Stop
s = s.stop();
