function fit_by_school(model_ascM, data_ascM, saveFigures, cS)
% How well does model fit the data
% One plot per school group

dirS = param_so1.directories(cS.gNo, cS.setNo);
figS = const_fig_so1;

% Cohorts to show
nr = 3;
nc = 3;
byShowV = helper_so1.by_show(cS.nCohorts, nr*nc);

for iSchool = 1 : cS.nSchool
   yMin = 0;   yMax = 0;
   ageRangeV = max(cS.demogS.workStartAgeV(iSchool), cS.ageRangeV(1)) : cS.ageRangeV(2);   

   output_so1.fig_new(saveFigures, figS.figOpt6S);

   % Plot all school groups; data and model
   fhV = zeros([length(byShowV), 1]);
   for ic = 1 : length(byShowV)
      fhV(ic) = subplot(nr, nc, ic);
      hold on;
      iCohort = byShowV(ic);

      dataWageV = data_ascM(ageRangeV, iSchool, iCohort);         
      idxV = find(dataWageV > -10);
      %meanDataWage = mean(dataWageV(idxV));
      plot(ageRangeV(idxV), dataWageV(idxV),  figS.lineStyleDenseV{1}, 'Color', figS.colorM(1,:));

      % Model: show all ages
      modelWageV = model_ascM(ageRangeV, iSchool, iCohort);
      %idxV = find(modelWageV > -10);
      plot(ageRangeV, modelWageV, figS.lineStyleDenseV{2}, 'Color', figS.colorM(2,:));

      % Also show wage profile for person with median h1/a
      % To see whether representative agent model has a shot
      if 0
         if ic == 1
            simS = var_load_so1(cS.vSimResults, cS);
         end
         a_h1V = simS.abilM(:, iCohort) ./ simS.h1M(:, iCohort);
         % Find median person
         a_h1_median = median(a_h1V);
         [~, mIdx] = min(abs(a_h1V - a_h1_median));
         logWageV = log(simS.wageM(mIdx, ageRangeV, iSchool, iCohort));

         iLine = 3;
         plot(ageRangeV(idxV),  logWageV(idxV) - dataWageV(idxV(1)), figS.lineStyleDenseV{iLine}, ...
            'Color', figS.colorM(iLine,:));
      end

      hold off;

      % Record axis ranges, so we can set common range below
      axisV = axis;
      yMin = min(yMin, axisV(3));
      yMax = max(yMax, axisV(4));
      %axis_range_lh([ageRangeV(1), ageRangeV(end), yMin, yMax]);

      xlabel(['Age, ', cS.demogS.cohStrV{iCohort}, ' cohort']);
      % Show y label only for 1st column
      if rem(ic, nr) == 1
         ylabel(cS.wageStr);
      end
      if 0
         legend({['D: ', cS.demogS.cohStrV{iCohort}], 'M'}, 'location', 'best', 'orientation', 'horizontal');
      end

   end

   % Format
   for ic = 1 : length(byShowV)
      % Set common axis range
      axis(fhV(ic), [ageRangeV(1), ageRangeV(end),  yMin, yMax]);
      % Format plot
      output_so1.fig_format(fhV(ic));
   end

   figFn = ['wage_ac_', cS.schoolSuffixV{iSchool}];
   output_so1.fig_save(fullfile(dirS.fitDir, figFn), saveFigures, cS);
end

end
