function cal_show_so1(saveFigures, gNo, setNo)
% Show calibration results
%{
Duplicates showing calibration targets, but that is hard to avoid

Checked: 2014-apr-8
%}
% -------------------------------------------

cS = const_so1(gNo, setNo);
cdS = const_so1(gNo, cS.dataSetNo);


loadS = var_load_so1(cS.vCalResults, cS);
%tgS = loadS.tgS;
tgS = var_load_so1(cS.vCalTargets, cdS);
outS = loadS.calDevS;

simS = var_load_so1(cS.vSimResults, cS);
simStatS = var_load_so1(cS.vSimStats, cS);

% Aggregate cps wage stats
clear cdS;



%%  IQ: Model vs data
if cS.gS.tgIq > 0
   fig_new_so(saveFigures);
   
   hold on;
   plot(cS.bYearV, tgS.iqPctM(1,:), cS.lineStyleV{1}, 'Color', cS.colorM(1,:));
   plot(cS.bYearV, simS.meanIqPctM(1,:), cS.lineStyleV{2}, 'Color', cS.colorM(1,:));
   
   plot(cS.bYearV, tgS.iqPctM(2,:), cS.lineStyleV{1}, 'Color', cS.colorM(2,:));
   plot(cS.bYearV, simS.meanIqPctM(2,:), cS.lineStyleV{2}, 'Color', cS.colorM(2,:));
   hold off;
   
   axisV = axis;
   axisV(3) = 0;
   axis(axisV);
   xlabel('Birth year');
   ylabel('Mean IQ percentile score');
   legend({'College data', 'College model',  'No college data', 'No college model'},  'Location', 'South');

   figure_format_so(gca);
   figFn = 'iq_model_data';
   save_fig_so(figFn, saveFigures, [], cS);
   
   %return;
end





%%  Labor inputs per hour, by [age, school, year]
if 1
   % Show these years
   yearV = cS.wageYearV(1 : 4 : 20);
   legendV = arrayfun(@(x) {sprintf('%d', x)}, yearV);
  
   for iSchool = 1 : cS.nSchool
      ageV = cS.workStartAgeV(iSchool) : cS.ageRetire;
      fig_new_so(saveFigures);
      hold on;
      
      for iLine = 1 : length(yearV)
         dataV = outS.meanLPerHour_astM(ageV, iSchool, yearV(iLine)-cS.spS.spYearV(1)+1);
         idxV = find(dataV ~= cS.missVal);
         plot(ageV(idxV),  dataV(idxV),  cS.lineStyleDenseV{iLine}, 'color', cS.colorM(iLine,:));         
      end
      
      hold off;
   
      xlabel('Age');
      ylabel('Mean L per hour');
      legend(legendV)
      figure_format_so(gca);
      save_fig_so(['mean_l_perhour_at_', cS.schoolSuffixV{iSchool}], saveFigures, [], cS);
   end
end



%%  Cohort schooling
% To verify that model gets it right
if saveFigures >= 0     &&  01
   fig_new_so(saveFigures);
   
   hold on;
   for iSchool = 1 : cS.nSchool
      plot(cS.bYearV,  tgS.sFracM(iSchool,:),      '-',  'Color', cS.colorM(iSchool,:));
      plot(cS.bYearV,  simStatS.sFracM(iSchool,:), 'd',  'Color', cS.colorM(iSchool,:));
   end
   hold off;
   
   axisV = axis;
   axisV(3) = 0;
   axis(axisV);
   xlabel('Birth year');
   ylabel('Fraction in each school group');
   legend({'Data', 'Model'}, 'location', 'southoutside', 'orientation', 'horizontal');

   figure_format_so(gca, setNo);
   figFn = 'school_cohort';
   save_fig_so(figFn, saveFigures, [], cS);
   %return;
end




%%  Table: wage growth rates
if 01
   dataGrowthV = simStatS.spDataGrowthV(:);
   modelGrowthV = simStatS.spModelGrowthV(:);
   
   
   % ********  Bar graph
   fig_new_so(saveFigures);
   bar(1 : cS.nSchool, [dataGrowthV(:), modelGrowthV(:)]);
   set(gca, 'XTick', 1 : cS.nSchool,  'XTickLabel', cS.schoolLabelV);
   ylabel(sprintf('Change in mean log wage, %i-%i', simStatS.spGrowthYearV));
   xlabel('School group');
   legend({'Data', 'Model'}, 'Location', 'Northwest');
   figure_format_so(gca, setNo);
   save_fig_so('wage_growth_bar', saveFigures, [], cS);
   

   % ********  Bar graph: wage premium
   fig_new_so(saveFigures);
   sIdxV = 1 : cS.nSchool;
   sIdxV(cS.schoolHSG) = [];
   dataSpV  = dataGrowthV(sIdxV)  - dataGrowthV(cS.schoolHSG);
   modelSpV = modelGrowthV(sIdxV) - modelGrowthV(cS.schoolHSG);
   bar(1 : (cS.nSchool-1), [dataSpV(:), modelSpV(:)]);
   set(gca, 'XTick', 1 : (cS.nSchool-1),  'XTickLabel', cS.schoolLabelV(sIdxV));
   ylabel(sprintf('Change in wage relative to HSG, %i-%i', simStatS.spGrowthYearV));
   xlabel('School group');
   legend({'Data', 'Model'}, 'Location', 'Northwest');
   figure_format_so(gca, setNo);
   save_fig_so('sp_growth_bar', saveFigures, [], cS);

   
   % ********  Table layout

   nc = 5;

   nr = 6;
   tbM = cell([nr, nc]);
   tbS.rowUnderlineV = zeros([nr, 1]);
   tbS.lineStrV = cell([nr, 1]);
   tbS.colLineV = zeros([nc, 1]);
   tbS.colLineV([2, 4]) = 1;
   tbS.showOnScreen = 1;

   % Header
   tbS.lineStrV{1} = ' & \multicolumn{2}{|c|}{Skill price growth}  &  \multicolumn{2}{|c}{Skill premium growth}';
   ir = 2;
   tbS.rowUnderlineV(ir) = 1;
   tbM(ir, :) = {'School group', 'Data', 'Model', 'Data', 'Model'};

   for iSchool = 1 : cS.nSchool
      ir = ir + 1;
      tbM{ir, 1} = cS.schoolLabelV{iSchool};
      
      tbM{ir, 2} = sprintf('%4.1f', dataGrowthV(iSchool) .* 100);
      tbM{ir, 3} = sprintf('%4.1f', modelGrowthV(iSchool) .* 100);
      
      tbM{ir, 4} = sprintf('%4.1f', (dataGrowthV(iSchool)  - dataGrowthV(cS.schoolHSG)) .* 100);
      tbM{ir, 5} = sprintf('%4.1f', (modelGrowthV(iSchool) - modelGrowthV(cS.schoolHSG)) .* 100);
   end

   
   fid = fopen([cS.tbDir, 'wage_growth.tex'], 'w');
   latex_texttb_lh(fid, tbM, 'Caption', 'Label', tbS);
   fclose(fid);
   disp('Saved table  wage_growth.tex');
   fprintf('Year range: %i - %i \n', simStatS.spGrowthYearV);
   %keyboard;
end



%%  How does model fit log median wage by (s,t)?
% Constant composition wages model / data
if 1
   plotYearV = cS.wageYearV;
   mS = var_load_so1(cS.vAggrStats, cS);
   
   for iSchool = 1 : cS.nSchool
      fig_new_so(saveFigures);
      hold on;
      
      iLine = 0;
      
      % Model
      iLine = iLine + 1;
      mYearV = mS.yearV;
      if cS.useMedianWage == 1
         modelV = mS.logMedianWage_stM(iSchool,:);
      else
         modelV = mS.meanLogWage_stM(iSchool, :);
      end
      idxV = find(mYearV >= plotYearV(1)  &  mYearV <= plotYearV(end)  &  modelV ~= cS.missVal);
      plot(mYearV(idxV), modelV(idxV), cS.lineStyleDenseV{iLine}, 'color', cS.colorM(iLine,:));
      
      % Data
      iLine = iLine + 1;
      dataV = tgS.logWage_stM(iSchool, :);  
      if length(dataV) ~= length(plotYearV)
         error_so1('Years do not match');
      end
      idxV = find(dataV ~= cS.missVal);
      plot(plotYearV(idxV), dataV(idxV), cS.lineStyleDenseV{iLine}, 'color', cS.colorM(iLine,:));
      
      
      hold off;
      xlabel('Year');
      ylabel('Log wage');
      legend({'Model', 'Data'}, 'location', 'south', 'orientation', 'horizontal');
      figure_format_so(gca);
      save_fig_so(['fit_aggr_wage_', cS.schoolSuffixV{iSchool}], saveFigures, [], cS);
   end
end


%%  Skill prices fed into the model
% Also show data wages
if saveFigures >= 0  &&  01
   mS = var_load_so1(cS.vAggrStats, cS);
   prefixStr = 'sp_';
   
   % ********  Construct the data
   dataYearV  = cS.wageYearV;
   dataBaseYearIdx = find(dataYearV == cS.wageBaseYear);
   ny = length(dataYearV);
   
   for iPlot = 1 : 2
      dataWageM  = zeros([ny, cS.nSchool]);
      % Relative to hsg
      dataSpM  = repmat(cS.missVal, [ny, cS.nSchool]);
      
      if iPlot == 1
         % Show model and data. Same year range
         modelYearV = dataYearV;
         figFn = 'skill_prices';
         suffixStr = [];
      else
         % Show all model skill prices
         modelYearV = cS.spS.spYearV(1) : cS.spS.spYearV(end);
         figFn = 'skill_prices_long';
         suffixStr = '_long';
      end
      modelBaseYearIdx = find(modelYearV == cS.wageBaseYear);
         
      % Skill prices and relative skill prices
      modelSkillPriceM = zeros([length(modelYearV), cS.nSchool]);
      modelSkillPricePremM = repmat(cS.missVal, [length(modelYearV), cS.nSchool]);
      % Model const compos wages and rel wages
      modelWageM     = zeros([length(modelYearV), cS.nSchool]);
      modelWagePremM = zeros([length(modelYearV), cS.nSchool]);

      for iSchool = 1 : cS.nSchool
         % Data wages
         dataWageV = tgS.logWage_stM(iSchool, :);  
         dataWageM(:,iSchool) = dataWageV(:);


         % Model skill prices
         idxV = modelYearV - cS.spS.spYearV(1) + 1;
         modelWageV = log(simStatS.skillPrice_stM(iSchool, idxV));
         % Set intercept to match data (b/c units differ)
         modelWageV = modelWageV - modelWageV(modelBaseYearIdx) + dataWageV(dataBaseYearIdx);
         modelSkillPriceM(:, iSchool) =  modelWageV;

      
         % Model aggregate constant composition wages (match tgS.logWage_stM)
         if cS.useMedianWage == 1
            modelV = mS.logMedianWage_stM(iSchool,:);
         else
            modelV = mS.meanLogWage_stM(iSchool, :);
         end
         idxV = mS.yearV(1) - modelYearV(1) + (1 : length(modelV));
         modelWageM(idxV,iSchool) = modelV;
      end
      
      % *****  Skill premiums
      for iSchool = 1 : cS.nSchool
         % Data skill premiums
         sV    = dataWageM(:, iSchool);
         hsV   = dataWageM(:, cS.schoolHSG);
         idxV = find(sV ~= cS.missVal  &  hsV ~= cS.missVal);
         dataSpM(idxV,iSchool) = sV(idxV) - hsV(idxV);
      
         % Model skill premiums
         sV    = modelSkillPriceM(:, iSchool);
         hsV   = modelSkillPriceM(:, cS.schoolHSG);
         idxV = find(sV ~= cS.missVal  &  hsV ~= cS.missVal);
         modelSkillPricePremM(idxV,iSchool) = sV(idxV) - hsV(idxV);      

         % Skill premium
         sV    = modelWageM(:, iSchool);
         hsV   = modelWageM(:, cS.schoolHSG);
         idxV = find(sV ~= cS.missVal  &  hsV ~= cS.missVal);
         modelWagePremM(idxV,iSchool) = sV(idxV) - hsV(idxV);      
      end
      
      
      % ******  Plot skill prices (one plot, model only)
      if 1
         plotYearV = cS.wageYearV(1) : cS.wageYearV(end);
         idxV = find(modelYearV >= plotYearV(1)  &  modelYearV <= plotYearV(end));
         fig_new_so(saveFigures);
         hold on;
         for iSchool = 1 : cS.nSchool
            plot(modelYearV(idxV), modelSkillPriceM(idxV,iSchool), cS.lineStyleDenseV{iSchool}, ...
               'Color', cS.colorM(iSchool,:));
         end
         hold off;
         xlabel('Year');
         ylabel('Log skill price');
         legend(cS.schoolLabelV, 'location', 'southoutside', 'orientation', 'horizontal');
         figure_format_so(gca);
         save_fig_so([prefixStr, 'skill_prices'], saveFigures, [], cS);
      end
      
      
      % ******  Plot skill prices (one plot per school group)

      [yMin, yMax] = y_range_so1([modelSkillPriceM(:); dataWageM(:)], cS.missVal);

      for iSchool = 1 : cS.nSchool
         legendV = cell([3,1]);

         fig_new_so(saveFigures);
         hold on;

         % Model skill prices
         iLine = 1;
         legendV{iLine} = 'Skill price';
         plot(modelYearV, modelSkillPriceM(:,iSchool), cS.lineStyleDenseV{1}, 'Color', cS.colorM(1,:));

         % Data wages
         iLine = iLine + 1;
         legendV{iLine} = 'Data';
         idxV = find(dataWageM(:, iSchool) > cS.missVal);
         plot(dataYearV(idxV),  dataWageM(idxV,iSchool),  cS.lineStyleDenseV{2}, 'Color', cS.colorM(2,:));
         
         % Model wages (should match data wages)
         iLine = iLine + 1;
         legendV{iLine} = 'Model';
         idxV = find(modelWageM(:, iSchool) ~= cS.missVal);
         plot(modelYearV(idxV),  modelWageM(idxV,iSchool),  cS.lineStyleDenseV{iLine}, 'Color', cS.colorM(iLine,:));

         hold off;
         xlabel('Year');
         ylabel(cS.wageStr);
         if iSchool == cS.nSchool
            legend(legendV, 'location', 'SouthEast');
         end
         axisV = axis;
         axisV(3:4) = [yMin, yMax];
         axis(axisV);
         figure_format_so(gca, setNo);
         save_fig_so([prefixStr, figFn, '_', cS.schoolSuffixV{iSchool}], saveFigures, [], cS);
      end

      
      
      % ****** Plot: college wage premium
      fig_new_so(saveFigures);
      hold on;

      iSchool = cS.schoolCG;
      plot(modelYearV, modelSkillPricePremM(:, iSchool), cS.lineStyleDenseV{1}, 'Color', cS.colorM(1,:));

      idxV = find(dataSpM(:,iSchool) ~= cS.missVal);
      plot(dataYearV(idxV),  dataSpM(idxV, iSchool),  cS.lineStyleDenseV{2}, 'Color', cS.colorM(2,:));

      hold off;
      xlabel('Year');
      ylabel('Log wage relative to HSG');
      legend({'Model', 'Data'},  'Location', 'Northwest');

      figure_format_so(gca, setNo);
      figFn = [prefixStr, 'college_premium', suffixStr];
      save_fig_so(figFn, saveFigures, cS.figOptS, cS);
   
   
      % ****** Plot: all school levels
      fig_new_so(saveFigures);

      for iSchool = 1 : cS.nSchool
         if iSchool ~= cS.schoolHSG
            subplot(2,2,iSchool);
            hold on;

            plot(modelYearV, modelSkillPricePremM(:, iSchool), cS.lineStyleDenseV{1}, 'Color', cS.colorM(1,:));

            idxV = find(dataSpM(:,iSchool) ~= cS.missVal);
            plot(dataYearV(idxV),  dataSpM(idxV, iSchool),  cS.lineStyleDenseV{2}, 'Color', cS.colorM(2,:));

            hold off;
            xlabel(['Year  --  ', cS.schoolLabelV{iSchool}]);
            ylabel('Log wage relative to HSG');
         end
         figure_format_so(gca, setNo);
      end
      %legend(,  'Location', 'Northwest');

      figFn = [prefixStr, 'skill_premiums', suffixStr];
      save_fig_so(figFn, saveFigures, cS.figOpt4S, cS);
   end
end



%%   Wage growth and intercept
if saveFigures >= 0  &&  01
   % Compute intercepts and growth rates over these ages
   ageV = cS.wageGrowthAgeV;
   
   % Show slope and intercept
   for iPlot = 1 : 2
      for iSchool = 1 : cS.nSchool
         % Compute data and model log wages, both ages, all cohorts
         
         dataLogWage_acM   = squeeze(tgS.logWage_ascM(ageV,iSchool,:));
         dataIdxV = find(dataLogWage_acM(1, :) ~= cS.missVal  & dataLogWage_acM(2, :) ~= cS.missVal);

         if cS.useMedianWage == 1
            modelLogWage_acM  = squeeze(simStatS.logMedianWage_ascM(ageV,iSchool,:));
         else
            modelLogWage_acM  = squeeze(simStatS.meanLogWage_ascM(ageV,iSchool,:));
         end
         if 0
            % Show all model cohorts
            modelIdxV = find(modelLogWage_acM(1, :) ~= cS.missVal  &  modelLogWage_acM(2, :) ~= cS.missVal);
         else
            % Show only data cohorts
            modelIdxV = dataIdxV;
         end


         if iPlot == 1
            % Change in log median wage
            yDataV  = dataLogWage_acM(2, :) - dataLogWage_acM(1, :);
            yModelV = modelLogWage_acM(2, :) - modelLogWage_acM(1, :);
            figFn = 'cohort_wage_growth';
         elseif iPlot == 2
            % Level of log wage at age 25
            yDataV  = dataLogWage_acM(1, :);
            yModelV = modelLogWage_acM(1, :);
            figFn = 'cohort_wage_intercept';
         end
         

         % *****  Plot
         
         fig_new_so(saveFigures);
         hold on;

         iLine = cS.iModel;
         plot(cS.bYearV(modelIdxV),  yModelV(modelIdxV), cS.lineStyleV{iLine}, 'Color', cS.colorM(iLine,:));
         
         iLine = cS.iData;
         plot(cS.bYearV(dataIdxV),  yDataV(dataIdxV), cS.lineStyleV{iLine}, 'Color', cS.colorM(iLine,:));
         
         
         hold off;
         xlabel('Birth year');
         axisV = axis;
         if iPlot == 1
            ylabel(sprintf('Change in mean log wage, ages %i to %i', ageV));
            axis([axisV(1:2), -0.2, 0.65]);  % do not hard code +++
         elseif iPlot == 2
            ylabel(sprintf('%s at age %i', cS.wageStr, ageV(1)));
            % axis([axisV(1:2), 0, 950]);  % do not hard code +++
         end

         legend({'Model', 'Data'}, 'location', 'best');
         figure_format_so(gca);
         save_fig_so([figFn, '_', cS.schoolSuffixV{iSchool}], saveFigures, [], cS);
      end % iSchool
   end % for iPlot
end   

   

end