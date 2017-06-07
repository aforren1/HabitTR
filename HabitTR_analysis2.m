% further behavior analysis

% examine asymptotic error rates. (possible subject exclusion)

RT_thr = .9; % threshold RT above which to assess asymptotic error rates

for c=1:3
    for subject=1:24
        if(~isempty(data(subject,c).RT))
            iLongRT = find(data(subject,c).RT>RT_thr);
            
            data(subject,c).asymptCorrect = mean(data(subject,c).response(iLongRT)==1);
            
            asymptHabit(subject,c) = mean(data(subject,c).response(iLongRT)==2);
            asymptCorrect(subject,c) = data(subject,c).asymptCorrect;
        end
    end
end


%% further subject exclusions

% Exclude participants with either asymptotic error < 70% or asymptotic
% habit > 20%
[ibadC jbadC] = find(asymptCorrect<.7);
[ibadH jbadH] = find(asymptHabit>.2);

figure(110); clf; hold on
for c=1:3
    subplot(1,3,c); hold on
    %title(cond_str{c})
    plot(dAIC12(c,:),'.','markersize',15)
    
    plot([0 25],[0 0],'k')
    axis([0 25 -20 70])
    ylabel('\Delta AIC')
    xlabel('Subject #')
    
    for k=1:length(ibadC)
        if(jbadC(k)==c)
            plot(ibadC(k),dAIC12(c,ibadC(k)),'ro','linewidth',2)
        end
    end
    for k=1:length(ibadH)
        if(jbadH(k)==c)
            plot(ibadH(k),dAIC12(c,ibadH(k)),'yx','linewidth',2)
        end
    end
    
end
    
%% examine asymptote values in habit model
figure(111); clf; hold on
for c=1:3
    subplot(1,3,c); hold on
    plot(model(1).paramsOpt(:,3,c),'o')
    
    iHabitual = find(dAIC12(c,:)>0);
    plot(iHabitual,model(1).paramsOpt(iHabitual,3,c),'x')
    
end


