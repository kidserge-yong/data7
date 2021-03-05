function [ReConX, Syn,rt] = SynDerive(EMG,datatype,remov_arr)
channels = setdiff(1:32,remov_arr);
if(strcmp(datatype,'EMG'))
    rt = rtfilter(length(channels), 25); % [channel, cutoff in Hz]
    for trial = 1:4
        Femg(:,:,trial) = rt.filtered_chunk(abs(EMG(:,channels,trial)));
    end
end

mov1(:,:) = Femg(:, :, 1);
mov1( all(~round(mov1),2),:) = [];
mov2(:,:) = Femg(:, :, 2);
mov2( all(~round(mov2),2),:) = [];
mov3(:,:) = Femg(:, :, 3);
mov3( all(~round(mov3),2),:) = [];
mov4(:,:) = Femg(:, :, 4);
mov4( all(~round(mov4),2),:) = [];
% mov5 = Femg(move_type(4):move_type(5), :);
% mov6 = Femg(move_type(5):move_type(6), :);

Syn = [];
tmpSyn1 = Cichocki(mov1,1,1000);
Syn = [Syn, tmpSyn1.V];
tmpSyn2 = Cichocki(mov2,1,1000);
Syn = [Syn, tmpSyn2.V];
tmpSyn3 = Cichocki(mov3,1,1000);
Syn = [Syn, tmpSyn3.V];
tmpSyn4 = Cichocki(mov4,1,1000);
Syn = [Syn, tmpSyn4.V];
% tmpSyn5 = Cichocki(mov5,1,1000);
% Syn = [Syn, tmpSyn5.V];
% tmpSyn6 = Cichocki(mov6,1,1000);
% Syn = [Syn, tmpSyn6.V];
test = [mov1; mov2; mov3 ; mov4];
ReConX = SynMagComputation(Syn,test);
end