% skill vs habit comparison
% condition 2

clear all
load HabitModelFits

figure(101); clf; hold
trainingRT_all{2} = [data(:,2).trainingRT];
dRT{2} = mean(trainingRT_all{2}(2:6,:))-mean(trainingRT_all{2}(36:40,:))
dAIC{2} = model(1).AIC(2,:)-model(2).AIC(2,:);

trainingRT_all{3} = [data(:,3).trainingRT];
dRT{3} = 1000*(mean(trainingRT_all{3}(2:6,:))-mean(trainingRT_all{3}(171:175,:)))
dAIC{3} = model(1).AIC(3,1:15)-model(2).AIC(3,1:15);

%dRT = trainingRT_all(2,:)-mean(trainingRT_all(36:40));
plot(dRT{2},dAIC{2},'.','markersize',12)
plot(dRT{3},dAIC{3},'r.','markersize',12)
%plot(dRT1,dAIC,'r.','markersize',12)
ylabel('\Delta AIC')
xlabel('\Delta RT')

igood = ~isnan(dRT{2}) & ~isnan(dAIC{2});
[rho, p] = corr(dRT{2}(igood)',dAIC{2}(igood)')

%optional - labels for individual subjects
for s=1:24
   text(dRT{2}(s)+2,dAIC{2}(s),num2str(s))
end

for s=1:15
   text(dRT{3}(s)+2,dAIC{3}(s),num2str(s))
end