close all; clear all;

makepdf = 1; % make a pdf of data if 1

load tmp;
clear data
% fit model on a subject by subject basis...
p = [];
p.condition1.unchanged = []; p.condition1.revised = [];
p.condition2.unchanged = []; p.condition2.revised = [];
p.condition3.unchanged = []; p.condition3.revised = [];

for c = 1:3 % 1=minimal, 2=4day, 3=4week
    if c < 2
        maxSub = 24; exclude = d.e1.exclude;
    elseif c == 3
        maxSub = 15; exclude = d.e2.exclude;
    end
    
    for subject = 1:maxSub
        if ismember(subject,exclude) == 0,  %only run on subjects that completed the study
            subStr = ['s' num2str(subject)];
            if c==1
                unchanged = d.e1.(subStr).untrained.tr.sw.unchanged;	revised = d.e1.(subStr).untrained.tr.sw.revised; habit = d.e1.(subStr).untrained.tr.sw.habit;
                unchangedX= d.e1.(subStr).untrained.tr.bin.unchanged.x; unchangedY= d.e1.(subStr).untrained.tr.bin.unchanged.y;
                revisedX =  d.e1.(subStr).untrained.tr.bin.revised.x;   revisedY =  d.e1.(subStr).untrained.tr.bin.revised.y;
                recodedX =  d.e1.(subStr).untrained.tr.modelCoded.x;    recodedY =  d.e1.(subStr).untrained.tr.modelCoded.y;
            elseif c==2
                unchanged = d.e1.(subStr).trained.tr.sw.unchanged; revised = d.e1.(subStr).trained.tr.sw.revised; habit = d.e1.(subStr).trained.tr.sw.habit;
                unchangedX= d.e1.(subStr).trained.tr.bin.unchanged.x; unchangedY= d.e1.(subStr).trained.tr.bin.unchanged.y;
                revisedX =  d.e1.(subStr).trained.tr.bin.revised.x;   revisedY =  d.e1.(subStr).trained.tr.bin.revised.y;
                recodedX =  d.e1.(subStr).trained.tr.modelCoded.x;    recodedY =  d.e1.(subStr).trained.tr.modelCoded.y;
            elseif c==3
                unchanged = d.e2.(subStr).tr.sw6.unchanged;     revised = d.e2.(subStr).tr.sw6.revised;         habit = d.e2.(subStr).tr.sw6.habit;
                unchangedX= d.e2.(subStr).tr.bin.unchanged.x;   unchangedY= d.e2.(subStr).tr.bin.unchanged.y;
                revisedX =  d.e2.(subStr).tr.bin.revised.x;     revisedY =  d.e2.(subStr).tr.bin.revised.y;
                recodedX =  d.e2.(subStr).tr.modelCoded.x;      recodedY =  d.e2.(subStr).tr.modelCoded.y;
            end
            
            paramsU = fit_speed_accuracy_AE2(unchangedX,unchangedY);
            p1 = paramsU(4)+(paramsU(3)-paramsU(4))*normcdf([(1:1200)/1000],paramsU(1),paramsU(2));
            p.(['condition' num2str(c)]).unchanged = [p.(['condition' num2str(c)]).unchanged; paramsU];
            
            params = fit_speed_accuracy_AE2(revisedX,revisedY);
            p2 = params(4)+(params(3)-params(4))*normcdf([(1:1200)/1000],params(1),params(2));
            p.(['condition' num2str(c)]).revised = [p.(['condition' num2str(c)]).revised; params];
            
            %%ADRIAN: here's the place to try out the new fitting.
            %you can use inputs recodedX and recodedY
            %	recodedX is the response time (aka preparation time)
            %   for recodedY...
            %       0 = non-habitual error
            %       1 = correct response
            %       2 = habitual error
            
            % revise errors to 3, not 0 (for indexing)
            i0 = find(recodedY==0);
            recodedY(i0) = 3;
            
            % get rid of any trials that had unchanged x - fitting to
            % changed symbols only
            revised_trials = ismember(recodedX,revisedX);
            recodedX = recodedX(revised_trials)';
            recodedY = recodedY(revised_trials)';
            
            %---Adrian fits from here down----
            
            % lower/upper bounds for fitting (with BADS)
            % params: [mu_A sigma_A AE_A mu_B sigma_B AE_B init_AE rho]; -
            %       NB - rho = probability of habit in flex-habit model
            LB_AE = .001; UB_AE = .999;
            LB = [0 0 LB_AE 0 0 LB_AE LB_AE LB_AE];
            UB = [.75 100 UB_AE 10 10 UB_AE .499 UB_AE];
            PLB = [.2 .02 LB_AE .2 .02 LB_AE .1 LB_AE];
            PUB = [.7 .5 UB_AE .7 .5 UB_AE .4 UB_AE];
            
            %paramsInit = [paramsA(1:3) paramsB(1:3) paramsA(4) .5];
            %paramsInit = max(paramsInit,LB);
            %paramsInit = min(paramsInit,UB);
            
            paramsInit = [.8 .05 .95 .6 .05 .95 .25 .95];
            
            model(1).name = 'habit';
            model(2).name = 'no-habit';
            model(3).name = 'flex-habit';
            
            
            data(subject,c).RT = recodedX;
            data(subject,c).response = recodedY;
            data(subject,c).sliding_window(1,:) = revised;
            data(subject,c).sliding_window(2,:) = habit;
            data(subject,c).sliding_window(4,:) = unchanged;
            
            data(subject,c).pfit_unchanged = p1;
            
            % set up and fit each model
            for m=1:3
                %model(i).InitParams
                model(m).like_fun = @(params) habit_lik(data(subject,c).RT,data(subject,c).response,params,model(m).name);
                
                %[paramsOpt LLopt_2process(c,subject)] = fminsearch(habit_lik_constr,paramsInit);
                %[model(i).paramsOpt(subject,:,c), model(i).LLopt(c,subject)] = bads(model(i).like_fun,paramsInit,LB,UB,PLB,PUB);
                [model(m).paramsOpt(subject,:,c), model(m).LLopt(c,subject)] = fmincon(model(m).like_fun,paramsInit,[],[],[],[],LB,UB);
                
                % get full likelihood vector
                [~, model(m).Lv{subject,c}] = model(m).like_fun(model(m).paramsOpt(subject,:,c));
            end
            
            % generate continuous model predictions
            xplot=[.001:.001:1.2];
            for m=1:3
                model(m).presponse(:,:,c,subject) = getResponseProbs(xplot,model(m).paramsOpt(subject,:,c),model(m).name);
            end
            
        end
    end

end

%% model comparison
% set likelihood to NaN's for missing data
for c=1:3
    for subject=1:24
        if(~isempty(model(1).Lv{subject,c}))
            AIC(c,subject,1) = 2*7 + 2*model(1).LLopt(c,subject);
            AIC(c,subject,2) = 2*4 + 2*model(2).LLopt(c,subject);
            AIC(c,subject,3) = 2*8 + 2*model(2).LLopt(c,subject);
        else
            AIC(c,subject,1) = NaN;
            AIC(c,subject,2) = NaN;
            AIC(c,subject,3) = NaN;
            for m=1:3
                model(m).LLopt(c,subject)=NaN;
            end
        end
    end
end

% compare likelihoods
figure(100); clf; hold on
for c=1:3
    subplot(1,3,c); hold on
    plot(model(2).LLopt(c,:)-model(1).LLopt(c,:),'o')
    axis([0 25 -10 40])
end

% compare AIC
figure(101); clf;
for c=1:3
    subplot(1,3,c); hold on
    title(cond_str{c})
    plot(AIC(c,:,2)-AIC(c,:,1),'o')
    
    plot([0 25],[0 0],'k')
    axis([0 25 -20 60])
    ylabel('\Delta AIC')
    xlabel('Subject #')
    
end
dAIC12 = AIC(:,:,2)-AIC(:,:,1);

figure(102); clf; hold on
plot(nanmean(dAIC12'),'o')
plot([1 1; 2 2; 3 3]',[nanmean(dAIC12')+seNaN(dAIC12');nanmean(dAIC12')-seNaN(dAIC12')],'b-')
plot([0 4],[0 0],'k')
xlim([.5 3.5])
ylabel('Average \Delta AIC')
xlabel('condition')

%% plot data and fits
close all;

cond_str = {'minimal','4day','4week'};

cols(:,:,1) = [ 0 210 255; 255 210 0; 0 0 0; 210 0 255]/256;
cols(:,:,2) = [ 0 155 255; 255 100 0; 0 0 0; 155 0 255]/256;
cols(:,:,3) = [0 100 255; 255 0 0; 0 0 0; 100 0 255]/256;


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
            for m=1:3
                subplot(3,3,c+3*(m-1));  hold on;  axis([0 1200 0 1.05]);
                title([cond_str{c},' condition; ',model(m).name,' model'],'fontsize',8);
                plot([1:1200],data(subject,c).sliding_window(4,:),'color',cols(4,:,c),'linewidth',1);
                plot([1:1200],data(subject,c).sliding_window(1,:),'color',cols(1,:,c),'linewidth',1);
                plot([1:1200],data(subject,c).sliding_window(2,:),'color',cols(2,:,c),'linewidth',1);
                
                %plotting model fit data...
                plot([1:1200],data(subject,c).pfit_unchanged,'color',cols(4,:,c),'linewidth',2);
                
                plot([1:1200],model(m).presponse(1,:,c,subject),'color',cols(1,:,c),'linewidth',2)
                plot([1:1200],model(m).presponse(2,:,c,subject),'color',cols(2,:,c),'linewidth',2)
                if(m~=2)
                    plot([1:1200],model(m).presponse(4,:,c,subject),':','color',cols(4,:,c),'linewidth',2)
                end
                
                text(650,.5,['AIC = ',num2str(AIC(c,subject,m))],'fontsize',8);
            end
        end
        set(fhandle, 'Position', [100, 100, 800, 600]);
        set(fhandle, 'Color','w')
    end
    

end

%% generate pdfs
makepdf=1;
if(makepdf)
    for subject=1:24
        figure(subject)
        % save pdf for this participant
        eval(['export_fig data_pdfs/Habit_Subj',num2str(subject),' -pdf']);
    end
    
    % collate all subjs into 1 pdf
    evalstr = ['append_pdfs data_pdfs/AllSubjs.pdf'];
    for i=1:24
        evalstr = [evalstr,' data_pdfs/Habit_Subj',num2str(i),'.pdf'];
    end
    eval(evalstr);
end
