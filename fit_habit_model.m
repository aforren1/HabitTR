% fit models to habit data
%
% model 1 = habit model - assume 
%
clear all

% load data
load HabitData;

% set up bounds for model
LB_AE = .0001; UB_AE = .9999;
LB = [0 .01 .5 0 0 .5 LB_AE LB_AE];
UB = [.75 100 UB_AE 10 100 UB_AE .499 UB_AE];
PLB = [.2 .02 LB_AE .2 .02 .5 .1 LB_AE];
PUB = [.7 .5 .5 .7 .5 UB_AE .4 UB_AE];

% initial parameters
paramsInit = [.4 .05 .99 .5 .05 .95 .25 .95];

% Inequality constraint to ensure that muA < muB
A = [0 0 1 0 0 -1 0 0];
B = 0;

for m=1:3
    % RT-values for plotting model prediction
    model(m).RTplot = [.001:.001:1.2];
end

for c = 1:3 % 1=minimal, 2=4day, 3=4week
    for subject = 1:size(data,1)
        if (~isempty(data(subject,c).RT)) % if this subject is not already excluded
            
            % set up and fit each model
            for m=1:3
                like_fun = @(params) habit_lik(data(subject,c).RT,data(subject,c).response,params,model(m).name);
                
                %[paramsOpt LLopt_2process(c,subject)] = fminsearch(habit_lik_constr,paramsInit);
                %[model(i).paramsOpt(subject,:,c), model(i).LLopt(c,subject)] = bads(model(i).like_fun,paramsInit,LB,UB,PLB,PUB);
                [model(m).paramsOpt(subject,:,c), model(m).LLopt(c,subject)] = fmincon(like_fun,paramsInit,A,B,[],[],LB,UB);
                
                % get full likelihood vector
                [~, model(m).Lv{subject,c}] = like_fun(model(m).paramsOpt(subject,:,c));
            end
            
            % generate continuous model predictions
            for m=1:3
                model(m).presponse(:,:,c,subject) = getResponseProbs(model(m).RTplot,model(m).paramsOpt(subject,:,c),model(m).name);
            end     
        end
    end
end

%% model comparison
% set likelihood to NaN's for missing data
for c=1:3
    for subject=1:24
        if(~isempty(model(1).Lv{subject,c}))
            nParams = [7,4,8];
            for m=1:3
                model(m).LLactual(c,subject) = sum(log(model(m).Lv{subject,c})); % compute actual (unpenalized) log-likelihood
                model(m).AIC(c,subject) = 2*nParams(m) - 2*model(m).LLactual(c,subject);
            end
            %AIC(c,subject,2) = 2*4 - 2*sum(model(2).LLv{c,subject};
            %AIC(c,subject,3) = 2*8 - 2*sum(model(3).LLv{c,subject};
        else
            for m=1:3
                model(m).AIC(c,subject,1) = NaN;
                model(m).LLopt(c,subject)=NaN;
                model(m).LLactual(c,subject)=NaN;
            end
        end
    end
end

%{
% compare likelihoods
figure(100); clf; hold on
for c=1:3
    subplot(1,3,c); hold on
    plot(model(2).LLactual(c,:)-model(1).LLactual(c,:),'.','markersize',20)
    axis([0 25 -10 40])
end

% compare AIC
figure(101); clf;
for c=1:3
    subplot(1,3,c); hold on
    title(cond_str{c})
    plot(model(2).AIC(c,:)-model(1).AIC(c,:),'.','markersize',20)
    
    plot([0 25],[0 0],'k')
    axis([0 25 -20 70])
    ylabel('\Delta AIC')
    xlabel('Subject #')
    
end
%}
%{
dAIC12 = model(2).AIC-model(1).AIC;

figure(102); clf; hold on
plot(nanmean(dAIC12'),'.','markersize',20)
plot([1 1; 2 2; 3 3]',[nanmean(dAIC12')+seNaN(dAIC12');nanmean(dAIC12')-seNaN(dAIC12')],'b-')
plot([0 4],[0 0],'k')
xlim([.5 3.5])
ylabel('Average \Delta AIC')
xlabel('condition')
%}
%%
save HabitModelFits model data 