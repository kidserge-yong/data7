function Rotation_Quat_Hand(Quat1,Quat2)
% data need to be quaternion
Fs = 200;
M8 = mean(Quat2(ceil(Fs*0.001):round(1.5*Fs),:));
M9 = mean(Quat1(ceil(Fs*0.001):round(1.5*Fs),:));
gain = QuatConj(Cross_Multiply(QuatConj(M9),M8));
for i = 1:length(Quat2)
Quat2(i,:) = Cross_Multiply(Quat2(i,:),gain);
end

H.Vertex = [-1 -1 -0.5;1 -1 -0.5;1 1 -0.5;-1 1 -0.5;-1 -1 0.5; 1 -1 0.5;1 1 0.5;-1 1 0.5];
H.face = [1 2 3 4;1 2 6 5;2 3 7 6;3 4 8 7;1 4 8 5;5 6 7 8];
H.IC = [1 0 0 ; 1 1 1 ; 1 0.3 0.8 ; 0.8 1 0.8 ; 0.25 0.5 1 ;0 0 0];
for i = 1:length(Quat1)
H.R1(i,:) = [(Quat1(i,1)^2+Quat1(i,2)^2-Quat1(i,3)^2-Quat1(i,4)^2) 2*(Quat1(i,2)*Quat1(i,3)+Quat1(i,1)*Quat1(i,4)) 2*(Quat1(i,2)*Quat1(i,4)-Quat1(i,1)*Quat1(i,3))];
H.R2(i,:) = [2*(Quat1(i,2)*Quat1(i,3)-Quat1(i,1)*Quat1(i,4)) (Quat1(i,1)^2-Quat1(i,2)^2+Quat1(i,3)^2-Quat1(i,4)^2) 2*(Quat1(i,3)*Quat1(i,4)+Quat1(i,1)*Quat1(i,2))];
H.R3(i,:) = [2*(Quat1(i,2)*Quat1(i,4)+Quat1(i,1)*Quat1(i,3)) 2*(Quat1(i,3)*Quat1(i,4)-Quat1(i,1)*Quat1(i,2)) (Quat1(i,1)^2-Quat1(i,2)^2-Quat1(i,3)^2+Quat1(i,4)^2)];
end

I.Vertex = [-3 -1 -0.5;-1 -1 -0.5;-1 1 -0.5;-3 1 -0.5;-3 -1 0.5; -1 -1 0.5;-1 1 0.5;-3 1 0.5];
I.face = [1 2 3 4;1 2 6 5;2 3 7 6;3 4 8 7;1 4 8 5;5 6 7 8];
I.IC = [1 0 0 ; 1 1 1 ; 1 0.3 0.8 ; 0.8 1 0.8 ; 0.25 0.5 1 ;0 0 0];
for i =1:length(Quat2)
I.R1(i,:) = [(Quat2(i,1)^2+Quat2(i,2)^2-Quat2(i,3)^2-Quat2(i,4)^2) 2*(Quat2(i,2)*Quat2(i,3)+Quat2(i,1)*Quat2(i,4)) 2*(Quat2(i,2)*Quat2(i,4)-Quat2(i,1)*Quat2(i,3))];
I.R2(i,:) = [2*(Quat2(i,2)*Quat2(i,3)-Quat2(i,1)*Quat2(i,4)) (Quat2(i,1)^2-Quat2(i,2)^2+Quat2(i,3)^2-Quat2(i,4)^2) 2*(Quat2(i,3)*Quat2(i,4)+Quat2(i,1)*Quat2(i,2))];
I.R3(i,:) = [2*(Quat2(i,2)*Quat2(i,4)+Quat2(i,1)*Quat2(i,3)) 2*(Quat2(i,3)*Quat2(i,4)-Quat2(i,1)*Quat2(i,2)) (Quat2(i,1)^2-Quat2(i,2)^2-Quat2(i,3)^2+Quat2(i,4)^2)];
end; clear i
% view = patch('Vertices',I.Vertex,'faces',I.face,'FaceVertexCData',I.IC,'Facecolor','flat');
% hexahedron formation
view(3);
xlabel('X axis');
ylabel('Y axis');
zlabel('Z axis');
n = length(Quat1);
T = 1/74;
i=1;
% tic;
while (i<=n)
%          pause(0.0000001);
        pause(T);
%     tic;
        %rotation matrix
        R = [H.R1(i,:) ; H.R2(i,:) ; H.R3(i,:)];
        H.C_Vertex = (R*H.Vertex')';        
        R = [I.R1(i,:) ; I.R2(i,:) ; I.R3(i,:)];
        I.C_Vertex = (R*I.Vertex')';
        sidepoint = mean(H.C_Vertex([1 2 6 5],:)) - mean(I.C_Vertex([3 4 8 7],:));
        I.C_Vertex= I.C_Vertex + sidepoint;

        if(i > 1)
            delete(h);
            delete(hi);
        end
%         if(i ==1)
%         h(j) = patch('Vertices',C_Vertex,'faces',face,'FaceVertexCData',IC,'Facecolor','flat');
%         end
        
        h = patch('Vertices',H.C_Vertex,'faces',H.face,'FaceVertexCData',H.IC,'Facecolor','flat');
        hi = patch('Vertices',I.C_Vertex,'faces',I.face,'FaceVertexCData',I.IC,'Facecolor','flat');
%         
i=i+1;
end
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

