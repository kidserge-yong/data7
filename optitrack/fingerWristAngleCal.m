function fwangle = fingerWristAngleCal(rigidarm, rigidhand, rigidfinger)
% rigidarm time x 8 of XYZ position and ABCD quaternion and confident (X, Y, Z, A, B ,C ,D, confident)
% rigidhand time x 8 of XYZ position and ABCD quaternion and confident (X, Y, Z, A, B ,C ,D, confident)
% rigidfinger time x 8 of XYZ position and ABCD quaternion and confident (X, Y, Z, A, B ,C ,D, confident)
% fwangle time x 9 of finger euler rotation angle (x,y,z) and wrist euler rotation angle (x,y,z)

rigidR1 = rigidarm(:,4:7);
rigidR2 = rigidhand(:,4:7);
rigidR3 = rigidfinger(:,4:7);

wristQangle = inframeQuat(rigidR1, rigidR2);
fingerQangle = inframeQuat(rigidR1, rigidR3);

wristangle = quat2eul(wristQangle, "XYZ");
raw_fingerangle = quat2eul(fingerQangle, "XYZ");
armangle = quat2eul(rigidR1, "XYZ");
fingerangle = raw_fingerangle - wristangle;

%% analysis
% figure;
% subplot(3,2,1);
% plot(rigidarm(:,1:3));
% title("Arm rigid body position X,Y,Z")
% subplot(3,2,2);
% plot(rigidR1);
% title("Arm rigid body angular A,B,C,D")
% subplot(3,2,3);
% plot(rigidhand(:,1:3));
% title("Hand rigid body position X,Y,Z")
% subplot(3,2,4);
% plot(rigidR2);
% title("Hand rigid body angular A,B,C,D")
% subplot(3,2,5);
% plot(rigidfinger(:,1:3));
% title("Finger rigid body position X,Y,Z")
% subplot(3,2,6);
% plot(rigidR3);
% title("Finger rigid body angular A,B,C,D")
% 
% figure;
% subplot(3,2,1);
% plot(fingerQangle);
% title("Finger inframe angular A,B,C,D")
% subplot(3,2,2);
% plot(raw_fingerangle);
% title("Finger euler angular R,P,Y")
% subplot(3,2,3);
% plot(wristQangle);
% title("Wrist inframe angular A,B,C,D")
% subplot(3,2,4);
% plot(wristangle);
% title("Wrist euler angular R,P,Y")
% subplot(3,2,5);
% fingerangle(fingerangle < -pi) = -fingerangle(fingerangle < -pi);
% plot(fingerangle);
% title("Finger - Wrist euler angular R,P,Y")


% plot(finger, wrist, arm angle)

flexExte = wristangle(:,2);
gripOpen = fingerangle(:,2);
pronSupi = rigidR3(:,3);

% subplot(3,2,6);
% plot([gripOpen, flexExte, pronSupi]);
% title("gripOpen (blue), flexExte (red), pronSupi (Yellow)")

%% return data
% fwangle = [fingerangle(2:end,:), wristangle(2:end,:), armangle(2:end,:)]
fwangle = [gripOpen(2:end,:), flexExte(2:end,:), pronSupi(2:end,:)];
end