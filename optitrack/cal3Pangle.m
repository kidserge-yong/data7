function angle3P = cal3Pangle(rigid1, rigid2, rigid3) 
% dimension of input and output is time x 7
% 7 consisted of r_x, r_y, r_z, r_w, x, y, z
% time is the number of input
    num = size(rigid1, 1);
    angle = zeros(num,1);
    %p = [0,1,0];

    for i = 1:num
        p0 = rigid1(i,:);
        p1 = rigid2(i,:);
        p2 = rigid3(i,:);
        angle(i,:) = vecangle360(p0, p1, p2);
    end
    angle3P = angle;
end