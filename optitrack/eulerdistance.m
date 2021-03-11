function magnitutearray = eulerdistance(vectorarray)
% vectorarray time x 3 quaternion data (X, Y, Z)
magnitutearray = zeros(size(vectorarray,1),1);
for i = 1:size(vectorarray,1)
    magnitutearray(i,:) = sqrt(sum(vectorarray(i,:).*vectorarray(i,:)));
end
end