function [ComputedC, Countx,Y] = RT_synergy(S,X,Y)
%{ ComputeSynergyMagnitude in YD way (cutting off minus Magnitudes with other
% S = synergy ( channel by synergy-number )
% X = IEMG ( time by channel )
% gains = weight for regression (
%}

% S = CS;
% X = CircleEMGN;

Y = [X ; Y(1:end-1,:)];
x = zeros(size(X,1),size(S,2));
e = 0.001;
% tic
for i = 1:size(X,1)
    eps = e;
    Tx = (((S'*S)^-1)*S'*X(i,:)')'; % Synergy Estimate 
    count =   0;
%     OBJ = 0;
    while(~isempty(find(Tx<-eps,1)))
    Minus = find(Tx<-eps);
    Plus = find(Tx>=-eps);
%     OBJ = 0.01 * max(Tx(Plus));
    subSyn = S; subSyn(:,Minus) = [];
    Cut = zeros(size(Tx));
    Cut(Plus) = (subSyn'*subSyn) \subSyn'*(S(:,Minus)*abs(Tx(Minus)'));
    Tx(Minus) = 0;
    Tx = Tx - Cut;
    count = count+1;
    eps = e*10^(floor(log10(count)));
    end
    x(i,:) = Tx;
    Countx(i) = count;
end
% toc
Xc(:,1) = x(:,1) -x(:,2);
% Xc(:,2) = x(:,3) -x(:,4);
% Xc(:,3) = x(:,5) -x(:,6);
ComputedC = Xc;
% clear Minus Plus Cut Tx count subSyn x A B i temp S X