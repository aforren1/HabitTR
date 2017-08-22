% inspect individual participants
xplot = [.001:.001:1.2];
s_flex = [1 3 4 11]; % participants which look more habitual than 

s = 11;

figure(201); clf; hold on
subplot(3,1,1); hold on

plot(xplot,data(s,2).sliding_window(1,:),'c','linewidth',1.5)
plot(xplot,data(s,2).sliding_window(2,:),'r','linewidth',1.5)
plot(xplot,data(s,2).sliding_window(3,:),'m','linewidth',1.5)
%plot(xplot,data(s,2).sliding_window(4,:))

pp2 = model(2).paramsOpt(s,:,2);
pp3 = model(3).paramsOpt(s,:,2);

habit_lik(data(s,2).RT,data(s,2).response,pp2,'habit')
plot(xplot,model(2).presponse(1,:,2,s),'c','linewidth',1)
plot(xplot,model(2).presponse(2,:,2,s),'c','linewidth',1)
plot(xplot,model(2).presponse(3,:,2,s),'c','linewidth',1)

[L,Lv] = habit_lik(data(s,2).RT,data(s,2).response,pp2,'habit');
L

subplot(3,1,2); hold on
plot(data(s,2).RT,log(Lv),'co')
plot(xplot,log(model(2).presponse(:,:,2,s)'),'c')

pp2(4) = .56;
pp2(5) = .1;
[L,Lv] = habit_lik(data(s,2).RT,data(s,2).response,pp2,'habit');
L
presponse = getResponseProbs(xplot,pp2,'habit');
subplot(3,1,1)
plot(xplot,presponse(1,:),'r','linewidth',2)
plot(xplot,presponse(2,:),'r','linewidth',2)
plot(xplot,presponse(3,:),'r','linewidth',2)

xlim([0 1.2])

subplot(3,1,2); hold on
plot(data(s,2).RT,log(Lv),'ro')
plot(xplot,log(presponse)','r')

subplot(3,1,3); hold on
plot(data(s,2).RT,data(s,2).response,'o')
xlim([0 1.2])