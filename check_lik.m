% compare old and new likelihood functions

%params = model(2).paramsOpt(subject,:,c)
params = paramsInit;

L1new = getResponseProbs(xplot,params,'no-habit')


sigg = @(xx) (1/(1+exp(-xx))); % sigmoidal transformation [-inf,inf] -> [-1,1]
sigg_inv = @(yy) -log(1./yy - 1); % inverse sigmoidal transformation [-1,1] -> [-inf,inf]

paramsA = params(1:3);
%paramsA(3) = sigg(params(3));
paramsB = params(4:6);
%paramsB(3) = sigg(params(6));
initAE = params(7);

L1old = getResponseProbs_1process(xplot,paramsA,paramsB,initAE);

figure(1); clf; hold on
plot(L1new')
plot(L1old','x')

%%
%compare likelihood functions
[LL1new Lv1new] = habit_lik(data(c,subject).RT,data(c,subject).response,params,'no-habit')

paramsA(3) = sigg_inv(params(3));
paramsB(3) = sigg_inv(params(6));
initAE = sigg_inv(initAE);

[LL1old Lv1old] = habit_lik_1process(data(c,subject).RT',data(c,subject).response',paramsA,paramsB,initAE);
