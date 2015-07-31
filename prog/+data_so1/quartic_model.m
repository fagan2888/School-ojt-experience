function quartic_model(saveFigures, gNo)
% How well does a quartic model fit the data?
%{
Repeats cpsojt code. But here I also check whether time effects fit the aggr prod fct

Show std error bands +++

Checked: 2014-may-1
%}


%% Settings

cS = const_data_so1(gNo);
figS = const_fig_so1;
varS = param_so1.var_numbers;

useWeights     = 1;
% useMedianWage  = cS.useMedianWage;
useTimeDummies = 1;
useCohDummies  = 0;     % Not implemented for time and cohort dummies
useAgeDummies  = false;
nx = 4;

% Age Range
ageMax = 60;      % Later ages have big drop-offs in wages
age1V  = cS.workStartAgeV;

fprintf('\n\nQuartic wage regressions\n\n');

fprintf('Cohort dummies: ');
if useCohDummies 
   fprintf('Yes \n');
else
   fprintf('No \n');
end


%% Regression inputs: median wage by [a,s,t]

% outS = output_so1.var_load(varS.vAgeSchoolYearStats, cS);
% Years are cS.wageYearV
tgS = output_so1.var_load(varS.vCalTargets, cS);

logWage_ascM = tgS.logWage_ascM(1 : ageMax, :, :);

if useWeights
   wt_ascM = sqrt(max(0,  tgS.nObs_ascM(1 : ageMax, :, :)));
else
   wt_ascM = [];
end



%% Quartic regression

% R2 from each regression
r2V = zeros([cS.nSchool, 1]);
% Predicted log wage by [cohort, school, age]
pred_ascM = repmat(cS.missVal, [ageMax, cS.nSchool, cS.nCohorts]);
% Predicted experience profiles
pred_asM  = repmat(cS.missVal, [ageMax, cS.nSchool]);
% Regression results
regrV = cell([cS.nSchool, 1]);

% Options struct for regressions
optS.useAgeDummies = useAgeDummies;
optS.nx = nx;
optS.useWeights = useWeights;
optS.useTimeDummies = useTimeDummies;
optS.useCohDummies = useCohDummies;

for iSchool = 1 : cS.nSchool
   clear regrS;
   ageV = age1V(iSchool) : ageMax;
   % Inputs are by [coh, age]
   y_caM = squeeze(logWage_ascM(ageV, iSchool, :))';
   if useWeights
      wt_caM = squeeze(wt_ascM(ageV, iSchool, :))';
   else
      wt_caM = [];
   end

   regrS  =  regress_lh.regr_cohort_age(y_caM, wt_caM, cS.bYearV, ageV, ...
      optS, cS.missVal, cS.dbg);
   regrV{iSchool} = regrS;

%    [predV, pred_caM, rsS, regrS.tdYearV, regrS.tdBetaV, regrS.cdIdxV, regrS.cdBetaV] = ...
%       regr_cohort_age_so(yM, wtM, cS.bYearV, ageV, useTimeDummies, useCohDummies, cS);
   
   % Age profile (pure age coefficients)
   pred_asM(ageV, iSchool) = regrS.ageProfileV;
   
   % Predicted values
   pred_acM = (y_caM - regrS.resid_caM)';
   
   % Predicted profile for each cohort
%    ageFirstYear = 1;
%    pred_caM = econ_lh.cohort_age_from_age_year(pred_acM, ageV, cS.wageYearV, cS.bYearV, ageFirstYear, ...
%       cS.missVal, cS.dbg);
   for ic = 1 : cS.nCohorts
      pred_ascM(ageV,iSchool,ic) = pred_acM(:, ic);
   end
   
   r2V(iSchool) = regrS.Rsquared.Ordinary;
end


fprintf('R2 from quartic regression:  ');
fprintf('%10.2f', r2V);
fprintf('\n');


%% Show quartic age profiles
if 1
   baseAge = max(cS.workStartAgeV);
   fh = output_so1.fig_new(saveFigures, []);
   hold on;
   for iSchool = 1 : cS.nSchool
      regrS = regrV{iSchool};
      plot(regrS.ageValueV,  regrS.ageProfileV - regrS.ageProfileV(regrS.ageValueV == baseAge),  ...
         figS.lineStyleDenseV{iSchool}, 'color', figS.colorM(iSchool,:));
   end
   hold off;
   xlabel('Age');
   ylabel('Log wage');
   legend(cS.schoolLabelV, 'location', 'south');
   output_so1.fig_format(fh, 'line');
   output_so1.fig_save('quartic_profiles', saveFigures, cS);
end


%%  Plot time effects and data wages
if 1
   for iSchool = 1 : cS.nSchool
      regrS = regrV{iSchool};
      
      % Model time effects
         % for unknown reasons: there is a 1962 time dummy (with missVal) +++++
      baseYear = 1965;
      baseIdx = find(regrS.timeValueV == baseYear);
      timeDummyV = regrS.timeDummyV - regrS.timeDummyV(baseIdx);
      
      dataWageV  = tgS.logWage_stM(iSchool, :)';
      baseWage   = dataWageV(cS.wageYearV == baseYear);
      
      output_so1.fig_new(saveFigures, []);
      hold on;
      iLine = 1;
      idxV = find(timeDummyV ~= cS.missVal);
      plot(regrS.timeValueV(idxV),  timeDummyV(idxV) + baseWage,  ...
         figS.lineStyleDenseV{iLine}, 'color', figS.colorM(iLine, :));
      iLine = iLine + 1;
      plot(cS.wageYearV(idxV), dataWageV(idxV),  ...
         figS.lineStyleDenseV{iLine}, 'color', figS.colorM(iLine, :));
      
      hold off;
      xlabel('Year');
      ylabel('Log wage');
      legend({'Model', 'Data'});
      output_so1.fig_format(gca, 'line');
      output_so1.fig_save(['quartic_wage_time_', cS.schoolSuffixV{iSchool}],  saveFigures, cS);
   end
end



%%  Show age profiles for selected cohorts
if 1
   for iSchool = 1 : cS.nSchool
      % Ages to plot
      ageV = cS.workStartAgeV(iSchool) : ageMax;
      
      % One subplot per cohort
      fh = output_so1.fig_new(saveFigures, figS.figOpt6S);
      for iSub = 1 : min(6, length(cS.byShowV))
         iBy = cS.byShowV(iSub);
         model_aV = pred_ascM(ageV, iSchool, iBy);
         data_aV  = tgS.logWage_ascM(ageV, iSchool, iBy);         
         idxV = find(model_aV ~= cS.missVal  &  data_aV ~= cS.missVal);
         
         subplot(3,2, iSub);
         hold on;
         
         iLine = 1;
         plot(ageV(idxV),  model_aV(idxV) - model_aV(idxV(1)),  ...
            figS.lineStyleDenseV{iLine},  'color', figS.colorM(iLine,:));
         iLine = iLine + 1;
         plot(ageV(idxV),  data_aV(idxV)  - data_aV(idxV(1)),   ...
            figS.lineStyleDenseV{iLine},  'color', figS.colorM(iLine,:));

         hold off;
         xlabel(sprintf('Age  --  cohort %i',  cS.bYearV(iBy)));
         ylabel('Log wage');
         legend({'Quartic', 'Data'});
         output_so1.fig_format(fh, 'line');
      end
      output_so1.fig_save(['quartic_wage_cohort_', cS.schoolSuffixV{iSchool}],  saveFigures,  cS);
   end

end



%%  Make and plot cohort effects
if useCohDummies
   error('Not updated');
   % Cohort effects
   cohEffect_scM = zeros([cS.nSchool, cS.nCohorts]);

   for iSchool = 1 : cS.nSchool
      regrS = regrV{iSchool};
      cohEffect_scM(iSchool, regrS.cdIdxV) = regrS.cdBetaV;
   end

   if 1
      fig_new_so(saveFigures);
      hold on;
      for iSchool = 1 : cS.nSchool
         plot(cS.bYearV, cohEffect_scM(iSchool, :), cS.lineStyleDenseV{iSchool}, 'color', cS.colorM(iSchool,:));
      end
      hold off;
      xlabel('Year');
      ylabel('Cohort effect');
      legend(cS.schoolLabelV, 'location', 'southoutside', 'orientation', 'horizontal');
      figure_format_so(gca);
      save_fig_so('quartic_cohort_effects', saveFigures, [], cS);
   end
end


return;  % +++++ continue here


%%  Infer skill weights

% *****  Years with data (time dummies)

spYearV = cS.wageYearV(1) : cS.wageYearV(end);
year1 = 0;
year2 = 9999;
for iSchool = 1 : cS.nSchool
   regrS = regrV{iSchool};
   year1 = max([year1, spYearV(1),   regrS.tdYearV(1)]);
   year2 = min([year2, spYearV(end), regrS.tdYearV(end)]);
end
spYearV = year1 : year2;
ny      = length(spYearV);

fprintf('Years with skill prices: %i - %i \n', spYearV(1), spYearV(end));


% *******  Skill prices

skillPrice_stM = repmat(cS.missVal, [cS.nSchool, ny]);
for iSchool = 1 : cS.nSchool
   regrS = regrV{iSchool};
   skillPrice_stM(iSchool, :) = ...
      exp(regrS.tdBetaV(year1 - regrS.tdYearV(1) + (1 : ny)));
end



% ****** Aggr hours

tgS = var_load_so1(cS.vCalTargets, cS);
yrIdxV = find(tgS.aggrHoursS.yearV >= spYearV(1)  &  tgS.aggrHoursS.yearV <= spYearV(end));


% ******* Efficiency from cohort and experience effects

meanLPerHour_astM = repmat(cS.missVal, [ageMax, cS.nSchool, ny]);
for iSchool = 1 : cS.nSchool   
   for age = cS.workStartAgeV(iSchool) : ageMax
      for iy = 1 : ny
         bYear = byear_from_age_so(age, spYearV(iy), cS.ageInBirthYear);
         % Find nearest cohort with data
         [~, byIdx] = min(abs(bYear - cS.bYearV));
         meanLPerHour_astM(age, iSchool, iy) = exp(cohEffect_scM(iSchool, byIdx) + pred_saM(iSchool,age));
      end
   end
end


% *****  Compute skill weights

rhoCG = 1 - 1 / 3;
rhoHS = 1 - 1 / 6;

[muM, LS2M, meanEffSY2M] = ...
   ge_cal_weights_so1(spYearV(:), skillPrice_stM, tgS.aggrHoursS.hours_astM(:,:,yrIdxV), meanLPerHour_astM, rhoHS, rhoCG, cS);



%% Plot skill weights
if 1
   fig_new_so(saveFigures);
   hold on;
   for iSchool = 1 : cS.nSchool
      yV = log(muM(iSchool,:) ./ muM(cS.schoolHSG,:));
      plot(spYearV, yV - yV(1), cS.lineStyleDenseV{iSchool}, 'color', cS.colorM(iSchool,:));
   end
   
   hold off;
   xlabel('Year');
   ylabel('Log skill weight rel to HSG');
   figure_format_so(gca);
   save_fig_so('quartic_skillweight_rel', saveFigures, [], cS);
end


end