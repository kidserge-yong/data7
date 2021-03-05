qb = qbrobot();
% Enter 2 or serial port that connect to smk device here
%2
pause(0.5);

qb.activate(true);
pause(0.5);

qb= qb.start_autoupdate();
% Start loop for send command to update position and current of each device
%
pause(0.5);

% Call 
qb = qb.updateData();

qb.setPS(1,9000,10000);


Posarray = [];
Curarray = [];
t0 = clock;
while etime(clock, t0) < 10
    qb = qb.updateData();
    Posarray = [Posarray; qb.deviceArray(1, 3).position];
    Curarray = [Curarray; qb.deviceArray(1, 3).current];
end

qb = qb.stop_autoupdate();
% Stop loop for send command to update position and current of each device
%