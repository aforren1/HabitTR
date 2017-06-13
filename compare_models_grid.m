% tinker with model. examine effect of varying the habit parameter rho
Np = 4;
rho = linspace(0,1,Np);
muB = linspace(.36,.5,Np);
%ae = linspace(.95,.25,Np);
c1 = linspace(.3,1,Np)';
c2 = linspace(1,.3,Np)';
o = ones(size(c2));
col = [c1 c2 .5*o];
col2 = [c2 .5*o c2];
params = [0.4000    0.0500    0.9500    0.5000    0.0500    0.9500    0.2500    1.0000];

figure(31); clf; hold on

xplot=[.001:.001:1.2];

for i=1:length(rho)
    for j=1:length(muB)
        subplot(Np,Np,i+Np*(j-1)); hold on
        params(8) = rho(i);
        params(4) = muB(j);
        presponse_rho(:,:,i,j) = getResponseProbs(xplot,params,'flex-habit');
        
        plot(xplot,presponse_rho(2,:,i,j),'r','linewidth',2)
        plot(xplot,presponse_rho(1,:,i,j),'b','linewidth',2)
        plot(xplot,presponse_rho(4,:,i,j),'r:')
        plot(xplot,.25,'k--')
        axis([0 1.2 0 1])
    end
end

