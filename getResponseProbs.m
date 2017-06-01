function presponse = getResponseProbs(RT,paramsA,paramsB,initAE)
% returns response probabilities (correct, habit, error) given RTs and
% parameters

PhiA = normcdf(RT,paramsA(1),paramsA(2)); % probability that A has been planned by RT
PhiB = normcdf(RT,paramsB(1),paramsB(2));

qA = paramsA(3);
qB = paramsB(3);

% coefficients for probability of acting according to mapping B (correct)
alpha(1,:) = [initAE (1-qA)/3 qB qB];

% coefficients for probability of acting according to mapping A (habit)
alpha(2,:) = [initAE qA (1-qB)/3 (1-qB)/3];

% coefficients for other keys
alpha(3,:) = [.5-initAE (1-qA)/3 (1-qB)/3 (1-qB)/3];

% coefficients for no-conflict A condition
alpha(4,:) = [initAE qA initAE qA];

% coefficients for no-conflict B condition
alpha(5,:) = [initAE initAE qB qB];

for i=1:5
    presponse(i,:) = alpha(i,1)*(1-PhiA).*(1-PhiB) + alpha(i,2)*PhiA.*(1-PhiB) + alpha(i,3)*(1-PhiA).*PhiB + alpha(i,4)*PhiA.*PhiB;
end