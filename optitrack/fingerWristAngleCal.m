function fwangle = fingerWristAngleCal(rigidarm, rigidhand, rigidfinger)
% rigidarm time x 8 of XYZ position and ABCD quaternion and confident (X, Y, Z, A, B ,C ,D, confident)
% rigidhand time x 8 of XYZ position and ABCD quaternion and confident (X, Y, Z, A, B ,C ,D, confident)
% rigidfinger time x 8 of XYZ position and ABCD quaternion and confident (X, Y, Z, A, B ,C ,D, confident)
% fwangle time x 6 of finger euler rotation angle (x,y,z) and wrist euler rotation angle (x,y,z)

rigidR1 = rigidarm(:,4:7);
rigidR2 = rigidhand(:,4:7);
rigidR3 = rigidfinger(:,4:7);

wristQangle = inframeQuat(rigidR1, rigidR2);
fingerQangle = inframeQuat(rigidR1, rigidR3);

wristangle = quat2eul(wristQangle);
fingerangle = quat2eul(fingerQangle);
fingerangle = fingerangle - wristangle;

fwangle = [fingerangle, wristangle];
end