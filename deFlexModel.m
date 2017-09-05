%function deFlexModel(subject,condition)
subject = 1; condition = 2;
paramsOpt_flex = model(5).paramsOpt(subject,:,condition);

figure(25); clf; hold on
subplot(1,2,1); hold on
% plot fitted model
col = {'b','r','m','g'};
for i=[1 2 3 4]
    plot(model(5).presponse(i,:,condition,subject),col{i},'linewidth',2)
    plot(data(subject,condition).sliding_window(i,:),col{i})
end

subplot(1,2,2); hold on
% now plot version with flex parameter set to 1
params_deflex = model(5).paramsOpt(subject,:,condition);
%params_deflex(1) = .37;
xplot=[.001:.001:1.2];
presponse_deflex = getResponseProbs(xplot,params_deflex,'habit')
for i=[1 2 3 4]
    plot(presponse_deflex(i,:),col{i},'linewidth',2)
    plot(data(subject,condition).sliding_window(i,:),col{i})
end