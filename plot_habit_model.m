% script to plot model fits
clear all
load HabitModelFits

makepdf = 0; % flag for exporting to pdf. Set to 1 if you want to generate a pdf.

%% plot data and fits
cols(:,:,1) = [ 0 210 255; 255 210 0; 0 0 0; 210 0 255]/256;
cols(:,:,2) = [ 0 155 255; 255 100 0; 0 0 0; 155 0 255]/256;
cols(:,:,3) = [0 100 255; 255 0 0; 0 0 0; 100 0 255]/256;

% open figures and pre-format (I've found this helps when later exporting
% to pdf)
for f=1:24
    fhandle = figure(f); clf; hold on
    set(fhandle, 'Position', [600, 100, 1000, 600]); % set size and loction on screen
    set(fhandle, 'Color','w') % set background color to white
    
    % pre-plot blank data in corner subplots to avoid cropping when exporting to pdf
    subplot(3,4,1);
    plot(0,0,'w.')    
    subplot(3,4,12);
    plot(0,0,'w.')

end

for c = 1:3 % 1=minimal, 2=4day, 3=4week
    for subject = 1:size(data,1)
        if (~isempty(data(subject,c).RT))  %only run on subjects that completed the study
            % plotting raw data...
            figure(subject);
            for m=1:3
                subplot(3,4,m+4*(c-1));  hold on;  axis([0 1200 0 1.05]);
                title([data(subject,c).condition_name,' condition; ',model(m).name,' model'],'fontsize',8);
                plot(0,0,'w.')
                plot([1:1200],data(subject,c).sliding_window(3,:),'color',cols(4,:,c),'linewidth',.5);
                plot([1:1200],data(subject,c).sliding_window(1,:),'color',cols(1,:,c),'linewidth',.5);
                plot([1:1200],data(subject,c).sliding_window(2,:),'color',cols(2,:,c),'linewidth',.5);
                %plot([1:1200],data(subject,c).sliding_window(4,:),'m','linewidth',.5);
                %plotting model fit data...
                %plot([1:1200],data(subject,c).pfit_unchanged,'color',cols(4,:,c),'linewidth',2);
                
                plot([1:1200],model(m).presponse(1,:,c,subject),'color',cols(1,:,c),'linewidth',2)
                plot([1:1200],model(m).presponse(2,:,c,subject),'color',cols(2,:,c),'linewidth',2)
                plot([1:1200],model(m).presponse(3,:,c,subject),'color',cols(4,:,c),'linewidth',2)
                if(m~=2)
                    plot([1:1200],model(m).presponse(4,:,c,subject),':','color',cols(4,:,c),'linewidth',2)
                end
                text(650,.5,['AIC = ',num2str(model(m).AIC(c,subject))],'fontsize',8);
            end
            
            subplot(3,4,4*(c-1)+4); cla; hold on
            plot(model(2).AIC(c,:)-model(1).AIC(c,:),'bo')
            plot(subject,model(2).AIC(c,subject)-model(1).AIC(c,subject),'b.','markersize',20)
            
            plot([0 25],[0 0],'k')
            axis([0 25 -20 70])
            title('\Delta AIC','fontsize',8)
        end

    end
end

%% generate pdfs
%makepdf=1;
if(makepdf)
    for subject=1:24
        figure(subject)
        % save pdf for this participant
        eval(['export_fig data_pdfs/Habit_Subj',num2str(subject),' -pdf']);
    end
    
    % collate all subjs into 1 pdf
    delete data_pdfs/AllSubjs.pdf
    evalstr = ['append_pdfs data_pdfs/AllSubjs.pdf'];
    for i=1:24
        evalstr = [evalstr,' data_pdfs/Habit_Subj',num2str(i),'.pdf'];
    end
    eval(evalstr);
end