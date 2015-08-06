function age_profile_show_so1(saveFigures, gNo, setNo)
% Show age profiles by cohort: h, study time
% from simulated histories
%{
Checked +++
%}
% --------------------------------------------

cS = const_so1(gNo, setNo);
paramS = var_load_so1(cS.vParams, cS);
prefixStr = 'profile_';

% Stats by [age, school, cohort]
simStatS = var_load_so1(cS.vSimStats, cS);
logHM  = simStatS.meanLogHM;
sTimeM = simStatS.sTimeMedianM;


%% ****  Age 1 study time
% 1 graph
if 1
   fig_new_so(saveFigures);
   hold on;
   for iSchool = 1 : cS.nSchool
      % First 5 years of work
      ageV = cS.demogS.workStartAgeV(iSchool) + (0 : 4);
      lV = mean(squeeze(sTimeM(ageV,iSchool,:)));
      plot(cS.demogS.bYearV, lV,  cS.lineStyleV{iSchool}, 'color', cS.colorM(iSchool,:));
   end
   
   hold off;
   xlabel('Birth year');
   ylabel('Median training time');
   legend(cS.schoolLabelV, 'location', 'southoutside', 'orientation', 'horizontal');
   figure_format_so1(gca);
   save_fig_so1([prefixStr, 'stime_age1'], saveFigures, [], cS);
end



%%  "wage" or efficiency profiles
% h (1-l ./ ell), intercepts and slopes
if saveFigures >= 0
   agePointV = [25, 45];

   
   % *****  Plot intercepts
   fig_new_so(saveFigures, setNo);
   hold on;
   
   for iSchool = 1 : cS.nSchool
      plot(cS.demogS.bYearV,  squeeze(simStatS.meanLogEffM(agePointV(1), iSchool, :)),  ...
         cS.lineStyleV{iSchool}, 'Color', cS.colorM(iSchool, :));
   end
   hold off;
   xlabel('Birth year');
   ylabel(sprintf('Mean log efficiency units at age %i',  agePointV(1)));
   legend(cS.schoolLabelV, 'location', 'best')
   figure_format_so(gca);
   
   save_fig_so1([prefixStr, 'eff_intercept'], saveFigures, [], cS);
   
   
   % ******  Plot slopes
   fig_new_so(saveFigures, setNo);
   hold on;
   
   for iSchool = 1 : cS.nSchool
      plot(cS.demogS.bYearV,  squeeze(simStatS.meanLogEffM(agePointV(2), iSchool, :) - simStatS.meanLogEffM(agePointV(1), iSchool, :)),  ...
         cS.lineStyleV{iSchool}, 'Color', cS.colorM(iSchool, :));
   end
   hold off;
   xlabel('Birth year');
   ylabel(sprintf('Efficiency change, ages %i-%i',  agePointV));
   legend(cS.schoolLabelV, 'location', 'best')
   figure_format_so(gca);
   
   save_fig_so1([prefixStr, 'eff_slope'], saveFigures, [], cS);
   
   
   
   % ******  Plot profiles
   fig_new_so(saveFigures, setNo);
   
   for iSchool = 1 : cS.nSchool
      subplot(2,2,iSchool);
      hold on;
      for ic = 1 : length(cS.demogS.byShowV)
         iCohort = cS.demogS.byShowV(ic);
         
         effV = squeeze(simStatS.meanLogEffM(:, iSchool, iCohort));
         idxV = find(effV ~= cS.missVal);
         plot(idxV,  effV(idxV),  cS.lineStyleDenseV{ic}, 'Color', cS.colorM(ic, :));
      end
      hold off;
      xlabel('Age');
      ylabel('Mean log efficiency');
      if iSchool == cS.nSchool
         legend(cS.demogS.cohStrV(cS.demogS.byShowV), 'Location', 'Southeast');
      end
   end
   save_fig_so1([prefixStr, 'eff_asc'], saveFigures, cS.figOpt4S, cS);
end



%%  study time profiles
% each plot is a school group
if 01
   [~, yMax] = y_range_so1(sTimeM(:), cS.missVal);
   age1 = cS.demogS.workStartAgeV(1);
   age2 = cS.demogS.ageRetire;
   
   for iSchool = 1 : cS.nSchool
      fig_new_so(saveFigures);
   
      hold on;
      for ic = 1 : length(cS.demogS.byShowV)
         iCohort = cS.demogS.byShowV(ic);
         tEndowV = paramS.tEndow_ascM(:, iSchool, iCohort);
         lV = sTimeM(:, iSchool, iCohort);
         idxV = find(lV > 0);
         plot(idxV, lV(idxV) ./ tEndowV(idxV), cS.lineStyleDenseV{ic}, 'Color', cS.colorM(ic,:));
      end
      hold off;      
   
      axis_range_lh([age1, age2, 0, yMax]);
      xlabel('Age');
      ylabel('$l / \ell$', 'interpreter', 'latex');

      if iSchool == 4
         legend(cS.demogS.cohStrV(cS.demogS.byShowV), 'location', 'southwest');
      end

      figure_format_so1(gca);
      figFn = [prefixStr, 'stime_ac_', cS.schoolSuffixV{iSchool}];
      save_fig_so1(figFn, saveFigures, [], cS);
   end
end




%% ****  h profliles: 
% Each plot is a school group
% No point having the same scale b/c h's have different units
% Normalize cohort 1 in each graph to start at 1
if 1
   %[hMin, hMax] = y_range_so1(log_lh(hM(:), cS.missVal), cS.missVal);
   age1 = cS.demogS.workStartAgeV(1);
   age2 = cS.demogS.ageRetire;
   
   for iSchool = 1 : cS.nSchool
      ageV = cS.demogS.workStartAgeV(iSchool) : cS.demogS.ageRetire;
      fig_new_so(saveFigures);
      hold on;
      for ic = 1 : length(cS.demogS.byShowV)
         iCohort = cS.demogS.byShowV(ic);
         
         logHV = logHM(ageV, iSchool, iCohort);
         plot(ageV, logHV - logHV(1), cS.lineStyleDenseV{ic}, 'Color', cS.colorM(ic,:));
      end
      hold off;      
   
      axis_range_lh([age1, age2, NaN, NaN]);
      xlabel('Age');
      ylabel('log h');

      if iSchool == cS.nSchool
         legend(cS.demogS.cohStrV(cS.demogS.byShowV), 'Location', 'South');
      end

      figure_format_so1(gca);
      figFn = [prefixStr, 'h_ac_', cS.schoolSuffixV{iSchool}];
      save_fig_so1(figFn, saveFigures, cS.figOptS, cS);
   end
end



end