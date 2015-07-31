function cal_targets_show(saveFigures, gNo)
% Show calibration targets
%{
This repeats graphs from data routines, but it is useful to keep the
typesetting easy
%}
% -----------------------------------------------

cS = const_data_so1(gNo);
varS = param_so1.var_numbers;
figS = const_fig_so1;

tgS = output_so1.var_load(varS.vCalTargets, cS);


%%  Beta IQ by experience
if cS.gS.hasIQ == 1
   output_so1.fig_new(saveFigures);
   plot(tgS.iqExperV, tgS.betaIqExperV, figS.lineStyleV{1}, 'color', figS.colorM(1,:));
   xlabel('Experience');
   ylabel('$\beta_{IQ}$', 'interpreter', 'latex');
   axis_range_lh([NaN, NaN, 0, NaN]);
   output_so1.fig_format(gca);
   output_so1.fig_save('iq_beta_afqt_exper',  saveFigures, [], cS);
end


%% ***********  Taubman Wales graph
if cS.gS.hasIQ == 1
   output_so1.fig_new(saveFigures);
   
   hold on;
   plot(tgS.twIqByV, tgS.twIqPctM(1,:), figS.lineStyleV{1}, 'Color', figS.colorM(1,:));
   plot(tgS.twIqByV, tgS.twIqPctM(2,:), figS.lineStyleV{2}, 'Color', figS.colorM(2,:));
   hold off;
   
   axisV = axis;
   axisV(3) = 0;
   axis(axisV);
   xlabel('Birth year');
   ylabel('Mean IQ percentile score');
   legend({'College', 'No college'},  'Location', 'South');

   output_so1.fig_format(gca);
   figFn = 'iq_taubman_wales';
   output_so1.fig_save(figFn, saveFigures, cS);
   %return;
end



%% Mean wage profiles by [a,s,t]
if 01
   yearV = cS.wageYearV(1 : 2 : 10);
   legendV = arrayfun(@(x) {sprintf('%d', x)}, yearV);
  
   for iSchool = 1 : cS.nSchool
      ageV = cS.workStartAgeV(iSchool) : cS.ageRetire;
      output_so1.fig_new(saveFigures);
      hold on;
      
      for iLine = 1 : length(yearV)
         dataV = tgS.logWage_astM(ageV, iSchool, yearV(iLine)-cS.wageYearV(1)+1);
         idxV = find(dataV ~= cS.missVal);
         plot(ageV(idxV),  dataV(idxV),  figS.lineStyleDenseV{iLine}, 'color', figS.colorM(iLine,:));         
      end
      
      hold off;
   
      xlabel('Age');
      ylabel('Log wage');
      legend(legendV)
      output_so1.fig_format(gca, 'line');
      output_so1.fig_save(['wage_log_ast_', cS.schoolSuffixV{iSchool}], saveFigures, cS);
   end
end



%% Steady state log median wage profiles
if 0
   % Initial and terminal steady state
   for iy = 1 : 2
      
      output_so1.fig_new(saveFigures);
      hold on;
      
      for iSchool = 1 : cS.nSchool
         % Ages over which to compare model with data
         xV = max(cS.workStartAgeV(iSchool), cS.ageRangeV(1)) : cS.ageRangeV(2);
         yV = tgS.ssS.logWage_astM(xV,iSchool,iy);
         idxV = find(yV ~= cS.missVal);
         plot(xV(idxV), yV(idxV), figS.lineStyleDenseV{iSchool}, 'color', figS.colorM(iSchool,:));
      end
      
      hold off;
      xlabel('Age');
      ylabel('Log wage');
      output_so1.fig_format(gca);
      output_so1.fig_save(sprintf('ss%i_wages', iy), saveFigures, cS);
   end
end



%%  Cohort wage and hours profiles
% Each sub-plot is a cohort
if 1
   figRows = 3;
   figCols = 2;
   byShowV = cS.byShowV;
   nc = length(byShowV);

   for iPlot = 1 : 2
      if iPlot == 1
         % Mean log wage
         yLabelStr = cS.wageStr;
         figFn = 'tg_wages';
         ageRangeV = [min(cS.workStartAgeV), cS.ageRetire];
         wageM = tgS.logWage_ascM;
         [yMin, yMax] = output_so1.y_range(wageM(:), cS.missVal);
      elseif iPlot == 2
         yLabelStr = 'Mean hours worked';
         figFn = 'tg_hours';
         ageRangeV = [min(cS.workStartAgeV), cS.ageRetire];
         wageM = tgS.hours_ascM;
         [yMin, yMax] = output_so1.y_range(wageM(:), cS.missVal);
         
      else
         error('Invalid ');
      end
      
      output_so1.fig_new(saveFigures, figS.figOpt6S);
   
      % Each suplot is a cohort; shows all school groups
      for i1 = 1 : min(figRows * figCols, nc)
         subplot(figRows,figCols,i1);
         ic = byShowV(i1);
         hold on;
         for iSchool = 1 : cS.nSchool
            wageV = wageM(:, iSchool, ic);
            wageV(1 : (cS.workStartAgeV(iSchool))) = cS.missVal;
            idxV = find(wageV ~= cS.missVal);
            plot(idxV, wageV(idxV), figS.lineStyleDenseV{iSchool}, 'Color', figS.colorM(iSchool, :));
         end

         hold off;
         axis([ageRangeV(1), ageRangeV(2), yMin, yMax]);
         xlabel(['Age  -  cohort ', cS.cohStrV{ic}]);
         ylabel(yLabelStr);
         if i1 == 1
            legend(cS.schoolLabelV, 'Location', 'South');
         end
         output_so1.fig_format(gca);
      end

      output_so1.fig_save(figFn, saveFigures, cS);
   end
end




end