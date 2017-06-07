% tinker with model. examine effect of varying the habit parameter rho

rho = linspace(0,1,10);
ae = linspace(.25,.95,10);
col = [rho' 0*rho' 0*rho'];

params = [0.4000    0.0500    0.9500    0.6000    0.0500    0.9500    0.2500    1.0000];

figure(31); clf; hold on
subplot(1,2,1); hold on

for i=1:length(rho)
    params(8) = rho(i);
    presponse_rho(:,:,i) = getResponseProbs(xplot,params,'flex-habit');
    
    plot(xplot,presponse_rho(2,:,i),'-','color',col(i,:),'linewidth',2)
end
axis([0 1.2 0 1])

subplot(1,2,2); hold on
params(8) = 1;
for i=1:length(rho)
    params(3) = ae(i);
    presponse_ae(:,:,i) = getResponseProbs(xplot,params,'flex-habit');
    
    plot(xplot,presponse_ae(2,:,i),'-','color',col(i,:),'linewidth',2)
end
axis([0 1.2 0 1])

