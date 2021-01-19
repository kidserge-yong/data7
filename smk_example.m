s = smk();
% Enter 2 or serial port that connect to smk device here
%2

s.check_setting();
% output should be
% '00000001,250
% 
% OK
% '
% 00000001,250 -> transfer only 1 channel at 250 Hz
pause(0.5);

s = s.startIEMG();
% Start transfer IEMG data, setting will NOT effect this
pause(0.5);

EMGarray = [];
iEMGarray = [];
t0 = clock;
while etime(clock, t0) < 10
  [s, EMG, iEMG] = s.getEMG();
  EMGarray = [EMGarray; EMG];
  iEMGarray = [iEMGarray; iEMG];
end
% Load data into model keep call this to update the data


s = s.stop();
% Stop transfer data
pause(0.5);

s.max_setting();
% In order to transfer all EMG channel, max_setting is needed 
pause(0.5);

s.check_setting()
% output should be
% 'FFFFFFFF,2000
% 
% OK
% '
% FFFFFFFF,2000 -> transfer all 32 channel F -> 1111 mean 4 channel at
% 2000 Hz
pause(0.5);

s = s.startEMG();
% Start transfer EMG data, setting will effect this
pause(0.5);

s = s.loaddata();
% Load data into model keep call this to update the data
pause(0.5);

s = s.stop();
% Stop transfer data
pause(0.5);