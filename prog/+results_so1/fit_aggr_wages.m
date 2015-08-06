function fit_aggr_wages(saveFigures, gNo, setNo)
% Compare model with aggregate wage stats
%{
Duplicates showing calibration targets, but that is hard to avoid

Checked: 2014-apr-8
%}

cS = const_so1(gNo, setNo);

loadS = var_load_so1(varS.vCalResults, cS);
outS = loadS.calDevS;

simS = var_load_so1(varS.vSimResults, cS);
simStatS = var_load_so1(varS.vSimStats, cS);

cdS = const_so1(gNo, cS.dataSetNo);
tgS = var_load_so1(varS.vCalTargets, cdS);


% fit_wage_st



%%  IQ: Model vs data
if cS.tgIq > 0
   output_so1.fig_new(saveFigures);
   
   hold on;
   plot(cS.demogS.bYearV, tgS.iqPctM(1,:), figS.lineStyleV{1}, 'Color', figS.colorM(1,:));
   plot(cS.demogS.bYearV, simS.meanIqPctM(1,:), figS.lineStyleV{2}, 'Color', figS.colorM(1,:));
   
   plot(cS.demogS.bYearV, tgS.iqPctM(2,:), figS.lineStyleV{1}, 'Color', figS.colorM(2,:));
   plot(cS.demogS.bYearV, simS.meanIqPctM(2,:), figS.lineStyleV{2}, 'Color', figS.colorM(2,:));
   hold off;
   
   axisV = axis;
   axisV(3) = 0;
   axis(axisV);
   xlabel('Birth year');
   ylabel('Mean IQ percentile score');
   legend({'College data', 'College model',  'No college data', 'No college model'},  'Location', 'South');

   output_so1.fig_format(gca);
   figFn = 'iq_model_data';
   output_so1.fig_save(figFn, saveFigures, [], cS);
   
   %return;
end





%%  Labor inputs per hour, by [age, school, year]
if 1
   % Show these years
   yearV = cS.wageYearV(1 : 4 : 20);
   legendV = arrayfun(@(x) {sprintf('%d', x)}, yearV);
  
   for iSchool = 1 : cS.nSchool
      ageV = cS.demogS.workStartAgeV(iSchool) : cS.demogS.ageRetire;
      output_so1.fig_new(saveFigures);
      hold on;
      
      for iLine = 1 : length(yearV)
         dataV = outS.meanLPerHour_astM(ageV, iSchool, yearV(iLine)-cS.spS.spYearV(1)+1);
         idxV = find(dataV ~= cS.missVal);
         plot(ageV(idxV),  dataV(idxV),  figS.lineStyleDenseV{iLine}, 'color', figS.colorM(iLine,:));         
      end
      
      hold off;
   
      xlabel('Age');
      ylabel('Mean L per hour');
      legend(legendV)
      output_so1.fig_format(gca);
      output_so1.fig_save(['mean_l_perhour_at_', cS.schoolSuffixV{iSchool}], saveFigures, [], cS);
   end
end





%%  Table: wage growth rates
if 01
   dataGrowthV = simStatS.spDataGrowthV(:);
   modelGrowthV = simStatS.spModelGrowthV(:);
   
   
   % ********  Bar graph
   output_so1.fig_new(saveFigures);
   bar(1 : cS.nSchool, [dataGrowthV(:), modelGrowthV(:)]);
   set(gca, 'XTick', 1 : cS.nSchool,  'XTickLabel', cS.schoolLabelV);
   ylabel(sprintf('Change in mean log wage, %i-%i', simStatS.spGrowthYearV));
   xlabel('School group');
   legend({'Data', 'Model'}, 'Location', 'Northwest');
   output_so1.fig_format(gca, setNo);
   output_so1.fig_save('wage_growth_bar', saveFigures, [], cS);
   

   % ********  Bar graph: wage premium
   output_so1.fig_new(saveFigures);
   sIdxV = 1 : cS.nSchool;
   sIdxV(cS.schoolHSG) = [];
   dataSpV  = dataGrowthV(sIdxV)  - dataGrowthV(cS.schoolHSG);
   modelSpV = modelGrowthV(sIdxV) - modelGrowthV(cS.schoolHSG);
   bar(1 : (cS.nSchool-1), [dataSpV(:), modelSpV(:)]);
   set(gca, 'XTick', 1 : (cS.nSchool-1),  'XTickLabel', cS.schoolLabelV(sIdxV));
   ylabel(sprintf('Change in wage relative to HSG, %i-%i', simStatS.spGrowthYearV));
   xlabel('School group');
   legend({'Data', 'Model'}, 'Location', 'Northwest');
   output_so1.fig_format(gca, setNo);
   output_so1.fig_save('sp_growth_bar', saveFigures, [], cS);

   
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
         
         output_so1.fig_new(saveFigures);
         hold on;

         iLine = cS.iModel;
         plot(cS.demogS.bYearV(modelIdxV),  yModelV(modelIdxV), figS.lineStyleV{iLine}, 'Color', figS.colorM(iLine,:));
         
         iLine = cS.iData;
         plot(cS.demogS.bYearV(dataIdxV),  yDataV(dataIdxV), figS.lineStyleV{iLine}, 'Color', figS.colorM(iLine,:));
         
         
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
         output_so1.fig_format(gca);
         output_so1.fig_save([figFn, '_', cS.schoolSuffixV{iSchool}], saveFigures, [], cS);
      end % iSchool
   end % for iPlot
end   

   

end



%%  How does model fit log median wage by (s,t)?
function fit_wage_st(tgS, cS)
   error('not updated');   % not clear how to compute this +++++
   plotYearV = cS.wageYearV;
   mS = var_load_so1(varS.vAggrStats, cS);
   
   for iSchool = 1 : cS.nSchool
      output_so1.fig_new(saveFigures);
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
      plot(mYearV(idxV), modelV(idxV), figS.lineStyleDenseV{iLine}, 'color', figS.colorM(iLine,:));
      
      % Data
      iLine = iLine + 1;
      dataV = tgS.logWage_stM(iSchool, :);  
      if length(dataV) ~= length(plotYearV)
         error_so1('Years do not match');
      end
      idxV = find(dataV ~= cS.missVal);
      plot(plotYearV(idxV), dataV(idxV), figS.lineStyleDenseV{iLine}, 'color', figS.colorM(iLine,:));
      
      
      hold off;
      xlabel('Year');
      ylabel('Log wage');
      legend({'Model', 'Data'}, 'location', 'south', 'orientation', 'horizontal');
      output_so1.fig_format(gca);
      output_so1.fig_save(['fit_aggr_wage_', cS.schoolSuffixV{iSchool}], saveFigures, [], cS);
   end
end

