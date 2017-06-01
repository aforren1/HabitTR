presponse_e2 = getResponseProbs(xplot,paramsAOpt_e2(c,:),paramsBOpt_e2(c,:),sigg(paramsOpt_e2(c,7)));


figure(101); clf; hold on

subplot(3,2,1)
plot(xplot,normpdf(xplot,paramsBOpt_e2(1),paramsAOpt_e2(2)),'r')

subplot(3,2,[3 5])
plot(xplot,presponse_e2(5,:),'r')



%%
fig1 = figure(102); clf; hold on
fig1.Renderer='Painters';

for c=1:3
    subplot(1,3,c); hold on
    
    
    presponse_e2 = getResponseProbs(xplot,paramsAOpt_e2(c,:),paramsBOpt_e2(c,:),.25);

    
    
    plot(xplot,presponse_e2(1,:),'b')
    plot(xplot,presponse_e2(2,:),'r')
    plot(xplot,presponse_e2(4,:),'c')
    %plot(xplot,presponse_e2(5,:),'r:')
    plot(xplot,.25-(presponse_e2(4,:)-.25)/3,'r:')
    axis square
end