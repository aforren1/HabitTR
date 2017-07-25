% tinker with model. examine effect of varying the habit parameter rho
clear all
Np = 4;
rho = linspace(0,1,Np);
muB = linspace(.4,.7,Np);
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
        presponse_rho = getResponseProbs(xplot,params,'flex-habit');
        
        plot(xplot,presponse_rho(2,:),'r','linewidth',2)
        plot(xplot,presponse_rho(1,:),'b','linewidth',2)
        plot(xplot,presponse_rho(3,:),'m','linewidth',2)
        plot(xplot,presponse_rho(4,:),'r:')
        plot(xplot,.25,'k--')
        axis([0 1.2 0 1])
    end
end

%% analysis
Np = 6;
rho = linspace(.4,1,Np);
muB = linspace(.4,.8,Np);
%ae = linspace(.95,.25,Np);
c1 = linspace(.3,1,Np)';
c2 = linspace(1,.3,Np)';
o = ones(size(c2));
col = [c1 c2 .5*o];
col2 = [c2 .5*o c2];

figure(32); clf; hold on

for i=1:length(rho)

    for j=1:length(muB)
            subplot(2,3,j); hold on
        % compute response probabilities
        params(8) = rho(i);
        params(4) = muB(j);
        presponse_rho(:,:) = getResponseProbs(xplot,params,'flex-habit');
        
        plot(xplot,presponse_rho(2,:),'r','linewidth',2)
        plot(xplot,presponse_rho(1,:),'b','linewidth',2)
        plot(xplot,presponse_rho(3,:),'m','linewidth',2)
        %plot(xplot,presponse_rho(4,:),'r:')
        
        % un-guess point
        i_unguess(i,j) = min(find(presponse_rho(3,:)<(.25+.05)/2));
        i_correct(i,j) = min(find(presponse_rho(1,:)>(.25+.95)/2));
        %i_correct(i,j) = min(find(presponse_rho(1,:)>.9));
        max_habit(i,j) = max(presponse_rho(2,:));
        
        plot(xplot(i_unguess(i,j)),presponse_rho(3,i_unguess(i,j)),'m.','markersize',20)

    end
end

figure(1); clf; hold on
subplot(2,2,1); hold on
plot(i_unguess',i_correct')
plot(i_unguess(Np,:),i_correct(Np,:),'b.')
axis equal
xlabel('unguess time')
ylabel('correct answer time')

subplot(2,2,2); hold on
plot(i_correct',max_habit')
plot(i_correct(Np,:),max_habit(Np,:),'b.')
ylabel('max habit')
xlabel('correct answer time')

subplot(2,2,3); hold on
plot(i_unguess',max_habit')
plot(i_unguess(Np,:),max_habit(Np,:),'b.')
xlabel('unguess time')
ylabel('max habit')

subplot(2,2,4); hold on
plot(i_correct'-i_unguess',max_habit')
plot(i_correct(Np,:)-i_unguess(Np,:),max_habit(Np,:),'b.')
xlabel('difference correct answ time - unguess time')
ylabel('max habit')


