function tg_hours_show(saveFigures, gNo)

cS = const_data_so1(gNo);
varS = param_so1.var_numbers;
figS = const_fig_so1;
byShowV = cS.demogS.byShowV(1:5);

tgS = output_so1.var_load(varS.vCalTargets, cS);

xMin = 15;
xMax = cS.demogS.ageRetire;


%% One cohort
% Useful when all cohorts have same hours profiles
if cS.dataS.sameHoursAllCohorts
   iBy = 1;
   output_so1.fig_new(saveFigures);
   
   hold on;
   for iSchool = 1 : cS.nSchool
      hoursV = squeeze(tgS.hours_ascM(:, iSchool, byShowV(iBy)));    %  .* cS.hoursScale;
      idxV = cS.demogS.workStartAgeV(iSchool) : cS.demogS.ageRetire;
      plot(idxV, hoursV(idxV), figS.lineStyleDenseV{iSchool}, 'color', figS.colorM(iSchool,:));
   end
   
   hold off;
   xlabel('Age');
   ylabel('Hours worked');
   legend(cS.schoolLabelV, 'Location', 'South');
   figures_lh.axis_range_lh([xMin, xMax, 0, NaN]);
   output_so1.fig_format(gca, 'line');
   
   figFn = 'cohort_hours';
   output_so1.fig_save(figFn, saveFigures, cS);
   
end


%% All cohorts
for iSchool = 1 : cS.nSchool
   output_so1.fig_new(saveFigures);
   %subplot(2,2,iSchool);
   
   hold on;
   for iBy = 1 : length(byShowV)
      hoursV = squeeze(tgS.hours_ascM(:, iSchool, byShowV(iBy)));    %  .* cS.hoursScale;
      idxV = cS.demogS.workStartAgeV(iSchool) : cS.demogS.ageRetire;
      plot(idxV, hoursV(idxV), figS.lineStyleDenseV{iBy}, 'color', figS.colorM(iBy,:));
   end
   
   hold off;
   xlabel('Age');
   ylabel('Hours worked');
   if iSchool == cS.nSchool
      legend(cS.demogS.cohStrV(byShowV), 'Location', 'South');
   end
   figures_lh.axis_range_lh([xMin, xMax, 0, NaN]);
   output_so1.fig_format(gca, 'line');
   
   figFn = ['cohort_hours_', cS.schoolSuffixV{iSchool}];
   output_so1.fig_save(figFn, saveFigures, cS);
end

end