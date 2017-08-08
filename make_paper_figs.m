% make figures for paper
clear all;
load HabitModelFits

% sample subjects
ex_subj = [9 13 3 4];

% set up figure
fhandle = figure(101); clf; hold on
set(fhandle, 'Position', [600, 100, 700, 300]); % set size and loction on screen
set(fhandle, 'Color','w') % set background color to white

%plotting variables
cols(:,:,1) = [ 0 210 255; 255 210 0; 0 0 0; 210 0 255]/256;
cols(:,:,2) = [ 0 155 255; 255 100 0; 0 0 0; 155 0 255]/256;
cols(:,:,3) = [0 100 255; 255 0 0; 0 0 0; 100 0 255]/256;
t = .001*[1:1200];

% make plots
subplot(2,3,1); hold on
plot(t,data(ex_subj(1),1).sliding_window(1,:),'color',cols(1,:,1),'linewidth',1)
plot(t,data(ex_subj(1),1).sliding_window(2,:),'color',cols(2,:,1),'linewidth',1)
plot(t,model(1).presponse(1,:,1,ex_subj(1)),'color',cols(1,:,1),'linewidth',2)
plot(t,model(1).presponse(2,:,1,ex_subj(1)),'color',cols(2,:,1),'linewidth',2)
axis([0 1.2 0 1])

subplot(2,3,4); hold on
plot(t,data(ex_subj(1),2).sliding_window(1,:),'color',cols(1,:,2),'linewidth',1)
plot(t,data(ex_subj(1),2).sliding_window(2,:),'color',cols(2,:,2),'linewidth',1)
plot(t,model(1).presponse(1,:,2,ex_subj(1)),'color',cols(1,:,2),'linewidth',2)
plot(t,model(1).presponse(2,:,2,ex_subj(1)),'color',cols(2,:,2),'linewidth',2)
plot(t,model(2).presponse(1,:,2,ex_subj(1)),':','color',cols(1,:,2),'linewidth',2)
plot(t,model(2).presponse(2,:,2,ex_subj(1)),':','color',cols(2,:,2),'linewidth',2)
axis([0 1.2 0 1])

subplot(2,3,2); hold on
plot(t,data(ex_subj(2),1).sliding_window(1,:),'color',cols(1,:,1),'linewidth',1)
plot(t,data(ex_subj(2),1).sliding_window(2,:),'color',cols(2,:,1),'linewidth',1)
plot(t,model(1).presponse(1,:,1,ex_subj(2)),'color',cols(1,:,1),'linewidth',2)
plot(t,model(1).presponse(2,:,1,ex_subj(2)),'color',cols(2,:,1),'linewidth',2)
axis([0 1.2 0 1])

subplot(2,3,5); hold on
plot(t,data(ex_subj(2),2).sliding_window(1,:),'color',cols(1,:,2),'linewidth',1)
plot(t,data(ex_subj(2),2).sliding_window(2,:),'color',cols(2,:,2),'linewidth',1)
plot(t,model(2).presponse(1,:,2,ex_subj(2)),'color',cols(1,:,2),'linewidth',2)
plot(t,model(2).presponse(2,:,2,ex_subj(2)),'color',cols(2,:,2),'linewidth',2)
%plot(t,model(2).presponse(1,:,2,ex_subj(2)),':','color',cols(1,:,2),'linewidth',2)
%plot(t,model(2).presponse(2,:,2,ex_subj(2)),':','color',cols(2,:,2),'linewidth',2)
axis([0 1.2 0 1])

% AIC plots
dAIC = model(1).AIC - model(2).AIC;
subplot(2,3,3); cla; hold on

plot(dAIC(1,:),'b.','markersize',12)
plot(ex_subj(1),dAIC(1,ex_subj(1)),'bo')
plot(ex_subj(2),dAIC(1,ex_subj(2)),'ro')
text(ex_subj(1)-.7,dAIC(1,ex_subj(1))+8,'1','fontsize',8)
text(ex_subj(2)-.7,dAIC(1,ex_subj(2))+8,'2','fontsize',8)
plot([0 25],[0 0],'k')
xlim([0 25]) 
ylim([-40 40])

subplot(2,3,6); cla; hold on
plot(dAIC(2,:),'b.','markersize',12)
plot(ex_subj(1),dAIC(2,ex_subj(1)),'bo')
plot(ex_subj(2),dAIC(2,ex_subj(2)),'ro')
text(ex_subj(1)-.7,dAIC(2,ex_subj(1))+8,'1','fontsize',8)
text(ex_subj(2)-.7,dAIC(2,ex_subj(2))+8,'2','fontsize',8)
plot([0 25],[0 0],'k')
xlim([0 25]) 
ylim([-40 40])

%export_fig ModelFits_part2 -eps

%% part II of this figure - illustrating the model
fhandle = figure(102); clf; hold on
set(fhandle, 'Position', [600, 100, 250, 300]); % set size and loction on screen
set(fhandle, 'Color','w') % set background color to white

paramsDemo = [.4 .06 .99 .5 .09 .9 .25 1];
xplot = [0:.01:1.2];

subplot(2,1,1); hold on
plot(xplot,normpdf(xplot,paramsDemo(1),paramsDemo(2)),'r','linewidth',2)
plot(xplot,normpdf(xplot,paramsDemo(4),paramsDemo(5)),'b','linewidth',2)
xlim([0 1.2])
ylim([0 20])

subplot(2,1,2); hold on
presponse = getResponseProbs(xplot,paramsDemo,'habit');
plot(xplot,presponse(2,:),'r','linewidth',2)
plot(xplot,presponse(1,:),'b','linewidth',2)

%export_fig ModelFits_part1 -eps

