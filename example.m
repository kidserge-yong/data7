qb = qbrobot();
s = smk();

pause(0.5);

qb= qb.start_autoupdate();


s = s.startIEMG();
pause(0.5);


max_size = 2000;
qb = qb.setPS(1, 5000, 10000);
% iEMGarray = [];
% Posarray = [];
% Curarray = [];
iEMGarray = zeros(max_size,32);
Posarray = zeros(max_size,32);
Curarray = zeros(max_size,32);

pause(0.5);
[s, EMG, iEMG] = s.getEMG();
offset = iEMG;

t0 = clock;
i = 1;
while etime(clock, t0) < 10
    [s, EMG, iEMG] = s.getEMG();
%   iEMGarray = [iEMGarray; iEMG];
    if i <= 1000
        iEMGarray(i,:) = iEMG;
    end
    
    

    qb = qb.updateData();
%   Posarray = [Posarray; qb.deviceArray(1, 3).position];
%   Curarray = [Curarray; qb.deviceArray(1, 3).current];
    if i <= 1000
        Posarray(i,:) = qb.deviceArray(1, 1).position;
        Curarray(i,:) = qb.deviceArray(1, 1).current;
    end
  
    pause(0.01);
  
end

qb = qb.setPS(1, 0, 10000);

qb = qb.stop_autoupdate();