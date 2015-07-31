function aggr_wage_stats_show_so1(saveFigures, gNo, setNo)
% Show wage stats model / data
%{
Uses aggregate cps wage stats

Checked: 2014-apr-8
%}
% ---------------------------------------------------

cS = const_so1(gNo, setNo);
cdS = const_so1(gNo, cS.dataSetNo);

% Data stats
tgS = var_load_so1(cS.vCalTargets, cdS);

% Aggr data stats
% use cal targets where possible
dataS = var_load_so1(cS.vAggrCpsStats, cdS);

% Compute alternative mean log wage series, from cells
% wageS = aggr_stats_from_cells_so1(tgS.wageM, tgS.aggrDataWtM, cS);


% Model stats
simStatS = var_load_so1(cS.vSimStats, cS);
skillPrice_stM = simStatS.skillPrice_stM;

% Aggr stats from sim histories
mS = var_load_so1(cS.vAggrStats, cS);
mYearV = mS.yearV;

% Check that data and model conform
% if max(abs(dataS.wagePctV(:) - mS.wagePctV(:)) > 0.01)
%    error('Model and data do not conform');
% end


%% Std log wage by school
if 0
   error('Not updated');
   % Figure out common axis range
   xV = mS.stdLogWage_stM;
   xV = xV(xV ~= cS.missVal);
   yV = dataS.stdLogWageSchoolM(:,:,dataS.iAdj);
   yV = yV(yV ~= cS.missVal);
   [yMin, yMax] = fig_yrange_lh([xV(:); yV(:)]);
   
   for iSchool = 1 : cS.nSchool
      fig_new_so(saveFigures);
      hold on;
      
      for i1 = 1 : 2
         iLine = i1;
         if i1 == 1
            % Model
            xV = mS.stdLogWage_stM(iSchool, :);
            xYearV = mYearV;
         elseif i1 == 2
            % data
            xV = dataS.stdLogWageSchoolM(iSchool,:,dataS.iAdj);
            xYearV = dataS.yearV;
         else
            error('Invalid');
         end
         
         xV = xV(:);
         idxV = find(xV ~= cS.missVal);
         plot(xYearV(idxV), xV(idxV),  cS.lineStyleDenseV{iLine}, 'color', cS.colorM(iLine,:));
      end
      
      hold off;
      xlabel('Year');
      ylabel('Std log wage');
      legend({'Model', 'Data'}, 'location', 'best');
      axis_range_lh([NaN, NaN, yMin, yMax]);
      figure_format_so(gca);
      save_fig_so(['aggr_stdlog_', cS.schoolSuffixV{iSchool}], saveFigures, [], cS);   
   end   
end




%% College premium young / old
% There is a difference between coll prem computed from ind data and computed from cell data
% Needs to be reconciled
if 1
   ngAge = size(cS.youngOldAgeM, 1);
   nCases = 2;
   legendV = {'Model', 'Data'};
   
   data_atM    = tgS.collPrem_YoungOldYearM;
   if cS.useMedianWage == 1
      model_atM   = mS.medianCollPrem_YoungOld_tM;
   else
      model_atM   = mS.collPrem_YoungOld_tM;
   end
   if ~v_check(data_atM, 'f', size(model_atM), 0, 2, cS.missVal)
      error_so1('Invalid');
   end
   
   % Figure out common axis range
   [yMin, yMax] = fig_yrange_lh([model_atM(model_atM ~= cS.missVal); data_atM(data_atM ~= cS.missVal)]);

   % One plot per age
   for iAge = 1 : ngAge
      fig_new_so(saveFigures);
      hold on;
      iLine = 0;
      for iCase = 1 : nCases
         if iCase == 1
            % Model
            premV = model_atM(iAge,  :);
         elseif iCase == 2
            % Data: from individual data
            premV = data_atM(iAge, :);
         else
            error('Invalid');
         end
         premV = premV(:);

         idxV = find(premV ~= cS.missVal);
         iLine = iLine + 1;
         plot(cS.wageYearV(idxV),  premV(idxV),  cS.lineStyleDenseV{iLine}, 'color', cS.colorM(iLine,:));
      end
      hold off;

      xlabel('Year');
      ylabel('College wage premium');
      legend(legendV,  'location', 'best');
      axis_range_lh([NaN, NaN, yMin, yMax]);
      figure_format_so(gca);
      save_fig_so(sprintf('aggr_coll_prem_age%i', iAge), saveFigures, [], cS);   
   end
end



%% College premium
if 1
   nLines = 3;
   legendV = cell([nLines, 1]);
   fig_new_so(saveFigures);
   hold on;

   if cS.useMedianWage == 1
      model_stM  = mS.logMedianWage_stM;
   else
      model_stM = mS.meanLogWage_stM;
   end
   if ~v_check(model_stM, 'f', [cS.nSchool, length(cS.wageYearV)], -10, 10, cS.missVal)
      error_so1('Invalid')
   end

   
   for iLine = 1 : nLines
      if iLine == 1
         % Model
         if cS.useMedianWage == 1
            cgV  = model_stM(cS.schoolCG,  :);
            hsgV = model_stM(cS.schoolHSG, :);
         else
            cgV  = mS.meanLogWage_stM(cS.schoolCG,  :);
            hsgV = mS.meanLogWage_stM(cS.schoolHSG, :);
         end
         legendV{iLine} = 'Model';
      elseif iLine == 2
         % Data: computed from cell means
         cgV  = tgS.logWage_stM(cS.schoolCG, :);
         hsgV = tgS.logWage_stM(cS.schoolHSG, :);
         legendV{iLine} = 'Data';
      elseif iLine == 3
         % Model skill prices
         %  that coll prem grows somewhat faster; reason is discrepancy between skill prices from
         %  aggr cps stats and from cells by [cohort, age, school] +++
         idxV  = cS.wageYearV - cS.spS.spYearV(1) + 1;
         cgV   = log(skillPrice_stM(cS.schoolCG, idxV));
         hsgV  = log(skillPrice_stM(cS.schoolHSG, idxV));
         % Scale is arbitrary
         cgV   = cgV  - cgV(1)  + tgS.logWage_stM(cS.schoolCG, 1);
         hsgV  = hsgV - hsgV(1) + tgS.logWage_stM(cS.schoolHSG, 1);
         legendV{iLine} = 'Skill prices';
%       elseif iLine == 4
%          % Data
%          cgV  = dataS.meanLogWageSchoolM(cS.schoolCG,  :, dataS.iAdj);
%          hsgV = dataS.meanLogWageSchoolM(cS.schoolHSG, :, dataS.iAdj);
%          yearV = dataS.yearV;
%          legendV{iLine} = 'Data 2';
%       elseif iLine == 5
%          % Model: computed from cell means (does not make a difference)
%          cgV  = simStatS.meanLogWage_stM(cS.schoolCG, :);
%          hsgV = simStatS.meanLogWage_stM(cS.schoolHSG, :);
%          yearV = cS.wageYearV;
%          legendV{iLine} = 'Model 2';
      else
         error('Invalid');
      end
      cgV = cgV(:);
      hsgV = hsgV(:);
   
      idxV = find(cgV ~= cS.missVal  &  hsgV ~= cS.missVal);
      plot(cS.wageYearV(idxV),  cgV(idxV) - hsgV(idxV),  cS.lineStyleDenseV{iLine}, 'color', cS.colorM(iLine,:));
   end
   hold off;
   xlabel('Year');
   ylabel('College wage premium');
   legend(legendV,  'location', 'best');
   figure_format_so(gca);
   save_fig_so('aggr_coll_prem', saveFigures, [], cS);
end



%% Mean log wage
if 1
   fig_new_so(saveFigures);
   hold on;
   iLine = 1;
   plot(mYearV, mS.meanLogWage_tV, cS.lineStyleDenseV{iLine}, 'color', cS.colorM(iLine,:));
   iLine = iLine + 1;
   idxV = find(dataS.meanLogWageM(:,2) ~= cS.missVal);
   plot(dataS.yearV(idxV), dataS.meanLogWageM(idxV,2) - log(cS.wageScale), cS.lineStyleDenseV{iLine}, 'color', cS.colorM(iLine,:));
   
   hold off;
   xlabel('Year');
   ylabel('Mean log wage');
   legend({'Model', 'Data'},  'location', 'best');
   figure_format_so(gca);
   save_fig_so('aggr_mean_log_wage', saveFigures, [], cS);
end




end