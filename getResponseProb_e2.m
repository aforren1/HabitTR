function e2 = getResponseProb_e2(RT,presponse,params)
% returns squared error between model and data
% paramsA = [mu sigma asympt_err]

% transform parameters
sigg = @(xx) (1/(1+exp(-xx))); % sigmoidal transformation [-inf,inf] -> [-1,1]
sigg_inv = @(yy) -log(1./yy - 1); % inverse sigmoidal transformation [-1,1] -> [-inf,inf]

paramsA = params(1:3);
paramsB = params(4:6);
paramsA(3) = sigg(paramsA(3));
paramsB(3) = sigg(paramsB(3));
initAE = sigg(params(7));


% get model predictions
model_presponse = getResponseProbs(RT,paramsA,paramsB,initAE);

% compute overall error
e2 = sum(sum((presponse(1:2,:)-model_presponse(1:2,:)).^2));
