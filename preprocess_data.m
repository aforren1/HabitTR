% load in raw data and pre-process in format suitable for fitting the model
clear all
cond_str = {'minimal','4day','4week'};

load tmp;
clear data

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
            p.(['condition' num2str(c)]).unchanged(subject,:) = paramsU;
            
            params = fit_speed_accuracy_AE2(revisedX,revisedY);
            p2 = params(4)+(params(3)-params(4))*normcdf([(1:1200)/1000],params(1),params(2));
            p.(['condition' num2str(c)]).revised(subject,:) = params;
            
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
            
            data(subject,c).RT = recodedX;
            data(subject,c).response = recodedY;
            data(subject,c).sliding_window(1,:) = revised;
            data(subject,c).sliding_window(2,:) = habit;
            data(subject,c).sliding_window(3,:) = (1-revised-habit)/2; % probability of "other" response
            data(subject,c).sliding_window(4,:) = unchanged;
            data(subject,c).condition_name = cond_str{c};
        
        % weed out bad subjects
        % need to have accuracy >=70% for RT>800ms
        data(subject,c).asympt_err = mean(data(subject,c).response(data(subject,c).RT>.8)==1);
        if(data(subject,c).asympt_err<.7)
            % for now, delete RT as this is current proxy for excluded
            % subjects
            data(subject,c).RT = [];
        end
        end
    end
end
%%
% load Free RT data
load data

% condition 2
% hack to insert NaNs for missing subjects
ss = [1:5 7:15 17:24];
for s=1:22
    data(ss(s),2).trainingRT = d.e1.group.training.RT(s,:)';
end
data(6,2).trainingRT = NaN*ones(1,40)';
data(16,2).trainingRT = NaN*ones(1,40)';

% condition 3
ss = [1:7 9:15];
for s=1:14
    data(ss(s),3).trainingRT = d.e2.group.training.RT(s,:)';
end
data(8,3).trainingRT = NaN*ones(size(data(1,3).trainingRT));

save HabitData data