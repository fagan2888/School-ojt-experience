function collprem_show_so1(saveFigures, gNo, setNo)
% Show college premium young / old
% How does it come about
%{
Show fixed age values of h, l, efficiency   by year
This is not consistent with the constant composition college premium by age shown elsewhere
%}
% --------------------------------------------------

cS = const_so1(gNo, setNo);
ngAge = size(cS.youngOldAgeM, 1);
yearV = cS.wageYearV(1) : cS.wageYearV(end);

statS = var_load_so1(cS.vSimStats, cS);

% Mean log h by [age, school, year]
%  using adjacent cohorts +++
[meanLogHM] = cohort_to_year_so1(statS.meanLogHM, cS.demogS.bYearV, yearV, cS);

% Mean log efficiency = h (\ell - l) / \ell
[meanLogEffM] = cohort_to_year_so1(statS.meanLogEffM, cS.demogS.bYearV, yearV, cS);

meanLogWageM = cohort_to_year_so1(statS.meanLogWage_ascM, cS.demogS.bYearV, yearV, cS);


%% Plot mean log h, mean log eff
for iPlot = 1 : 4
   if iPlot == 1
      yM = meanLogHM;
      yStr = 'logh';
      yLabelStr = 'Log h';
   elseif iPlot == 2
      yM = meanLogEffM;
      yStr = 'logeff';
      yLabelStr = 'Log efficiency';
   elseif iPlot == 3
      % Training time / time endowment = efficiency / h
      yM = m_oper_lh(meanLogEffM, meanLogHM, '-', cS.missVal, cS.dbg);
      yStr = 'stime';
      yLabelStr = 'Log training time';
   elseif iPlot == 4
      % Mean log wage
      yM = meanLogWageM;
      yStr = 'wage';
      yLabelStr = 'Log wage';
   else
      error('Invalid');
   end
   
   % For young / old
   for iAge = [1, ngAge]
      fig_new_so(saveFigures);
      % Age range to use
      meanAge = round(mean(cS.youngOldAgeM(iAge, 1) : cS.youngOldAgeM(iAge, 2)));
      ageV    = meanAge + (-3 : 3);
      %ageV = cS.youngOldAgeM(iAge, 1) : cS.youngOldAgeM(iAge, 2);

      hold on;
      for iSchool = [cS.schoolHSG, cS.schoolCG]
         logHM = squeeze(yM(ageV, iSchool, :));
         if length(ageV) > 1
            validM = (logHM ~= cS.missVal);
            logHV  = sum(logHM .* validM) ./ max(1, sum(validM));
            idxV   = find(logHV ~= 0);
         else
            logHV = logHM(:);
            idxV  = find(logHV ~= cS.missVal);
         end
         plot(yearV(idxV),  logHV(idxV) - logHV(idxV(1)),  cS.lineStyleDenseV{iSchool}, 'color', cS.colorM(iSchool,:));
      end
      hold off;

      xlabel('Year');
      ylabel(yLabelStr);
      legend(cS.schoolLabelV([cS.schoolHSG, cS.schoolCG]), 'location', 'northwest');
      %axis_range_lh([yearV(1), yearV(end), yMin, yMax]);
      axis_range_lh([yearV(1), yearV(end), NaN, NaN]);
      figure_format_so1(gca);
      save_fig_so1(sprintf('collprem_%s_age%i', yStr, iAge), saveFigures, [], cS);
   end
end


end