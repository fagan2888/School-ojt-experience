function betaiq_age_so1(saveFigures, gNo, setNo)
% Show how betaIQ varies with experience
%{
For one cohort. Model and data
%}
% ---------------------------------------------------

cS = const_so1(gNo, setNo);
expRangeV = 1 : 30;
nx = length(expRangeV);
% Show the NLSY cohort
[~, iCohort] = min(abs(cS.demogS.bYearV - 1960));

simS = var_load_so1(cS.vSimResults, cS);
tgS  = var_load_so1(cS.vCalTargets, [], gNo, cS.dataSetNo);
calS = var_load_so1(cS.vCalResults, cS);
betaIqExperV = calS.calDevS.betaIqExperV;
clear calS;


%% Construct stats

betaIQV = zeros([nx, 1]);
betaAbilV = zeros([nx, 1]);
% Correlation log wage, IQ
corrM = zeros([nx, cS.nSchool]);
% Correlation log wage, ability
corrAbilM = zeros([nx, cS.nSchool]);

pSchoolM = simS.pSchoolM(:, :, iCohort);
for ix = 1 : nx
   % Log wage by [ind, school]
   logWageM = zeros([cS.nSim, cS.nSchool]);
   for iSchool = 1 : cS.nSchool
      age = cS.demogS.workStartAgeV(iSchool) + ix - 1;
      logWageM(:,iSchool) = squeeze(log(simS.wageM(:, age, iSchool, iCohort)));
   end
  
   % how does this differ from the one used in cal_dev? +++
   betaIQV(ix) = betaiq_so1(logWageM, pSchoolM, simS.iqM(:,iCohort), cS);
   
   % Regress log wage on ability
   betaAbilV(ix) = betaiq_so1(logWageM, pSchoolM, simS.abilM(:,iCohort), cS);
   
   % Correlations
   for iSchool = 1 : cS.nSchool
      [~, corrM(ix, iSchool)]     = cov_w(logWageM(:, iSchool), simS.iqM(:,iCohort),   pSchoolM(:, iSchool), cS.missVal, cS.dbg);
      [~, corrAbilM(ix, iSchool)] = cov_w(logWageM(:, iSchool), simS.abilM(:,iCohort), pSchoolM(:, iSchool), cS.missVal, cS.dbg);
   end
end


%% Plot  Beta IQ by experience
if 1
   legendV = cell([3,1]);
   fig_new_so(saveFigures);
   hold on;
   iLine = 1;

   legendV{iLine} = 'Model';
   plot(tgS.iqExperV, betaIqExperV,  cS.lineStyleDenseV{iLine}, 'color', cS.colorM(iLine,:));
   
   if 0
      iLine = iLine + 1;
      legendV{iLine} = 'Model CS';
      plot(expRangeV, betaIQV(expRangeV),  cS.lineStyleDenseV{iLine}, 'color', cS.colorM(iLine,:));
   end
   iLine = iLine + 1;
   legendV{iLine} = 'Data';
   plot(tgS.iqExperV, tgS.betaIqExperV, cS.lineStyleDenseV{iLine}, 'color', cS.colorM(iLine,:));

   hold off;
   xlabel('Experience');
   ylabel('$\beta_{IQ}$', 'interpreter', 'latex');
   axis_range_lh([NaN, NaN, 0, NaN]);
   legend(legendV(1 : iLine), 'location', 'south', 'orientation', 'horizontal');
   figure_format_so1(gca);
   save_fig_so1('iq_wage_beta',  saveFigures, [], cS);
end



%% Beta ability

fig_new_so(saveFigures);
plot(expRangeV, betaAbilV(expRangeV), cS.lineStyleDenseV{1}, 'color', cS.colorM(1,:));
xlabel('Experience');
ylabel('beta ability');
axis_range_lh([NaN, NaN, 0, NaN]);
figure_format_so1(gca);
save_fig_so1('abil_wage_beta',  saveFigures, [], cS);


%% Correlation log wage / iq

fig_new_so(saveFigures);
hold on;
for iSchool = 1 : cS.nSchool
   plot(expRangeV, corrM(expRangeV, iSchool), cS.lineStyleDenseV{iSchool}, 'color', cS.colorM(iSchool,:));
end
hold off;
xlabel('Experience');
ylabel('Corr log wage / IQ');
axis_range_lh([NaN, NaN, 0, 1]);
legend(cS.schoolLabelV, 'location', 'south', 'orientation', 'horizontal');
figure_format_so1(gca);
save_fig_so1('iq_wage_corr',  saveFigures, [], cS);


% Correlation log wage / ability
fig_new_so(saveFigures);
hold on;
for iSchool = 1 : cS.nSchool
   plot(expRangeV, corrAbilM(expRangeV, iSchool), cS.lineStyleDenseV{iSchool}, 'color', cS.colorM(iSchool,:));
end
hold off;
xlabel('Experience');
ylabel('Corr log wage / ability');
axis_range_lh([NaN, NaN, 0, 1]);
legend(cS.schoolLabelV, 'location', 'south', 'orientation', 'horizontal');
figure_format_so1(gca);
save_fig_so1('abil_wage_corr',  saveFigures, [], cS);


end