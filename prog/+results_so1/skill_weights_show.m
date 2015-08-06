function skill_weights_show(saveFigures, gNo, setNo)
% Compare model implied skill weights with using hours as labor supplies
%{

There is an issue with mean log wage data
   steep rise after 1964 - not plausible
   this is what generates diff between 2 ways of constructing labor supplies

change:
   data hours should have no missing values

Checked: +++++
%}
% --------------------------------------------------

cS = const_so1(gNo, setNo);
cdS = const_data_so1(gNo);
varS = param_so1.var_numbers;


%% Load Model
% Skill weights for years in spYearV

modelS.yearV = (cS.spS.spYearV(1) : cS.spS.spYearV(end))';
modelS.ny = length(modelS.yearV);

calS = var_load_so1(varS.vCalResults, cS);
paramS = calS.paramS;
outS = calS.calDevS;

% Aggr labor supply by [school, year]
modelS.lSupply_stM = outS.lSupply_stM;

modelS.skillPrice_stM = outS.skillPrice_stM;

modelS.skillWeightTop_tlM = outS.skillWeightTop_tlM;
modelS.skillWeight_tlM = outS.skillWeight_tlM;




%% Load data

tgS = var_load_so1(varS.vCalTargets, cdS);

dataS.yearV = cS.wageYearV(1) : cS.wageYearV(end);
dataS.ny = length(dataS.yearV);

% Make aggregate labor supplies
dataS.lSupply_stM = tgS.aggrHours_stM;

dataS.skillPrice_stM = exp(tgS.logWage_stM);
validateattributes(tgS.logWage_stM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
   '>', cS.missVal + 1, 'size', [cS.nSchool, dataS.ny]})

% Calibrate skill weights using hours as labor supply
[dataS.skillWeightTop_tlM, dataS.skillWeight_tlM, AV] = calibr_so1.skill_weights(dataS.lSupply_stM, ...
   dataS.skillPrice_stM, paramS.aggrProdFct, cS);

% Check that this recovers data wages
mp_tsM = paramS.aggrProdFct.mproducts(AV,  dataS.skillWeightTop_tlM, dataS.skillWeight_tlM, ...
   dataS.lSupply_stM');
check_lh.approx_equal(mp_tsM',  dataS.skillPrice_stM, 1e-3, []);


%% Compare model and data

plot_skill_weights(modelS, 'skill_weights', saveFigures, cS);
plot_skill_weights(dataS, 'skill_weights_hours', saveFigures, cS);

plot_model_ls(modelS, saveFigures, cS);
plot_labor_supplies(modelS, dataS, saveFigures, cS);

return;  % +++++


%% Alternative labor supply from wage bill

%  Data: total wage bill by [school, year]
%  Approximate as exp(log wage) * hours
%  Each wage bill can be scaled by an arbitrary factor (same for all years) without affecting
%  results

% wageBillM = repmat(cS.missVal, [cS.nSchool, nYr]);
% for iy = 1 : nYr
%    yrIdx = find(dataYearV == yearV(iy));
%    if length(yrIdx) == 1
%       for iSchool = 1 : cS.nSchool
%          ageV = cS.demogS.workStartAgeV(iSchool) : cS.demogS.ageRetire;
%          logWageV = dataS.meanLogWageTruncM(ageV,iSchool,yrIdx);
%          hoursV   = dataHoursM(ageV,iSchool,yrIdx);
%          idxV = find(logWageV ~= cS.missVal  &  hoursV > 0);
%          xV = exp(logWageV(idxV)) .* hoursV(idxV);
%          wageBillM(iSchool, iy) = sum(xV(:));
%       end
%    end
% end

% Labor supply = wage bill / skill price
% modelLS_stM = wageBillM ./ skillPrice_stM;
% modelLS_stM(wageBillM <= 0  |  skillPrice_stM <= 0) = cS.missVal;







%% Plot mean log efficiency
if 1
   plotYearV = cS.wageYearV(1) : cS.wageYearV(end);
   
   % Mean efficiency = model labor supply / data hours
   %  This is consistent b/c model labor supply = model eff * data hours (cal_dev3)
   meanEff_stM = modelLS_stM ./ LSHours_stM;

   output_so1.fig_new(saveFigures);
   hold on;
   for iSchool = 1 : cS.nSchool
      idxV = find(meanEff_stM(iSchool,:)' > 0  &  yearV >= plotYearV(1)  &  yearV <= plotYearV(end));
      plot(yearV(idxV),  log(meanEff_stM(iSchool,idxV)) - log(meanEff_stM(iSchool,idxV(1))),  ...
         figS.lineStyleDenseV{1}, 'color', figS.colorM(iSchool,:));
   end
   if 0
      error('Not updated') % +++
      % Also plot alternative version
      for iSchool = 1 : cS.nSchool
         idxV = find(meanEffSY2M(iSchool,:)' > 0  &  yearV >= plotYearV(1)  &  yearV <= plotYearV(end));
         plot(yearV(idxV),  log(meanEffSY2M(iSchool,idxV)) - log(meanEffSY2M(iSchool,idxV(1))),  ...
            figS.lineStyleDenseV{2}, 'color', figS.colorM(iSchool,:));
      end
   end
   hold off;

   xlabel('Year');
   ylabel('Log efficiency');
   legend(cS.schoolLabelV, 'location', 'southoutside', 'orientation', 'horizontal');
   output_so1.fig_format(gca, setNo);
   output_so1.fig_save('ge_efficiency', saveFigures, [], cS);
end


%% Plot hours worked by [school, year]
if 1   
   output_so1.fig_new(saveFigures);
   hold on;
   for iSchool = 1 : cS.nSchool
      idxV = find(LSHours_stM(iSchool,:) > 0);
      plot(yearV(idxV),  log(LSHours_stM(iSchool,idxV)) - log(LSHours_stM(iSchool,idxV(1))),  figS.lineStyleDenseV{iSchool}, 'color', figS.colorM(iSchool,:));
   end
   hold off;

   xlabel('Year');
   ylabel('Log hours');
   legend(cS.schoolLabelV, 'location', 'southoutside', 'orientation', 'horizontal');
   output_so1.fig_format(gca, setNo);
   output_so1.fig_save('ge_hours', saveFigures, [], cS);
end


% Check that model matches mean log wages
% Levels do not matter (?)
if 0
   error('Not updated');   % +++
   ageV = 30 : 10 : 50;
   for iSchool = 1 : cS.nSchool
      output_so1.fig_new(saveFigures);
      hold on;
      for iAge = 1 : length(ageV)
         % Model
         yV = squeeze(meanLogEffM(ageV(iAge),iSchool,:)) + log(skillPrice_stM(iSchool,:))';
         yV = yV(:);
         idxV = find(yV ~= cS.missVal);
         plot(yearV(idxV),  yV(idxV) - yV(idxV(1)) + iAge,  figS.lineStyleDenseV{1}, 'color', figS.colorM(iAge,:));
         
         % Data
         yV = dataS.meanLogWageTruncM(ageV(iAge),iSchool,:);         
         yV = yV(:);
         idxV = find(yV ~= cS.missVal);
         plot(yearV(idxV),  yV(idxV) - yV(idxV(1)) + iAge,  figS.lineStyleDenseV{2}, 'color', figS.colorM(iAge,:));
      end
      
      hold off;
      xlabel('Year');
      ylabel('Mean log wage');
      output_so1.fig_save(['ge_wages_', cS.schoolSuffixV{iSchool}], saveFigures, [], cS);
   end
end


end


%% Local: plot model or data skill weights
function plot_skill_weights(modelS, figFn, saveFigures, cS)
   figS = const_fig_so1;

   % Normalize skill weights relative to HSG
   skillWeight_stM = normalize(modelS, cS);
   
   iSchoolV = 1 : cS.nSchool;
   iSchoolV(cS.iHSG) = [];
   legendV = cS.schoolLabelV(iSchoolV);
   
   output_so1.fig_new(saveFigures, []);   
   hold on;
   iLine = 0;
   
   for iSchool = iSchoolV
      yV = log(skillWeight_stM(iSchool, :));
      iLine = iLine + 1;
      plot(modelS.yearV,  yV,  figS.lineStyleDenseV{iLine}, 'color', figS.colorM(iLine,:));      
   end
   
   hold off;
   xlabel('Year');
   ylabel('Log skill weights (relative)');
   legend(legendV);
   output_so1.fig_format(gca, 'line');
   output_so1.fig_save(figFn, saveFigures, cS);
end


%% Local: plot skill weights, model vs data
%{
Data really means: hours as labor supplies
%}
% function compare_skill_weights(modelS, dataS, saveFigures, cS)
% 
%    figNameV = {'skill_weights', 'skill_weights_hours'};
% 
%    % Show with and without skill weights implied by hours worked as LS
%    for iPlot = 1 : 2
%       output_so1.fig_new(saveFigures, []);
%       hold on;
%       for iSchool = 1 : cS.nSchool
%          yV = log(outS.skillWeight_stM(iSchool,:));
%          plot(yearV,  yV - yV(1),  figS.lineStyleDenseV{1}, 'color', figS.colorM(iSchool,:));
%       end
%       if iPlot == 2
%          % Also show mu's from hours. Scale to match level of muM
%          for iSchool = 1 : cS.nSchool
%             yV = log(muHours_stM(iSchool,:));
%             plot(yearV,  yV - yV(1),  figS.lineStyleDenseV{2}, 'color', figS.colorM(iSchool,:));
%          end
%       end
%       hold off;
% 
%       xlabel('Year');
%       ylabel('Log skill weight');
%       legend(cS.schoolLabelV, 'location', 'southoutside', 'orientation', 'horizontal');
%       output_so1.fig_format(gca, setNo);
%       figFn = 'ge_skill_weights';
%       if iPlot == 2
%          figFn = [figFn, '_hours'];
%       end
%       output_so1.fig_save(figFn, saveFigures, [], cS);
%    end
% 
% 
% 
% end


%% Plot model labor supplies (all periods)
function plot_model_ls(modelS, saveFigures, cS)
   figS = const_fig_so1;
   plotYearV = cS.spS.spYearV(1) : cS.spS.spYearV(end);
   
   output_so1.fig_new(saveFigures);
   hold on;
   for iSchool = 1 : cS.nSchool
      plot(plotYearV,  log(modelS.lSupply_stM(iSchool, :) ./ modelS.lSupply_stM(iSchool, 1)),  ...
         figS.lineStyleDenseV{iSchool}, 'color', figS.colorM(iSchool,:));
   end
   
   hold off;
   xlabel('Year');
   ylabel('Log labor supply');
   legend(cS.schoolLabelV, 'location', 'southoutside', 'orientation', 'horizontal');
   output_so1.fig_format(gca, 'line');
   output_so1.fig_save('labor_supply_model', saveFigures, cS);
end


%% Local:  Plot labor supplies
%  All normalized to 1 in year 1
function plot_labor_supplies(modelS, dataS, saveFigures, cS)
   figS = const_fig_so1;
   
   % Years to show
   plotYearV = dataS.yearV;
   mYrIdxV = plotYearV - modelS.yearV(1) + 1;
   
   output_so1.fig_new(saveFigures);
   hold on;
   for iSchool = 1 : cS.nSchool
      plot(plotYearV,  log(modelS.lSupply_stM(iSchool, mYrIdxV) ./ modelS.lSupply_stM(iSchool, mYrIdxV(1))),  ...
         figS.lineStyleDenseV{1}, 'color', figS.colorM(iSchool,:));
   end
   
   % Also plot hours - to show how similar they are
   for iSchool = 1 : cS.nSchool
      plot(plotYearV,  log(dataS.lSupply_stM(iSchool, :) ./ dataS.lSupply_stM(iSchool, 1)),  ...
         figS.lineStyleDenseV{2}, 'color', figS.colorM(iSchool,:));
   end
   hold off;

   xlabel('Year');
   ylabel('Log labor supply');
   legend(cS.schoolLabelV, 'location', 'southoutside', 'orientation', 'horizontal');
   output_so1.fig_format(gca, 'line');
   output_so1.fig_save('labor_supply_hours', saveFigures, cS);
end


%% Normalize skill weights so that HSG have weight of 1 in each period
% This can be plotted directly
% Rising skill weights mean: productivity rises relative to HSG
function skillWeight_stM = normalize(modelS, cS)
   iRef = cS.iHSG;
   T = modelS.ny;
   skillWeight_stM = zeros(cS.nSchool, T);
   skillWeight_stM(cS.iCG, :) = (modelS.skillWeightTop_tlM(:, 2) ./ modelS.skillWeightTop_tlM(:, 1));
   skillWeight_stM(1 : cS.iCD, :) = modelS.skillWeight_tlM(:, 1 : cS.iCD)';
   skillWeight_stM = skillWeight_stM ./ (ones(cS.nSchool, 1) * skillWeight_stM(iRef, :));
   
   if cS.dbg > 10
      validateattributes(skillWeight_stM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
         'size', [cS.nSchool, T]})
   end
end