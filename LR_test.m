% likelihood ratio test to assess all-or-nothing habit model
clear all
load HabitModelFits

rng = [1:10 12:24]; % exclude subj 11;
LLall_2 = nansum([model(2).LLactual(2,rng)]); % likelihood of full habit model
LLall_3 = nansum([model(3).LLactual(2,rng)]); % likelihood of flex-habit model

Lambda_all = max(2*(LLall_3-LLall_2),0); % likelihood ratio statistic

% compute p-value
%[h,pValue] = lratiotest(Lall_3,Lall_2,1)
p_all2 = 1-chi2cdf(Lambda_all,21)

%%
% individual participants
for s=1:24
    LL_2_2(s) = [model(2).LLactual(2,s)]; % likelihood of full habit model
    LL_3_2(s) = [model(3).LLactual(2,s)]; % likelihood of flex-habit model

    
    Lambda2(s) = max(2*(LL_3_2(s)-LL_2_2(s)),0); % likelihood ratio statistic
    
% compute p-value
%[h,pValue] = lratiotest(Lall_3,Lall_2,1)
    p2(s) = 1-chi2cdf(Lambda2(s),1);
end
inan = find(isnan(LL_2_2))
Lambda2(inan) = NaN;
p2(inan) = NaN

%% same for condition 3
% individual participants
for s=1:24
    LL_2_3(s) = [model(2).LLactual(3,s)]; % likelihood of full habit model
    LL_3_3(s) = [model(3).LLactual(3,s)]; % likelihood of flex-habit model

    Lambda3(s) = max(2*(LL_3_3(s)-LL_2_3(s)),0); % likelihood ratio statistic
    
% compute p-value
%[h,pValue] = lratiotest(Lall_3,Lall_2,1)
    p3(s) = 1-chi2cdf(Lambda3(s),1);
    
end

    %ibad = find(model(2).LLopt(3,:)==0);
    %p3(ibad) = NaN;
inan = find(isnan(LL_2_3))
Lambda3(inan) = NaN;
p3(inan) = NaN
    
    %% all participants - cond 3
    LLall_2_3 = nansum([model(2).LLactual(3,:)]); % likelihood of full habit model
LLall_3_3 = nansum([model(3).LLactual(3,:)]); % likelihood of flex-habit model

Lambda_all3 = max(2*(LLall_3_3-LLall_2_3),0); % likelihood ratio statistic

% compute p-value
%[h,pValue] = lratiotest(Lall_3,Lall_2,1)
p_all3 = 1-chi2cdf(Lambda_all3,21)
%% same for condition 1
% individual participants
for s=1:24
    LL_2_1(s) = [model(2).LLactual(1,s)]; % likelihood of full habit model
    LL_3_1(s) = [model(3).LLactual(1,s)]; % likelihood of flex-habit model

    Lambda1(s) = max(2*(LL_3_1(s)-LL_2_1(s)),0); % likelihood ratio statistic

% compute p-value
%[h,pValue] = lratiotest(Lall_3,Lall_2,1)
    p1(s) = 1-chi2cdf(Lambda1(s),1);
    
end

inan = find(isnan(LL_2_1));
Lambda1(inan) = NaN;
p1(inan) = NaN

%% all participants - cond 1
    LLall_2_1 = nansum([model(2).LLactual(1,:)]); % likelihood of full habit model
LLall_3_1 = nansum([model(3).LLactual(1,:)]); % likelihood of flex-habit model

Lambda_all1 = max(2*(LLall_3_1-LLall_2_1),0); % likelihood ratio statistic

% compute p-value
%[h,pValue] = lratiotest(Lall_3,Lall_2,1)
p_all1 = 1-chi2cdf(Lambda_all1,21)
    %% compare likelihood ratio stats to dAIC
    figure(105); clf; hold on
    plot(Lambda2,model(2).AIC(2,:)-model(3).AIC(2,:),'bo')
    plot(Lambda3,model(2).AIC(3,:)-model(3).AIC(3,:),'ro')