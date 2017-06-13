% tinker with model. examine effect of varying the habit parameter rho
Np = 6;
rho = linspace(0,1,Np);
ae = linspace(.95,.25,Np);
c1 = linspace(.3,1,Np)';
c2 = linspace(1,.3,Np)';
o = ones(size(c2));
col = [c1 c2 .5*o];
col2 = [c2 .5*o c2];
params = [0.4000    0.0500    0.9500    0.5000    0.0500    0.9500    0.2500    1.0000];

figure(31); clf; hold on

xplot=[.001:.001:1.2];

for i=1:length(rho)
    subplot(Np,2,2*i-1); hold on
    params(8) = rho(i);
    presponse_rho(:,:,i) = getResponseProbs(xplot,params,'flex-habit');
    
    plot(xplot,presponse_rho(2,:,i),'r','linewidth',2)
    plot(xplot,presponse_rho(1,:,i),'b','linewidth',2)
    plot(xplot,presponse_rho(4,:,i),'r:')
end
axis([0 1.2 0 1])

%{
subplot(Np,2,2); hold on
params(8) = 1;
for i=1:length(rho)
    params(3) = ae(i);
    presponse_ae(:,:,i) = getResponseProbs(xplot,params,'flex-habit');
    
    plot(xplot,presponse_ae(2,:,i),'-','color',col(i,:),'linewidth',2)
    plot(xplot,presponse_ae(1,:,i),'-','color',col2(i,:),'linewidth',2)
end
axis([0 1.2 0 1])
%}
muB = linspace(.36,.5,Np);
params(8) = 1;
params(3) = .95;
subplot(1,2,2);

for i=1:length(muB)
    subplot(Np,2,2*i); hold on
    params(4) = muB(i);
    presponse_muB(:,:,i) = getResponseProbs(xplot,params,'flex-habit');
    
    plot(xplot,presponse_muB(2,:,i),'r','linewidth',2)
    plot(xplot,presponse_muB(1,:,i),'b','linewidth',2)
    plot(xplot,presponse_rho(4,:,i),'r:')
end
axis([0 1.2 0 1])


%% examine whether there is such a thing as an intermediate habit
rho = squeeze(model(5).paramsOpt(:,8,:));
rho(rho==0)=NaN;
figure(32); clf; hold on
hist(rho)

[subj_noHabit c_noHabit] = find(rho<0.1 | rho>.9);
[subj_Habit c_Habit] = find(rho>0.1 & rho<.9);