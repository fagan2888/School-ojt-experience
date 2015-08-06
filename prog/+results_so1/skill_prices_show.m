function skill_prices_show(saveFigures, gNo, setNo)

cS = const_so1(gNo, setNo);
% figS = const_fig_so1;
dirS = param_so1.directories(gNo, setNo);
varS = param_so1.var_numbers;
outDir = dirS.paramDir;

calS = var_load_so1(varS.vCalResults, cS);
logSkillPrice_stM = log_lh(calS.calDevS.skillPrice_stM, cS.missVal);
modelYearV = cS.spS.spYearV(1) : cS.spS.spYearV(end);

cdS = const_data_so1(gNo);
tgS = var_load_so1(varS.vCalTargets, cdS);
logDataWage_stM = tgS.logWage_stM;
dataYearV = cS.wageYearV;

% Model skill prices
model_skill_prices(logSkillPrice_stM, modelYearV,  outDir, saveFigures, cS);
% Model skill prices vs data log wages
model_data_wages(logSkillPrice_stM, modelYearV,  logDataWage_stM, dataYearV,  outDir, saveFigures, cS);


end


%% Model skill prices
function model_skill_prices(logSkillPrice_stM, modelYearV, outDir, saveFigures, cS)
   yrIdx = find(modelYearV == cS.wageYearV(1));
   
   figS = const_fig_so1;

   % *******  Levels
   fh = output_so1.fig_new(saveFigures);
   hold on;
   
   for iSchool = 1 : cS.nSchool
      plot(modelYearV, logSkillPrice_stM(iSchool, :) - logSkillPrice_stM(iSchool, yrIdx),  ...
         figS.lineStyleDenseV{iSchool}, 'color', figS.colorM(iSchool,:));
   end
   
   hold off;
   xlabel('Year');
   ylabel('Log skill price');
   legend(cS.schoolLabelV, 'location', 'southoutside', 'orientation', 'horizontal');
   output_so1.fig_format(fh, 'line');
   figFn = fullfile(outDir, 'skill_price_model');
   output_so1.fig_save(figFn, saveFigures, cS);
   
   
   % *******  Relative to HSG
   y_stM = logSkillPrice_stM - ones(cS.nSchool, 1) * logSkillPrice_stM(cS.iHSG, :);
   fh = output_so1.fig_new(saveFigures);
   hold on;
   
   for iSchool = 1 : cS.nSchool
      plot(modelYearV, y_stM(iSchool, :) - y_stM(iSchool, yrIdx),  ...
         figS.lineStyleDenseV{iSchool}, 'color', figS.colorM(iSchool,:));
   end
   
   hold off;
   xlabel('Year');
   ylabel('Log skill premium');
   legend(cS.schoolLabelV, 'location', 'southoutside', 'orientation', 'horizontal');
   output_so1.fig_format(fh, 'line');
   figFn = fullfile(outDir, 'skill_prem_model');
   output_so1.fig_save(figFn, saveFigures, cS);
end


%% Model skill prices vs data wages
function model_data_wages(logSkillPrice_stM, modelYearV,  logDataWage_stM, dataYearV,  outDir, saveFigures, cS)
   yrIdx = find(modelYearV == cS.wageYearV(1));
   model_stM = logSkillPrice_stM - logSkillPrice_stM(:, yrIdx) * ones(1, length(modelYearV));
   data_stM = logDataWage_stM - logDataWage_stM(:, 1) * ones(1, length(dataYearV));
   
   figS = const_fig_so1;

   % *******  Levels
   
   for iSchool = 1 : cS.nSchool
      fh = output_so1.fig_new(saveFigures);
      hold on;
      
      iLine = 1;
      plot(modelYearV, model_stM(iSchool, :),  ...
         figS.lineStyleDenseV{iLine}, 'color', figS.colorM(iLine,:));
      iLine = iLine + 1;
      plot(dataYearV, data_stM(iSchool, :),  ...
         figS.lineStyleDenseV{iLine}, 'color', figS.colorM(iLine,:));
   
      hold off;
      xlabel('Year');
      ylabel('Log skill price');
      output_so1.fig_format(fh, 'line');
      figFn = fullfile(outDir, ['model_data_wages_', cS.schoolSuffixV{iSchool}]);
      output_so1.fig_save(figFn, saveFigures, cS);
   end
   
   
   % *******  Relative to HSG
   
   for iSchool = 1 : cS.nSchool
      fh = output_so1.fig_new(saveFigures);
      hold on;
      
      iLine = 1;
      plot(modelYearV, model_stM(iSchool, :) - model_stM(cS.iHSG, :),  ...
         figS.lineStyleDenseV{iLine}, 'color', figS.colorM(iLine,:));
      iLine = iLine + 1;
      plot(dataYearV, data_stM(iSchool, :) - data_stM(cS.iHSG, :),  ...
         figS.lineStyleDenseV{iLine}, 'color', figS.colorM(iLine,:));
   
      hold off;
      xlabel('Year');
      ylabel('Log skill premium');
      output_so1.fig_format(fh, 'line');
      figFn = fullfile(outDir, ['skill_prem_model_data_', cS.schoolSuffixV{iSchool}]);
      output_so1.fig_save(figFn, saveFigures, cS);
   end


end