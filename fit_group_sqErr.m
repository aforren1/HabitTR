%%
    clear all
    load group_tmp
    
    constrained = 1; % 1 = constrained fit (4 params per condition); 0 = unconstrained (7 params per condition)
    
% plot group data
figure(100); clf; hold on
for c=1:3
    figure(100);
    subplot(1,3,c); hold on
    shadedErrorBar([1:1200],nanmean(unchanged_all(:,:,c)),seNaN(unchanged_all(:,:,c)),'-c',1)
    shadedErrorBar([1:1200],nanmean(revised_all(:,:,c)),seNaN(revised_all(:,:,c)),'-b',1)
    shadedErrorBar([1:1200],nanmean(habit_all(:,:,c)),seNaN(habit_all(:,:,c)),'-r',1)
    
    
    % model fits
    paramsU = fit_speed_accuracy_AE2(unchangedX_all{c},unchangedY_all{c});
    %paramsU = [
    p1 = paramsU(4)+(paramsU(3)-paramsU(4))*normcdf([(1:1200)/1000],paramsU(1),paramsU(2));
    p.(['condition' num2str(c)]).unchanged = [p.(['condition' num2str(c)]).unchanged; paramsU];
    
    params = fit_speed_accuracy_AE2(revisedX_all{c},revisedY_all{c});
    p2 = params(4)+(params(3)-params(4))*normcdf([(1:1200)/1000],params(1),params(2));
    phabit = params(4)-((1-params(4))/3)*normcdf([(1:1200)/1000],paramsU(1),paramsU(2));
    p.(['condition' num2str(c)]).revised = [p.(['condition' num2str(c)]).revised; params];
    
    % revise errors to 3, not 0 (for indexing)
    i0 = find(recodedY_all{c}==0);
    recodedY_all{c}(i0) = 3;
    
    % get rid of any trials that had unchanged x - fitting to
    % changed symbols only
    revised_trials = ismember(recodedX_all{c},revisedX_all{c});
    recodedX_all{c} = recodedX_all{c}(revised_trials);
    recodedY_all{c} = recodedY_all{c}(revised_trials);
    
    % initialize parameters
    paramsA = paramsU;
    paramsB = paramsU;
    
    params_unchanged(c,:) = paramsU;
    
    % transform asymptote paramters to keep true parameters within [0,1];
    sigg = @(xx) (1/(1+exp(-xx))); % sigmoidal transformation [-inf,inf] -> [-1,1]
    sigg_inv = @(yy) -log(1./yy - 1); % inverse sigmoidal transformation [-1,1] -> [-inf,inf]
    paramsA(3) = sigg_inv(paramsA(3));
    paramsB(3) = sigg_inv(paramsB(3));
    
    habit_lik_constr = @(params) habit_lik(recodedX_all{c},recodedY_all{c},params(1:7), ); % constrained function
    % find optimal parameters
    paramsInit = [paramsA(1:3) paramsB(1:3) sigg_inv(paramsA(4))];
    paramsOpt(c,:) = fminsearch(habit_lik_constr,paramsInit);
    paramsAOpt = paramsOpt(c,1:3);
    paramsBOpt = paramsOpt(c,4:6);
    paramsBOpt(3) = sigg(paramsBOpt(3));
    paramsAOpt(3) = sigg(paramsAOpt(3));
    % plot model predictions
    xplot=[.001:.001:1.2];
    presponse = getResponseProbs(xplot,paramsAOpt,paramsBOpt,sigg(paramsOpt(c,7)));
    
    % optimize based on least squares
    %presponse_model = @(params) getResponseProbs(xplot,params(1:3),params(4:6),params(7));
    presponse_data = [nanmean(revised_all(:,:,c));nanmean(habit_all(:,:,c))]; % NB - last row (incorrects) is zeros - we don't care about that
    %e2 = @(params) sum(sum((presponse_data-presponse_model(params)).^2));
    

    %set up fitting function
    if(~constrained)
        % ordinary fit - 7 free params
        get_e2 = @(params) getResponseProb_e2(xplot,presponse_data,params);
        
        % optimize
        paramsOpt_e2(c,:) = fminsearch(get_e2,paramsInit);
        
        % tidy up parameters
        paramsAOpt_e2(c,:) = paramsOpt_e2(c,1:3);
        paramsBOpt_e2(c,:) = paramsOpt_e2(c,4:6);
        paramsAOpt_e2(c,3) = sigg(paramsAOpt_e2(c,3));
        paramsBOpt_e2(c,3) = sigg(paramsBOpt_e2(c,3));
        
        params_unconstrained(c,:) = [paramsAOpt_e2(c,:) paramsBOpt_e2(c,:) sigg(paramsOpt_e2(c,7))];
    else
        disp('fixed A')
        % constrained fit - fix A to equal unchanged responses
        get_e2 = @(params) getResponseProb_e2(xplot,presponse_data,[params_unchanged(c,1:3) params]);
    
        % optimize
        paramsOpt_e2B(c,:) = fminsearch(get_e2,paramsInit);
        
        % tidy up parameters
        paramsOpt_e2(c,:) = [params_unchanged(c,1:3) paramsOpt_e2B(c,:)];
        paramsAOpt_e2(c,:) = params_unchanged(c,1:3);
        paramsBOpt_e2(c,:) = paramsOpt_e2B(c,1:3);
        %paramsAOpt_e2(c,3) = sigg(paramsAOpt_e2(c,3));
        paramsBOpt_e2(c,3) = sigg(paramsBOpt_e2(c,3));
        
        params_constrained(c,:) = [params_unchanged(c,1:2) sigg(params_unchanged(c,3)) paramsBOpt_e2(c,:) sigg(paramsOpt_e2(c,7))];
    %{
    else
        disp('fixed B')
        % constrained fit - fix A to equal unchanged responses
        get_e2 = @(params) getResponseProb_e2(xplot,presponse_data,[params(1:3) params_unchanged(c,1:3) params(4)]);
    
        % optimize
        paramsOpt_e2A(c,:) = fminsearch(get_e2,paramsInit);
        
        % tidy up parameters
        paramsOpt_e2(c,:) = [params_unchanged(c,1:3) paramsOpt_e2A(c,:)];
        paramsBOpt_e2(c,:) = params_unchanged(c,1:3);
        paramsAOpt_e2(c,:) = paramsOpt_e2A(c,1:3);
        %paramsAOpt_e2(c,3) = sigg(paramsAOpt_e2(c,3));
        paramsBOpt_e2(c,3) = sigg(paramsBOpt_e2(c,3));
        
        params_constrained2(c,:) = [paramsAOpt_e2(c,:) params_unchanged(c,1:2) sigg(params_unchanged(c,3)) sigg(paramsOpt_e2(c,7))];
        %}
    end
        
    xplot=[.001:.001:1.2];
    
    %paramsAOpt_e2(2,3) = .95;
    presponse_e2 = getResponseProbs(xplot,paramsAOpt_e2(c,:),paramsBOpt_e2(c,:),sigg(paramsOpt_e2(c,7)));
    

    
    
    
    
    %plotting raw data...
    %figure(subject); subplot(2,2,c);  hold on;  axis([0 1200 0 1.05]);
    %plot([1:1200],unchanged,'--c','linewidth',1);
    %plot([1:1200],revise.d,'--b','linewidth',1);
    %plot([1:1200],habit,'--r','linewidth',1);
    %plotting model fit data...
    %plot([1:1200],p2,'b','linewidth',2);
    plot([1:1200],p1,'c','linewidth',2);
    plot([1:1200],phabit,'r','linewidth',2)
    
    %plot([1:1200],presponse(1,:),'b','linewidth',2)
    %plot([1:1200],presponse(2,:),'r','linewidth',2)
    %plot([1:1200],presponse(4,:),'r:','linewidth',2)
    
    plot([1:1200],presponse_e2(1,:),'b','linewidth',2)
    plot([1:1200],presponse_e2(2,:),'r','linewidth',2)
    plot([1:1200],presponse_e2(4,:),'r:','linewidth',2)
    plot([1:1200],presponse_e2(5,:),'b:','linewidth',2)
    %keyboard
    
    if(c==2)
        fig1 = figure(101); clf; hold on

        fig1.Renderer = 'Painters';
        
        subplot(3,3,1)
        plot(xplot,normpdf(xplot,paramsAOpt_e2(c,1),paramsAOpt_e2(c,2)),'r')
        axis([0 1 0 6])
        
        subplot(3,3,[4 7])
        plot(xplot,presponse_e2(4,:),'r')
        axis([0 1 0 1])  
        
        subplot(3,3,2);
        plot(xplot,normpdf(xplot,paramsBOpt_e2(c,1),paramsBOpt_e2(c,2)),'b')
        axis([0 1 0 6])
        
        subplot(3,3,[5 8]);
        plot(xplot,presponse_e2(5,:),'b')
        axis([0 1 0 1])
        
        subplot(3,3,3); hold on
        plot(xplot,normpdf(xplot,paramsAOpt_e2(c,1),paramsAOpt_e2(c,2)),'r')
        plot(xplot,normpdf(xplot,paramsBOpt_e2(c,1),paramsBOpt_e2(c,2)),'b')
        axis([0 1 0 6])
        
        subplot(3,3,[6 9]); hold on
        plot(xplot,presponse_e2(1,:),'b')
        plot(xplot,presponse_e2(2,:),'r')
        axis([0 1 0 1])
    end
    
    
end
