function presponse = getResponseProbs_rawParams(RT,params)
% returns response probabilities (correct, habit, error) given RTs and
% parameters

sigg = @(xx) (1/(1+exp(-xx))); % sigmoidal transformation [-inf,inf] -> [-1,1]
sigg_inv = @(yy) -log(1./yy - 1); % inverse sigmoidal transformation [-1,1] -> [-inf,inf]

paramsA = params(1:3);
paramsA(3) = sigg(params(3));
paramsB = params(4:6);
paramsB(3) = sigg(params(6));
initAE = sigg(params(7));

presponse = getResponseProbs(RT,paramsA,paramsB,initAE);

%{

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
%}