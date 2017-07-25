% Compare change in skill for untrained and trained conditions...
% Should allow us to identify if participants can be skilled not habitual

%pull data and apply model

close all; clear all
cond_str = {'minimal','4day','4week'};

% load tmp;
load data;
clear data

maxSub = 24; exclude = d.e1.exclude;

for subject = 1:maxSub
    if ismember(subject,exclude) == 0,  %only run on subjects that completed the study
       subStr = ['s' num2str(subject)];
       
       for c = 1:2,
            if c == 1, condition = 'untrained'; 
            else condition = 'trained'; 
            end
            %pull data for model fit
            unchangedX= d.e1.(subStr).(condition).tr.bin.unchanged.x; unchangedY= d.e1.(subStr).(condition).tr.bin.unchanged.y;
            params = fit_speed_accuracy_AE2(unchangedX,unchangedY);
            output(subject,c) = params(1);
       end
    end
end
    figure(101); clf; hold on
    bar(output(:,1)-output(:,2));
    ylabel('RT Improvement (negative indicates worse performance after training)');
    
    figure(102); clf; hold on
    tmp = (output(:,1)-output(:,2));
    imissing = find(tmp==0);
    tmp(tmp==0) = [];
    plot(tmp,d.e1.group.training.RT(:,1)-d.e1.group.training.RT(:,40),'.','markersize',10)
    xlabel('skill improvement for unchanged symbols')
    ylabel('\Delta RT during training')

    %%
    load HabitModelFits
    
skill_delta = d.e1.group.training.RT(:,1)-d.e1.group.training.RT(:,40);

%imissing = find(isnan(tmp));

figure(103); clf; hold on
dAIC = model(1).AIC(2,:)-model(2).AIC(2,:);
dAIC(imissing) = [];
plot(skill_delta, dAIC,'.','markersize',12);
xlabel('\Delta RT during training')
ylabel('Habit strength (\Delta AIC)')
    
    
    
