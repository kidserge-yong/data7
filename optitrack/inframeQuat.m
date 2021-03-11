function result = inframeQuat(Quat1, Quat2)
% Quat1 time x 4 quaternion data (A, B, C, D)
% Quat2 time x 4 quaternion data (A, B, C, D)
% result time x 4 quaternion of Quat2 framed by Quat1
% Use quat2eul to convert to eul


%% CONDITION CHECK
assert(size(Quat1,1) == size(Quat2,1), "The size of Quat1 and Quat2 is not equal")
assert(size(Quat1,2) == size(Quat2,2), "The size of Quat1 and Quat2 is not equal")



% Quat1 = rigid_arr{1,1}(:,4:7);
% Quat2 = rigid_arr{2,1}(:,4:7);

%% Setup the primary quaternion to be (1,0,0,0)
% Fs = 200;
% M8 = mean(Quat2(ceil(Fs*0.001):round(1.5*Fs),:));
% if size(Quat1,1) > 1
%     M9 = mean(Quat1(ceil(Fs*0.001):round(1.5*Fs),:));
%     for i = 1:length(Quat1)
%         Quat1(i,:) = Cross_Multiply(Quat1(i,:),QuatConj(M9));
%     end
% end
% gain = QuatConj(Cross_Multiply(QuatConj(M9),M8));


%% Calculate inframe quaternion
nQuat2 = zeros(size(Quat1));
for i = 1:size(Quat2,1)
    nQuat2(i,:) = Cross_Multiply(Quat2(i,:),QuatConj(Quat1(i,:)));
end

tmp = nQuat2(1,:);
for i = 1:size(Quat2,1)
    nQuat2(i,:) = Cross_Multiply(nQuat2(i,:),QuatConj(tmp));
end

result = nQuat2;
% plot(quat2eul(nQuat2))
% euler = quat2eul(nQuat2);

% nQuat3 = zeros(size(euler));
% for i = 1:size(euler,2)
% nQuat3(:,i) = reconstruct(euler(:,i), 0.08);
% end
end

function quaternion = QuatConj(quaternion)
for i=2:size(quaternion,2)
    quaternion(:,i) = -quaternion(:,i);
end
end

function result = Cross_Multiply(a,b)
% multiply a(1,4), b(1,4) as cross multiplication
% result = zeros(1,4);
result(1,1) = a(1)*b(1)-a(2)*b(2)-a(3)*b(3)-a(4)*b(4);
result(1,2) = a(1)*b(2)+a(2)*b(1)+a(3)*b(4)-a(4)*b(3);
result(1,3) = a(1)*b(3)-a(2)*b(4)+a(3)*b(1)+a(4)*b(2);
result(1,4) = a(1)*b(4)+a(2)*b(3)-a(3)*b(2)+a(4)*b(1);
end

