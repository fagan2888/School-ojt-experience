function sim_stats(gNo, setNo)
% After calibration is done, simulate aggregate stats
%{
Some variables are simply copied from sim_histories
   Useful to have all aggr stats in one place

% OUT:
   spGrowthV(school)
      skill price growth rates, over data period
   sFracM(school, cohort)
   abilMeanM(school, cohort)
      E(theta * a | s)
   logH1MeanM(school, cohort)
      E(ln h1 | s), at start of life (not work)

   Age profiles, by [age, school, cohort]
      hMedianM, sTimeMedianM
         medians
      meanLogWageM
      meanLogEffM
         h * (1 - l / ell)

Change:

Checked: 2014-apr-8
%}
% ---------------------------------------------------

cS = const_so1(gNo, setNo);
nc = cS.nCohorts;
varS = param_so1.var_numbers;


%%  Load

% Age range to compute
ageMax = cS.ageRetire;

% Load calibration results
loadS = var_load_so1(varS.vCalResults, cS);
paramS = loadS.paramS;
outS = loadS.calDevS;
tgS  = loadS.tgS;
% Load simulated histories
simS  = var_load_so1(varS.vSimResults, cS);


%% Copy

% nameV = {'logWage_ascM'};
% for i1 = 1 : length(nameV)
%    saveS.(nameV{i1}) = outS.(nameV{i1});
% end



%% Regression of log wage on IQ, school dummies
% May be computed in cal_dev3. If not, run the same code here
% if any(simS.betaIqV ~= cS.missVal)
%    saveS.betaIqV = simS.betaIqV;
% else
%    saveS.betaIqV = zeros([cS.nCohorts, 1]);
%    for ic = 1 : cS.nCohorts
%       saveS.betaIqV(ic) = iq_regr_fixed_age_so1(simS.wageM(:,:,:,ic), simS.pSchoolM(:,:,ic), simS.iqM(:,ic), cS.iqAge, cS);
%    end
% end
% 
% if ~v_check(saveS.betaIqV, 'f', [cS.nCohorts, 1], -0.5, 2, [])
%    error_so1('Invalid');
% end


%%  Skill price growth rates
% Average over entire period with wage data
if 0
%    dwS = var_load_so1(varS.vAggrCpsStats, [], gNo, cS.dataSetNo);  
%    % Use constant weights
%    iCase = dwS.iAdj;
%    
   % Find common year range. Data are always the constraint
   year1 = max(cS.spS.spYearV(1),   cS.wageYearV(1));
   year2 = min(cS.spS.spYearV(end), cS.wageYearV(end));
   saveS.spGrowthYearV = [year1, year2];
   dy = year2 - year1;
%    
%    idxV = [year1, year2] - dwS.yearV(1) + 1;
%    % always use mean log? Probably should use median +++
%    saveS.spDataGrowthV  = (dwS.meanLogWageSchoolM(:,idxV(2),iCase) - dwS.meanLogWageSchoolM(:,idxV(1),iCase)) ./ dy;

   % Data
   idxV = [year1, year2] - cS.wageYearV(1) + 1;
   saveS.spDataGrowthV = (tgS.logWage_stM(:,idxV(2)) - tgS.logWage_stM(:,idxV(1))) ./ dy;
   
   idxV = [year1, year2] - cS.spS.spYearV(1) + 1;
   saveS.spModelGrowthV = (log(saveS.skillPrice_stM(:,idxV(2))) - log(saveS.skillPrice_stM(:,idxV(1)))) ./ dy;  

   if cS.dbg > 10
      if ~v_check(saveS.spDataGrowthV, 'f', [cS.nSchool, 1], -0.3, 0.3, [])
         error_so1('Invalid sp growth', cS);
      end
      if ~v_check(saveS.spModelGrowthV, 'f', [cS.nSchool, 1], -0.3, 0.3, [])
         error_so1('Invalid sp growth', cS);
      end
   end
end


%%   Stats by [age, school, cohort]

size_ascV = [ageMax, cS.nSchool, nc];
saveS.hMedian_ascM = zeros([ageMax, cS.nSchool, nc]);
saveS.sTimeMedian_ascM = cS.missVal .* ones([ageMax, cS.nSchool, nc]);
% % Mean log labor efficiency per hour = h * (1 - l) / \ell
% saveS.meanLogEffM = cS.missVal .* ones([ageMax, cS.nSchool, nc]);
% saveS.meanEffM    = cS.missVal .* ones([ageMax, cS.nSchool, nc]); 
% % Mean log h
% saveS.meanLogHM = cS.missVal .* ones([ageMax, cS.nSchool, nc]);
% saveS.stdLogHM  = cS.missVal .* ones([ageMax, cS.nSchool, nc]);
% % Mean effective ability by [school, cohort]
% saveS.abilMean_scM = zeros([cS.nSchool, nc]);
% saveS.abilStd_scM  = zeros([cS.nSchool, nc]);
% % h1 : at cS.age1
% saveS.logH1Mean_scM = repmat(cS.missVal, [cS.nSchool, nc]);
% saveS.logH1Std_scM  = repmat(cS.missVal, [cS.nSchool, nc]);
% % Avg fraction of time spent studying
% saveS.meanSTimeFracM = zeros([cS.nSchool, nc]);
% saveS.meanSTimeFracV = zeros([nc, 1]);
% % Truncated mean wage (not log)
% saveS.meanWageM = repmat(cS.missVal, [ageMax, cS.nSchool, nc]);
% % Std dev of Log(A) / (1-alpha)
% saveS.stdLogProductM = zeros([cS.nSchool, nc]);
% % h growth first 20 years of work
% saveS.hGrowthM = zeros([cS.nSchool, nc]);
% saveS.hGrowthV = zeros([nc, 1]);

% correlation (a, ln h1)
saveS.corrAbilH1M = zeros([cS.nSchool, nc]);

% Loop over cohorts
for ic = 1 : nc
   for iSchool = 1 : cS.nSchool
      % Weight = prob of choosing this s
      wtV = simS.pSchool_iscM(:, iSchool, ic);
      wtV = wtV ./ sum(wtV);
      
      ageRangeV = cS.workStartAgeV(iSchool) : ageMax;
      % Time endowment by age in range
      tEndowV = paramS.tEndow_ascM(ageRangeV, iSchool, ic);
      
      % People in the school group
      hM = simS.h_itscM(:, ageRangeV, iSchool, ic);
      sTimeM = simS.sTime_itscM(:, ageRangeV, iSchool, ic);
      
      
      % *****  Stats by cohort
      
      logH1V = log(simS.h1_icM(:, ic));
      abilV  = simS.abil_icM(:,ic) .* paramS.theta;
%       pProductV = ojt_productivity_so1(simS.abilM(:,ic), iSchool, ic, paramS, cS);
      
      % A ^ (1/(1-alpha))  determines steady state h
%       saveS.stdLogProductM(iSchool, ic) = std_w(log(pProductV) ./ (1 - paramS.alphaV(iSchool)), wtV, cS.dbg);
      
      % Correlation (ability , ln h1)
      [~, saveS.corrAbilH1M(iSchool, ic)] = distrib_lh.cov_w(logH1V, abilV, wtV, cS.missVal, cS.dbg);
      
%       [saveS.abilStd_scM(iSchool,ic),  saveS.abilMean_scM(iSchool, ic)]  = std_w(abilV,  wtV, cS.dbg);
%       [saveS.logH1Std_scM(iSchool,ic), saveS.logH1Mean_scM(iSchool, ic)] = std_w(logH1V, wtV, cS.dbg);
      
%       % Ratio of avg study time to time endowment. First 20 years of career
%       maxExper = cS.wageGrowthExperV(2) - cS.wageGrowthExperV(1) + 1;
%       xM  = sTimeM(:, cS.wageGrowthExperV(1) : cS.wageGrowthExperV(2));
%       wtM = wtV * ones([1, maxExper]);
%       meanSTime = sum(xM(:) .* wtM(:)) ./ sum(wtM(:));
%       meanEndow = mean(tEndowV(cS.wageGrowthExperV(1) : cS.wageGrowthExperV(2)));
%       saveS.meanSTimeFracM(iSchool, ic) = meanSTime / meanEndow;
      
      % ******  Stats by age
      for iAge = 1 : length(ageRangeV)
         age = ageRangeV(iAge);
         
         % Mean log h
%          [saveS.stdLogHM(age,iSchool,ic), saveS.meanLogHM(age,iSchool,ic)] = std_w(log(hM(:,iAge)), wtV, cS.dbg);
         
         % Mean log labor efficiency. 
%          effV = hM(:,iAge) .* (tEndowV(iAge) - sTimeM(:,iAge)) ./ max(1e-4, tEndowV(iAge));
%          [saveS.stdLogEffM(age,iSchool,ic), saveS.meanLogEffM(age,iSchool,ic)] = std_w(log(effV), wtV, cS.dbg);
         
%          saveS.meanEffM(age,iSchool,ic) = sum(effV .* wtV);
         
         saveS.hMedianM(age,iSchool,ic) = distrib_lh.weighted_median(hM(:,iAge), wtV, cS.dbg);
         saveS.sTimeMedianM(age,iSchool,ic) = distrib_lh.weighted_median(sTimeM(:,iAge), wtV, cS.dbg);
         
         % Mean wage (model stats are not truncated)
%          saveS.meanWageM(age,iSchool,ic) = sum(simS.wageM(:,age,iSchool,ic) .* wtV) ./ sum(wtV);      
      end
      
%       % Avg growth of h over 1st 20 years
%       ageV = ageRangeV(1) - 1 + cS.wageGrowthExperV;
%       saveS.hGrowthM(iSchool,ic) = saveS.meanLogHM(ageV(2),iSchool,ic) - saveS.meanLogHM(ageV(1),iSchool,ic);
   end
   
%    % avg study time by cohort (across school groups)
%    saveS.meanSTimeFracV(ic) = sum(saveS.meanSTimeFracM(:,ic) .* saveS.sFracM(:,ic));
%    
%    saveS.hGrowthV(ic) = sum(saveS.hGrowthM(:,ic) .* saveS.sFracM(:,ic));
end



var_save_so1(saveS, varS.vSimStats, cS);



%% Self test
if cS.dbg > 10
   validateattributes(saveS.hMedian_ascM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', size_ascV})
end



end