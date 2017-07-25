% skill vs habit comparison
% condition 2

clear all
load HabitModelFits

figure(1); clf; hold


%{
skill = p.condition2.unchanged(:,1);
ibad = find(skill==0)
skill(ibad)=NaN;

habit = dAIC12(2,:)'>0;

i_habitual = find(habit==1);
skill_habit = skill(i_habitual);

i_nothabitual = find(habit==0);
skill_nohabit = skill(i_nothabitual);

figure(41); clf; hold on
plot(habit,skill,'o')

plot([0 1],[nanmean(skill_nohabit) nanmean(skill_habit)],'linewidth',2)
axis([-.5 1.5 0 .7])
text(-.25, .6, 'non-habitual participants','fontsize',8)
text(.75, .6, 'habitual participants','fontsize',10)
ylabel('skill level (ms)')

%export_fig habit_vs_skill.png
[t_skill p_skill] = ttest(skill_habit,skill_nohabit,1,'independent')
%}
%% 