% check habit model
clear all
load HabitModelFits
for s=1:24
    for c=1:3
        if(~isempty(data(s,c).RT))
            % estimate time at which guesses decline
            [paramsGuess, SATguess(s,:,c)] = fit_speed_accuracy_AE2(data(s,c).RT,data(s,c).response==3);
            t_unguess(s,c) = paramsGuess(1);
            SATguess(s,:,c) = SATguess(s,:,c)/2;
            % get lower asymptote over first 200 ms
            %pguess = mean(data(s,c).response(data(s,c).RT<.2)==3)/2;
            %t_unguess(s,c) = pguess(1);
            
            %tmin = 200;
            %t_unguess(s,c) = min(find(data(s,c).sliding_window(3,tmin+1:end)<pguess*.75))+tmin;
            %figure(1); clf; hold on
            %plot(data(s,c).sliding_window(3,:));
            %plot([0 200],pguess*[1 1],'k')
            %plot(t_unguess(s,c),data(s,c).sliding_window(3,t_unguess(s,c)),'o')
            %pause

            % estimate time at which responses become correct
            [paramsCorrect SATcorrect(s,:,c)] = fit_speed_accuracy_AE2(data(s,c).RT,data(s,c).response==1);
            t_correct(s,c) = paramsCorrect(1);
            %pause 
            %t_correct(s,c) = min(find(data(s,c).sliding_window(1,tmin+1:end)>.8))+tmin;
            %plot(data(s,c).sliding_window(1,:));
            %plot(t_correct(s,c),data(s,c).sliding_window(1,t_correct(s,c)),'o')
            %pause
            
            % estimate max p(habit)
            max_habit(s,c) = max(data(s,c).sliding_window(2,201:end));
        end
    end
end
            
%%
t_unguess(13,3) = .26; % poor fit for this subject/condition; manual override
t_unguess(14,2) = .45;
t_unguess(t_unguess==0) = NaN;
figure(1); clf; hold on
%figure(33); 
subplot(2,2,1); hold on
plot(1000*t_unguess(:,2),1000*t_correct(:,2),'.','markersize',20)
plot(1000*t_unguess(:,3),1000*t_correct(:,3),'r.','markersize',20)
%plot(t_unguess(Np,:),t_correct(Np,:),'b.')
axis equal
xlabel('unguess time')
ylabel('correct answer time')

subplot(2,2,2); hold on
plot(1000*t_correct(:,2),max_habit(:,2),'.','markersize',20)
plot(1000*t_correct(:,3),max_habit(:,3),'r.','markersize',20)
%plot(t_correct(Np,:),max_habit(Np,:),'b.')
ylabel('max habit')
xlabel('correct answer time')

subplot(2,2,3); hold on
plot(1000*t_unguess(:,2),max_habit(:,2),'.','markersize',20)
plot(1000*t_unguess(:,3),max_habit(:,3),'r.','markersize',20)
%plot(t_unguess(Np,:),max_habit(Np,:),'b.')
xlabel('unguess time')
ylabel('max habit')

subplot(2,2,4); hold on
plot(1000*t_correct(:,2)-1000*t_unguess(:,2),max_habit(:,2),'.','markersize',20)
plot(1000*t_correct(:,3)-1000*t_unguess(:,3),max_habit(:,3),'r.','markersize',20)
plot(1000*t_correct(13,3)-1000*t_unguess(13,3),max_habit(13,3),'ro','markersize',12)
%plot(t_correct(Np,:)-t_unguess(Np,:),max_habit(Np,:),'b.')
xlabel('difference correct answ time - unguess time')
ylabel('max habit')

%% polynomial fit to predict max habit
igood = find(~isnan(t_unguess(:,2)));
X2 = 1000*t_correct(igood,2)-1000*t_unguess(igood,2);
Y2 = max_habit(igood,2);
Xplt = [min(X2) max(X2)];
PP2 = polyfit(X2,Y2,1);
plot(Xplt,PP2(1)*Xplt+PP2(2),'b')

igood = find(~isnan(t_unguess(:,3)));
X3 = 1000*t_correct(igood,3)-1000*t_unguess(igood,3);
Y3 = max_habit(igood,3);
Xplt = [min(X3) max(X3)];
PP3 = polyfit(X3,Y3,1);
plot(Xplt,PP3(1)*Xplt+PP3(2),'r')

%% plot subject-by-subject
% figure colors
cols(:,:,1) = [ 0 210 255; 255 210 0; 210 0 255]/256;
cols(:,:,2) = [ 0 155 255; 255 100 0; 155 0 255]/256;
cols(:,:,3) = [0 100 255; 255 0 0; 100 0 255]/256;
xplt = [0:.01:1.2]*1000;
for s=1:24
    figure(1); clf; hold on
    subplot(2,2,[1 2]); hold on
    plot(1000*t_correct(:,2)-1000*t_unguess(:,2),max_habit(:,2),'.','markersize',20)
    plot(1000*t_correct(:,3)-1000*t_unguess(:,3),max_habit(:,3),'r.','markersize',20)
    if(~isempty(data(s,2).RT))
        plot(1000*t_correct(s,2)-1000*t_unguess(s,2),max_habit(s,2),'bo','markersize',12)
    end
    if(~isempty(data(s,3).RT))
        plot(1000*t_correct(s,3)-1000*t_unguess(s,3),max_habit(s,3),'ro','markersize',12)
    end
    %plot(t_correct(Np,:)-t_unguess(Np,:),max_habit(Np,:),'b.')
    xlabel('difference correct answ time - unguess time')
    ylabel('max habit')
    Xplt = [min(X2) max(X2)];
    plot(Xplt,PP2(1)*Xplt+PP2(2),'b')
    Xplt = [min(X3) max(X3)];
    plot(Xplt,PP3(1)*Xplt+PP3(2),'r')
    
    subplot(2,2,3); hold on
    for i=1:3
        if(~isempty(data(s,2).RT))
            plot(data(s,2).sliding_window(i,:),'color',cols(i,:,2),'linewidth',2)
            % plot reflected SAT
            g0 = .25;%SATguess(s,1,2);
            g_refl = -(data(s,2).sliding_window(3,:)-g0)*(1-g0)/g0 + g0;
            plot(g_refl,'--','color',cols(3,:,2))
        end
    end
    plot(1000*t_unguess(s,2)*[1 1],[0 1],'color',cols(3,:,2))
    plot(1000*t_correct(s,2)*[1 1],[0 1],'color',cols(1,:,2))
    plot(xplt,SATcorrect(s,:,2),'color',cols(1,:,2))
    plot(xplt,SATguess(s,:,2),'color',cols(3,:,2))
    

    
    subplot(2,2,4); hold on
    for i=1:3
        if(~isempty(data(s,3).RT))
            plot(data(s,3).sliding_window(i,:),'color',cols(i,:,3),'linewidth',2)
            % plot reflected SAT
            g0 = .25;%SATguess(s,1,3);
            g_refl = -(data(s,3).sliding_window(3,:)-g0)*(1-g0)/g0 + g0;
            %g_refl = .5-data(s,3).sliding_window(3,:);
            plot(g_refl,'--','color',cols(3,:,3))
        end
    end
    plot(1000*t_unguess(s,3)*[1 1],[0 1],'color',cols(3,:,3))
    plot(1000*t_correct(s,3)*[1 1],[0 1],'color',cols(1,:,3))
    plot(xplt,SATcorrect(s,:,3),'color',cols(1,:,2))
    plot(xplt,SATguess(s,:,3),'color',cols(3,:,2))

    
    disp(['subj ',num2str(s)])
    pause
    
end