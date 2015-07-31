function cohort_profiles_show(saveFigures, gNo)
% Show data wage profiles
%{
Checked: 2013-6-7
%}
% ------------------------------------------

cS = const_so1(gNo, 1);
cS = const_so1(gNo, cS.dataSetNo);
varS = param_so1.var_numbers;
figS = const_fig_so1;

byShowV = cS.byShowV(1 : 5);

% Load cohort profiles
tgS = output_so1.var_load(varS.vCalTargets, cS);
[nAge, nSchool, nBy] = size(tgS.logWage_ascM);

if nSchool ~= cS.nSchool  ||  nBy ~= length(cS.bYearV)
   error_so1('Invalid', cS);
end

% These are the wage profiles to be shown
%  In dollar units
if cS.useMedianWage == 1
%    logWage_ascM = log_lh(loadS.wageMedian_ascM, cS.missVal) + log(cS.wageScale);
%    logWage_ascM(loadS.wageMedian_ascM <= 0) = cS.missVal;
   wStr = 'Log median wage';
else
%    logWage_ascM = loadS.wageMeanLog_ascM + log(cS.wageScale);
%    logWage_ascM(loadS.wageMeanLog_ascM == cS.missVal) = cS.missVal;
   wStr = 'Mean log wage';
end
validateattributes(tgS.logWage_ascM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
   'size', [size(tgS.logWage_ascM, 1), nSchool, nBy]});



%%  Plot wage growth over life-cycle
if 1
   output_so1.fig_new(saveFigures);
   hold on;
   for iSchool = 1 : cS.nSchool
      % Ages over which to compute wage growth
      ageV = cS.wageGrowthAgeV;
      % Mean log wage by [exper, cohort]
      logWageM = squeeze(tgS.logWage_ascM(ageV, iSchool, :));
      % Find cohorts with data
      idxV = find(min(logWageM) > cS.missVal);
      % Wage growth for these cohorts
      wGrowthV = logWageM(2,idxV) - logWageM(1,idxV);
      plot(cS.bYearV(idxV),  wGrowthV,  figS.lineStyleV{iSchool}, 'color', figS.colorM(iSchool,:));
   end
   
   hold off;
   xlabel('Birth year');
   ylabel(sprintf('Wage growth, ages %i-%i',  ageV));
   legend(cS.schoolLabelV, 'location', 'southoutside', 'orientation', 'horizontal');
   output_so1.fig_format(gca, 'line');
   output_so1.fig_save('wage_growth_asc', saveFigures, cS);
end




%%   Plot profiles
% On same scale

% Figure out scale
ageMax = 60;
logWageV = tgS.logWage_ascM(1 : ageMax, : ,byShowV);
logWageV = logWageV(logWageV > cS.missVal);
[yMin, yMax] = output_so1.y_range(logWageV, cS.missVal);
yMin = max(yMin, yMax - 3);
xMin = 15;
xMax = ageMax;
clear logWageV;

for iSchool = 1 : cS.nSchool
   output_so1.fig_new(saveFigures);
   % Line counter
   iLine = 0;
   hold on;

   for iBy = byShowV(:)'
      smoothV = squeeze(tgS.logWage_ascM(:, iSchool, iBy));
      idxV = find(smoothV ~= cS.missVal);
      % Drop ages before assumed work start
      idxV(idxV < cS.workStartAgeV(iSchool)) = [];
      
      if length(idxV) < 2
         error_so1('no data to show', cS);
      end

      iLine = iLine + 1;
      plot(idxV, smoothV(idxV),  figS.lineStyleDenseV{iLine},  'Color', figS.colorM(iLine,:));

      %dataV   = squeeze(loadS.meanLogWageM(iBy, iSchool, :));
      %plot(idxV, dataV(idxV),    '.', 'Color', figS.colorM(iLine,:));
   end
   
   
   hold off;
   xlabel('Age');
   ylabel(wStr);
   figures_lh.axis_range_lh([xMin, xMax, yMin, yMax]);
   if iSchool == cS.schoolCG
      legend(cS.cohStrV(byShowV), 'Location', 'southeast');
   end
      
   % save
   output_so1.fig_format(gca, 'line');
   output_so1.fig_save(['data_profile_', cS.schoolSuffixV{iSchool}],  saveFigures, cS);
end


%%   Table: no of observations
if 1
   fprintf('\n\nNo of wage observations\n\n');
   fprintf('    by cohort / school.   mean / min / max across ages \n');
   
   for iBy = 1 : nBy
      fprintf('\nCohort %i\n',  cS.bYearV(iBy));
      
      for iSchool = 1 : cS.nSchool
         nObsV = squeeze(tgS.nObs_ascM(:, iSchool, iBy));
         idxV = find(nObsV >= cS.minWageObs);
         nObsV = nObsV(idxV);
         fprintf('%6.0f / %6.0f / %6.0f    ',  mean(nObsV), min(nObsV), max(nObsV));
      end
      
      fprintf('\n');
   end
end


end