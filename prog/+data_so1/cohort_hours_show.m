function cohort_hours_show(saveFigures, gNo)
% Plot cohort hours profiles
% -----------------------------------

cS = const_data_so1(gNo);
varS = param_so1.var_numbers;
figS = const_fig_so1;

% Load hours profiles (in model units)
loadS = output_so1.var_load(varS.vCohortHours, cS);

% Show these cohorts
byShowV = cS.demogS.byShowV(1:5);

if cS.wagePeriod == cS.hourlyWages
   yMin = 1600;
   yMax = 2500;
elseif cS.wagePeriod == cS.weeklyWages
   yMin = 0;
   yMax = 55;
else
   error('Invalid');
end

xMin = 15;
xMax = 65;




%% *********  Actual profiles
if 1
   output_so1.fig_new(saveFigures, figS.figOpt4S);
   for iSchool = 1 : cS.nSchool
      subplot(2,2,iSchool);

      hold on;
      for iBy = 1 : length(byShowV)
         hoursV = squeeze(loadS.hoursRaw_ascM(:, iSchool, byShowV(iBy))) .* cS.hoursScale;
         idxV = find(hoursV > 0);
         yV = hpfilter(hoursV(idxV), cS.hpFilterHours);
         plot(idxV, yV, figS.lineStyleDenseV{iBy}, 'color', figS.colorM(iBy,:));
      end

      hold off;
      xlabel('Age');
      ylabel('Hours');
      if iSchool == cS.nSchool
         legend(cS.demogS.cohStrV(byShowV), 'Location', 'South');
      end
      figures_lh.axis_range_lh([cS.demogS.workStartAgeV(1), cS.demogS.ageRetire, yMin, yMax]);
      output_so1.fig_format(gca, 'line');
   end

   figFn = 'cohort_hours_raw';
   output_so1.fig_save(figFn, saveFigures, cS);
end   


%% ***********  Quartic profiles
if 1
   output_so1.fig_new(saveFigures, figS.figOpt4S);
   
   hold on;
   for iSchool = 1 : cS.nSchool
      hoursV = loadS.hoursFit_asM(:, iSchool) .* cS.hoursScale;
      hoursV = hoursV(:);
      idxV = find(hoursV > 0);
      plot(idxV, hoursV(idxV), figS.lineStyleDenseV{iSchool}, 'color', figS.colorM(iSchool,:));
   end
   hold off;
   
   xlabel('Age');
   ylabel('Hours');
   legend(cS.schoolLabelV, 'Location', 'South', 'orientation', 'horizontal');
   figures_lh.axis_range_lh([xMin, xMax, yMin, yMax]);
   output_so1.fig_format(gca, 'line');

   figFn = 'cohort_hours_fitted';
   output_so1.fig_save(figFn, saveFigures, cS);
   
end



end