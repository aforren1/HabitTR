% fit constrained model
paramsInit = [.4 .05 .95 .6 .05 .95 .25 .95];
for c=1:3
    for subject = 1:24
        if(~isempty(data(subject,c).RT))
            
            % set up model 4 - habit model with qA constrained = 1
            model(4).name = 'habit-constrained';
            model(4).like_fun = @(params) habit_lik(data(subject,c).RT,data(subject,c).response,params,'habit');
            
            % set up model 5 - flex-habit model with qA constrained = 1
            model(5).name = 'flex-constrained';
            model(5).like_fun = @(params) habit_lik(data(subject,c).RT,data(subject,c).response,params,'flex-habit');
            
            for m=[4 5];
                % set up constraint
                Aeq = [0 0 1 0 0 0 0 0];
                Beq = .95;
                [model(m).paramsOpt(subject,:,c), model(m).LLopt(c,subject)] = fmincon(model(m).like_fun,paramsInit,[],[],Aeq,Beq,LB,UB);
                % get full likelihood vector
                [~, model(m).Lv{subject,c}] = model(m).like_fun(model(m).paramsOpt(subject,:,c));
                % generate continuous model predictions
                xplot=[.001:.001:1.2];
                if(m==4)
                    model(m).presponse(:,:,c,subject) = getResponseProbs(xplot,model(m).paramsOpt(subject,:,c),'habit');
                elseif(m==5)
                    model(m).presponse(:,:,c,subject) = getResponseProbs(xplot,model(m).paramsOpt(subject,:,c),'flex-habit');
                end
            end
        end
    end
end
%% compute AIC between these models
nParams = [7,4,8,6,7]; % number of parameters in each model
for c=1:3
    for subject=1:24
        if(~isempty(model(1).Lv{subject,c}))

            for m=[4 5];
                model(m).LLactual(c,subject) = sum(log(model(m).Lv{subject,c})); % compute actual (unpenalized) log-likelihood
                model(m).AIC(c,subject) = 2*nParams(m) - 2*model(m).LLactual(c,subject);
            end
            %AIC(c,subject,2) = 2*4 - 2*sum(model(2).LLv{c,subject};
            %AIC(c,subject,3) = 2*8 - 2*sum(model(3).LLv{c,subject};
        else
            for m=[4 5]
                model(m).AIC(c,subject)=NaN;
                model(m).LLopt(c,subject)=NaN;
                model(m).LLactual(c,subject)=NaN;
            end
        end
    end
end
dAIC14 = model(4).AIC-model(1).AIC;
dAIC54 = model(5).AIC-model(4).AIC;

%% plot AIC
figure(121); clf; hold on
for c=1:3
    subplot(2,3,c); hold on
    plot(dAIC54(c,:),'bo')
    axis([0 25 -10 10])
   
    subplot(2,3,c+3); hold on
    
    plot(model(4).AIC(c,:)-model(5).AIC(c,:),'bo')
end

%% likelihood ratio test
% lambda = 2log(L(theta))-2log(L(theta0))
lambda = 2*(model(5).LLactual - model(4).LLactual)

%% plot fits

cols(:,:,1) = [ 0 210 255; 255 210 0; 0 0 0; 210 0 255]/256;
cols(:,:,2) = [ 0 155 255; 255 100 0; 0 0 0; 155 0 255]/256;
cols(:,:,3) = [0 100 255; 255 0 0; 0 0 0; 100 0 255]/256;

for f=1:24
    figure(f); clf; hold on
    subplot(3,4,1);
    plot(0,0,'w.')    
    subplot(3,4,12);
    plot(0,0,'w.')
end

for c = 1:3 % 1=minimal, 2=4day, 3=4week
    if c < 2
        maxSub = 24; exclude = d.e1.exclude;
    elseif c == 3
        maxSub = 15; exclude = d.e2.exclude;
    end
    for subject = 1:maxSub
        if ismember(subject,exclude) == 0,  %only run on subjects that completed the study
            % plotting raw data...
            fhandle = figure(subject);
            mi = [2 4 5];
            for i=1:length(mi)
                subplot(3,4,i+4*(c-1));  hold on;  axis([0 1200 0 1.05]);
                title([cond_str{c},' condition; ',model(mi(i)).name,' model'],'fontsize',8);
                plot(0,0,'w.')
                plot([1:1200],data(subject,c).sliding_window(3,:),'color',cols(4,:,c),'linewidth',.5);
                plot([1:1200],data(subject,c).sliding_window(1,:),'color',cols(1,:,c),'linewidth',.5);
                plot([1:1200],data(subject,c).sliding_window(2,:),'color',cols(2,:,c),'linewidth',.5);
                
                %plotting model fit data...
                %plot([1:1200],data(subject,c).pfit_unchanged,'color',cols(4,:,c),'linewidth',2);
                
                plot([1:1200],model(mi(i)).presponse(1,:,c,subject),'color',cols(1,:,c),'linewidth',2)
                plot([1:1200],model(mi(i)).presponse(2,:,c,subject),'color',cols(2,:,c),'linewidth',2)
                plot([1:1200],model(mi(i)).presponse(3,:,c,subject),'m','linewidth',2)
                
                plot([1:1200],model(mi(i)).presponse(4,:,c,subject),':','color',cols(4,:,c),'linewidth',2)
                
                
                %text(650,.5,['AIC = ',num2str(AIC(c,subject,m))],'fontsize',8);
                

            end
            subplot(3,4,4*(c-1)+4); hold on
            plot(dAIC54(c,:),'bo')
            plot(subject,dAIC54(c,subject),'b.','markersize',20)
            
            plot([0 25],[0 0],'k')
            axis([0 25 -20 70])
            title('\Delta AIC','fontsize',8)
        end
        set(fhandle, 'Position', [600, 100, 1000, 600]);
        set(fhandle, 'Color','w')
    end
    

end