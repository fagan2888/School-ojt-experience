function sim_show_so1(saveFigures, gNo, setNo)
% Show simulation results
%{
By cohort
   endowments
      by school: ability, h1

Checked: 2014-apr-4
%}
% ----------------------------------------------

cS = const_so1(gNo, setNo);

% Load sim results
paramS = var_load_so1(cS.vParams, cS);
paramS = param_derived_so1(0, paramS, cS);
simS   = var_load_so1(cS.vSimResults, cS);
simStatS = var_load_so1(cS.vSimStats, cS);

[calS, ~, version1] = var_load_so1(cS.vCalResults, cS);
outS = calS.calDevS;

% Effective abilities
abilM = simS.abilM .* paramS.abilScale;



%% Endowment correlations
if 1
   fprintf('\nEndowment correlations\n');
   for i1 = 1 : length(cS.byShow4V)
      ic = cS.byShow4V(i1);
      corrM = corr([simS.abilM(:,ic), log(simS.h1M(:,ic)), simS.iqM(:,ic)]);
      fprintf('Cohort %i:  (a,h1): %4.2f    (a,iq): %4.2f    (h1,iq): %4.2f \n', ...
         cS.demogS.bYearV(ic), corrM(1,2), corrM(1,3), corrM(2,3));
   end
end


%% IQ, ability
if cS.hasIQ == 1
   fig_new_so(saveFigures);

   for i1 = 1 : length(cS.byShow4V)
      subplot(2,2,i1);
      ic = cS.byShow4V(i1);
      
      plot(abilM(:,ic), simS.iqM(:,ic), '.', 'color', cS.colorM(1,:));
      xlabel(['Effective ability, ', cS.demogS.cohStrV{ic}]);
      ylabel('IQ');
      figure_format_so(gca, setNo);
   end
   save_fig_so('endow_abil_iq', saveFigures, cS.figOpt4S, cS);
end


%% IQ, h1
if cS.hasIQ == 1
   fig_new_so(saveFigures);

   for i1 = 1 : length(cS.byShow4V)
      subplot(2,2,i1);
      ic = cS.byShow4V(i1);
      
      plot(log(simS.h1M(:,ic)), simS.iqM(:,ic), '.', 'color', cS.colorM(1,:));
      xlabel(['Log h1, ', cS.demogS.cohStrV{ic}]);
      ylabel('IQ');
      figure_format_so(gca, setNo);
   end
   save_fig_so('endow_h1_iq', saveFigures, cS.figOpt4S, cS);
end



%%  Plot a, h1 
if 1
   fig_new_so(saveFigures);

   for i1 = 1 : length(cS.byShow4V)
      subplot(2,2,i1);
      ic = cS.byShow4V(i1);
      
      plot(abilM(:,ic), log(simS.h1M(:,ic)), '.', 'color', cS.colorM(1,:));
      xlabel(['Effective ability, ', cS.demogS.cohStrV{ic}]);
      ylabel('log h1');
      figure_format_so(gca, setNo);
   end
   save_fig_so('endow_abil_h1', saveFigures, cS.figOpt4S, cS);
end


%%  How does school prob vary with a, h1?
if 1
   fig_new_so(saveFigures);   
   for i1 = 1 : length(cS.byShow4V)
      subplot(2,2,i1);
      ic = cS.byShow4V(i1);
      pCollegeV = sum(simS.pSchoolM(:, cS.schoolCD : cS.schoolCG, ic), 2);
      plot(abilM(:,ic), pCollegeV, '.', 'color', cS.colorM(1,:));
      xlabel(['Effective ability, ', cS.demogS.cohStrV{ic}]);
      ylabel('Prob college');
      axis_range_lh([NaN, NaN, 0, 1]);
      figure_format_so(gca, setNo);
   end
   save_fig_so('endow_abil_prob_college', saveFigures, cS.figOpt4S, cS);
   
   
   % h1
   % Determine x axis range
   [xMin, xMax] = y_range_so1(log(simS.h1M), cS.missVal);
   fig_new_so(saveFigures);
   for i1 = 1 : length(cS.byShow4V)
      ic = cS.byShow4V(i1);
      subplot(2,2,i1);
      pCollegeV = sum(simS.pSchoolM(:, cS.schoolCD : cS.schoolCG, ic), 2);
      plot(log(simS.h1M(:,ic)), pCollegeV, '.', 'color', cS.colorM(1,:));
      xlabel(['Log h1, ', cS.demogS.cohStrV{ic}]);
      ylabel('Prob college');
      axis_range_lh([xMin, xMax, 0, 1]);
      figure_format_so(gca, setNo);
   end
   save_fig_so('endow_h1_prob_college', saveFigures, cS.figOpt4S, cS);

   %return;
end


%% ********  Table with summary stats
if 1
   nr = 20;
   nc = 2;
   tbM = cell([nr, nc]);
   tbS.rowUnderlineV = zeros([nr, 1]);
   tbS.showOnScreen = 1;

   % Header row
   ir = 1;
   tbM{ir,1} = 'Statistic';
   tbM{ir,2} = 'Value';
   

   % ******  Technicalities
   
   ir = ir + 1;
   tbM{ir, 1} = 'Set description';
   tbM{ir, 2} = ' ';
   
   % Set name
   ir = ir + 1;
   tbM{ir, 1} = 'Label';
   tbM{ir, 2} = cS.setStr;

   % Exit flag
   ir = ir + 1;
   tbM{ir, 1} = 'exit flag';
   tbM{ir, 2} = sprintf('%i', calS.exitFlag);
   
   % Version of settings
   ir = ir + 1;
   tbM{ir, 1} = 'Version';
   tbM{ir, 2} = sprintf('%i', version1);
   

   % *****  Deviations
   
   ir = ir + 1;
   tbM{ir, 1} = 'Deviations';
   tbM{ir, 2} = ' ';
   
   % Deviation
   ir = ir + 1;
   tbM{ir, 1} = 'Deviation';
   tbM{ir, 2} = sprintf('%6.4f', calS.dev);
   
   % Mean log wage deviation
   if isfield(outS, 'scalarMeanDev')
      ir = ir + 1;
      tbM{ir, 1} = 'Dev mean log wage';
      tbM{ir, 2} = sprintf('%6.4f', outS.scalarMeanDev);
   end
   % Std log wage deviation
%    if isfield(outS, 'scalarStdDev')
%       ir = ir + 1;
%       tbM{ir, 1} = 'Dev std log wage';
%       tbM{ir, 2} = sprintf('%6.4f', outS.scalarStdDev);
%    end
   % AR(1)
%    ir = ir + 1;
%    tbM{ir, 1} = 'Dev AR(1)';
%    tbM{ir, 2} = sprintf('%6.4f', outS.scalarShockDev);
   % Cov log wage
%    ir = ir + 1;
%    tbM{ir, 1} = 'Dev cov log wage';
%    tbM{ir, 2} = sprintf('%6.4f', outS.scalarCovWageDev);
   
   
%    ir = ir + 1;
%    tbM{ir, 1} = 'Avg R2';
%    xStr = [sprintf('%4.2f, ', simStatS.avgR2V),  sprintf('(%4.2f)', mean(simStatS.avgR2V))];
%    tbM{ir, 2} = xStr;
%    
%    ir = ir + 1;
%    tbM{ir, 1} = 'Avg R2 std log wage';
%    xV = simStatS.avgStdLogWageR2V;
%    xStr = [sprintf('%4.2f, ', xV),  sprintf('(%4.2f)', mean(xV))];
%    tbM{ir, 2} = xStr;
   

   ir = ir + 1;
   tbM{ir, 1} = 'Corr a, ln h1';
   tbM{ir, 2} = sprintf('%4.2f',  mean(simStatS.corrAbilH1M(:)));
   
   % Growth rate of skill prices
   ir = ir + 1;
   tbM{ir, 1} = 'g(w)';
   xStr = sprintf('%4.1f, ',  100 .* simStatS.spModelGrowthV);
   tbM{ir, 2} = xStr(1 : (end-2));

   
   % Write table
   tbS.rowUnderlineV = tbS.rowUnderlineV(1 : ir);
   fid = fopen([cS.tbDir, 'tb_stats.tex'], 'w');
   latex_texttb_lh(fid, tbM(1:ir,:), 'Caption', 'Label', tbS);
   fclose(fid);
   disp('Saved table  tb_stats.tex');
end



%% ********  Endowment distributions
% for 1 cohort
if 01
   nFigs = 2;
   for iFig = 1 : nFigs
      if iFig == 1
         % Ability
         xPlotV = abilM(:, cS.resultCohort);
         plotFn = 'endow_abil_distr';
         xNameStr = 'Effective ability';
      elseif iFig == 2
         % h1
         xPlotV = log(simS.h1M(:,cS.resultCohort));
         plotFn = 'endow_h1_distr';
         xNameStr = 'log h1';
      else
         error('Invalid');
%          % p
%          xPlotV = prefV;
%          plotFn = 'pref_distr';
%          xNameStr = '\pi \times p';
      end
      
      fig_new_so(saveFigures);
      
      %for iCohort = 1 : cS.nCohorts
      %   subplot(cS.figRows, cS.figCols, iCohort);
      %   hold on;
         
         [fV, xV] = ksdensity(xPlotV);
         plot(xV, fV, '-', 'Color', cS.colorM(1,:));
         xlabel(xNameStr);
         
         %if iCohort == 1
         %   legend(cS.schoolLabelV, 'Location', 'Northwest');
         %end
      %end
     
      figure_format_so(gca, setNo);
      save_fig_so(plotFn, saveFigures, [], cS);
   end
   
end




%%  Sorting by endowments: mean(a | s) and std dev(a | s)
if saveFigures >= 0
   fig_new_so(saveFigures, setNo);
   
   hold on;
   for iSchool = 1 : cS.nSchool
      plot(cS.demogS.bYearV,  simStatS.abilMean_scM(iSchool, :),  cS.lineStyleV{iSchool}, 'Color', cS.colorM(iSchool,:));
   end
   
   hold off;
   xlabel('Birth year');
   ylabel('Mean effective ability');
   legend(cS.schoolLabelV, 'Location', 'Southoutside', 'Orientation', 'horizontal');
   
   figure_format_so(gca, setNo);
   save_fig_so([cS.figDir, 'endow_abil_school_mean'], saveFigures, [], cS);


   % *****  Std dev
   fig_new_so(saveFigures, setNo);
   
   hold on;
   for iSchool = 1 : cS.nSchool
      plot(cS.demogS.bYearV,  simStatS.abilStd_scM(iSchool, :),  cS.lineStyleV{iSchool}, 'Color', cS.colorM(iSchool,:));
   end
   
   hold off;
   xlabel('Birth year');
   ylabel('Std effective ability');
   legend(cS.schoolLabelV, 'Location', 'Southoutside', 'Orientation', 'horizontal');
   
   figure_format_so(gca, setNo);
   save_fig_so([cS.figDir, 'endow_abil_school_std'], saveFigures, [], cS);
end



%% ********  Sorting by endowments: mean(h1 | s) / std(h1 | s)
if saveFigures >= 0
   fig_new_so(saveFigures, setNo);
   
   hold on;
   for iSchool = 1 : cS.nSchool
      plot(cS.demogS.bYearV,  simStatS.logH1Mean_scM(iSchool, :),  cS.lineStyleV{iSchool}, 'Color', cS.colorM(iSchool,:));
   end
   
   hold off;
   xlabel('Birth year');
   ylabel('Mean log h_{1}');
   legend(cS.schoolLabelV, 'Location', 'Southoutside', 'Orientation', 'horizontal');
   
   figure_format_so(gca, setNo);
   save_fig_so([cS.figDir, 'endow_h1_school_mean'], saveFigures, [], cS);

   
   % ******  Std dev
   fig_new_so(saveFigures, setNo);
   
   hold on;
   for iSchool = 1 : cS.nSchool
      plot(cS.demogS.bYearV,  simStatS.logH1Std_scM(iSchool, :),  cS.lineStyleV{iSchool}, 'Color', cS.colorM(iSchool,:));
   end
   
   hold off;
   xlabel('Birth year');
   ylabel('Std log h_{1}');
   legend(cS.schoolLabelV, 'Location', 'Southoutside', 'Orientation', 'horizontal');
   
   figure_format_so(gca, setNo);
   save_fig_so([cS.figDir, 'endow_h1_school_std'], saveFigures, [], cS);
end


%% ********  Sorting by endowments: entire distribution
if 01
   figRows = 3;   figCols = 2;
   nFigs = 2;
   for iFig = 1 : nFigs
      
      fig_new_so(saveFigures, setNo);
      meanM = cS.missVal .* ones([cS.nSchool, cS.nCohorts]);
      
      for ic = 1 : length(cS.demogS.byShowV)
         iCohort = cS.demogS.byShowV(ic);
         if iFig == 1
            % Ability
            xPlotV = abilM(:, iCohort);
            plotFn = 'endow_abil_school';
            xNameStr = 'Effective ability';
         elseif iFig == 2
            % h1
            xPlotV = log(simS.h1M(:, iCohort));
            plotFn = 'endow_h1_school';
            xNameStr = 'h1';
         else
            error('Invalid');
         end
         
         subplot(figRows, figCols, ic);
         hold on;
         
         for iSchool = 1 : cS.nSchool
            % Weights
            wtV = simS.pSchoolM(:, iSchool, iCohort);
            wtV = wtV ./ sum(wtV);
            [fV, xV] = ksdensity(xPlotV, 'weights', wtV);
            plot(xV, fV, '-', 'Color', cS.colorM(iSchool,:));
            meanM(iSchool, iCohort) = sum(xPlotV .* wtV);
         end
         hold off;
         xlabel([xNameStr, ' -- Cohort ', cS.demogS.cohStrV{iCohort}]);
         
         if iCohort == 1
            legend(cS.schoolLabelV, 'Location', 'Northwest');
         end
         figure_format_so(gca, setNo);
      end
      
      save_fig_so(plotFn, saveFigures, cS.figOpt6S, cS);
      
      % Table with means
      disp(' ');
      disp(['Mean ', xNameStr, ' by [school, cohort]']);
      for iCohort = 1 : cS.nCohorts
         if any(meanM(:, iCohort) ~= cS.missVal)
            fprintf('Cohort %i    ', iCohort);
            fprintf('%10.4f', meanM(:, iCohort));
            fprintf('\n');
         end
      end
   end
end




end