function fit_by_cohort(model_ascM, data_ascM, saveFigures, cS)
%  Age wage profiles: data vs model
% Each figure contains 8 cohorts. One subplot per cohort with all s.

dirS = param_so1.directories(cS.gNo, cS.setNo);
figS = const_fig_so1;

[yMin, yMax] = output_so1.y_range(model_ascM, cS.missVal);

% Subplot counter
maxPlot = 6;
iPlot = 0;
% Plot counter
iFig = 0;
iCohortV = 2 : 3 : cS.nCohorts;

for iCohort = iCohortV
   if iPlot == 0
      output_so1.fig_new(saveFigures, figS.figOpt6S);
   end
   iPlot = iPlot + 1;
   subplot(3,2,iPlot);
   hold on;

   % Plot all school groups; data and model
   for iSchool = 1 : cS.nSchool
      ageRangeV = max(cS.demogS.workStartAgeV(iSchool), cS.ageRangeV(1)) : cS.ageRangeV(2);   

      modelWageV = model_ascM(ageRangeV, iSchool, iCohort);
      idxV = find(modelWageV > -10);
      plot(ageRangeV(idxV), modelWageV(idxV), figS.lineStyleDenseV{1}, 'Color', figS.colorM(iSchool,:));

      dataWageV  = data_ascM(ageRangeV, iSchool, iCohort);
      idxV = find(dataWageV > -10);
      plot(ageRangeV(idxV), dataWageV(idxV),  figS.lineStyleDenseV{2}, 'Color', figS.colorM(iSchool,:));
   end

   hold off;
   figures_lh.axis_range_lh([cS.ageRangeV(1), ageRangeV(end), yMin, yMax]);

   xlabel(['Age  --  Cohort ', cS.demogS.cohStrV{iCohort}]);
   ylabel('Log wage');

   %if iPlot == 1
   %   legend({'Data', 'Model'}, 'Location', 'Northwest');
   %end
   output_so1.fig_format(gca);

   % Close and save plot
   if iPlot == maxPlot  ||  iCohort == iCohortV(end)
      iFig = iFig + 1;
      figFn = fullfile(dirS.fitDir, ['wage_as_', sprintf('c%i', iFig)]);
      output_so1.fig_save(figFn, saveFigures, cS);
      iPlot = 0;
   end
end

end