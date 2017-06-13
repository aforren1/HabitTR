function [LL Lv] = habit_lik(RT,response,params,model)
% computes likelihood of observed responses under automaticity model
% inputs:
%   RT - N x 1 reaction time for each trial
%   response - N x 1 response for each trial; 1 = correct, 
%                                             2 = habit,
%                                             3 = other error
%
%   params - parameters of the model
%            [sigmaA muA qA sigmaB muB qB]; (q = probability of error in
%                                            each process)

presponse = getResponseProbs(RT,params,model);

RR = zeros(size(presponse));
RR(1,response==1)=1;
RR(2,response==2)=1;
RR(3,response==3)=1;

Lv = sum(RR.*presponse);

%{
paramsA = params(1:3);
paramsB = params(4:6);
initAE = params(7);

PhiA = normcdf(RT,paramsA(1),paramsA(2)); % probability that A has been planned by RT
PhiB = normcdf(RT,paramsB(1),paramsB(2));

qA = paramsA(3); % asymptotic error
qB = paramsB(3);

% coefficients for probability of acting according to mapping B (correct)
alpha(1,:) = [initAE (1-qA)/3 qB];

% coefficients for probability of acting according to mapping A (habit)
alpha(2,:) = [initAE qA (1-qB)/3];

% coefficients for other keys
alpha(3,:) = [.5-initAE (1-qA)/3 (1-qB)/3];

Lv = alpha(response,1).*(1-PhiA).*(1-PhiB) + alpha(response,2).*PhiA.*(1-PhiB) + alpha(response,3).*PhiB;
%}
LLv = log(Lv); % log-likelihood vector
aa =1000;
slope0 = .07;
LL = -sum(LLv) + aa*(params(2)-slope0)^2 + aa*(params(5)-slope0)^2; % total log-likelihood
%% debugging
%{
% sliding window on each response
xplot = [0:.001:1.2];
w = .075;
for i=1:length(xplot)
    igood = find(RT>xplot(i)-w/2 & RT<xplot(i)+w/2);
    if(~isempty(igood))
        pcorrect(i) = sum(response(igood)==1)/length(igood);
        phabit(i) = sum(response(igood)==2)/length(igood);
        perror(i) = sum(response(igood)==3)/length(igood);
    else
        pcorrect(i) = NaN;
        phabit(i) = NaN;
        perror(i) = NaN;
    end
end
figure(6); clf; hold on
plot(xplot,pcorrect,'b--')
plot(xplot,phabit,'r--')
plot(xplot,perror/2,'k--')


PhiAplot = normcdf(xplot,paramsA(1),paramsA(2)); % probability that A has been planned by RT
PhiBplot = normcdf(xplot,paramsB(1),paramsB(2));

PhiA2plot = normcdf(xplot,paramsA(1),paramsA(2));       
lstyle = {'b','r','k'};
for i=1:3
    phit(i,:) = alpha(i,1)*(1-PhiAplot).*(1-PhiBplot) + alpha(i,2)*PhiAplot.*(1-PhiBplot) + alpha(i,3)*PhiBplot;
    plot(xplot,phit(i,:),lstyle{i});
    
end
phitA(i,:) = .25*(1-PhiA2plot)+qA*PhiA2plot;
plot(xplot,phitA,'c')
%keyboard
%}
end

