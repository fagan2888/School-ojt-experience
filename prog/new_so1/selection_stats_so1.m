function selection_stats_so1(gNo, setNo)
% Compute wage stats with random school assignment
%{
Each person chooses each school level with the same probability. Then follows the optimal investment
strategy for that level

Checked: +++
%}
% ------------------------------------------------

cS = const_so1(gNo, setNo);



%% Compute aggregate stats w/ random school choice
% Constant composition weights

% calS   = var_load_so1(cS.vCalResults, cS);
tgS    = var_load_so1(cS.vCalTargets, [], gNo, cS.dataSetNo);
simS   = var_load_so1(cS.vSimResults, cS);

yearV  = cS.wageYearV(1) : cS.wageYearV(end);
ageMin = cS.aggrAgeRangeV(1);
ageMax = cS.aggrAgeRangeV(end);

% Take out school selection
pSchoolM = (1 ./ cS.nSchool) .* ones([cS.gS.nSim, cS.nSchool, cS.nCohorts]);


% Profiles to use for cohorts before / after 1st modeled cohorts
   if 1  % +++++ trying alternative comp of non modeled cohorts
      logWageSS_iascM = repmat(cS.missVal, [cS.gS.nSim, cS.ageRetire, cS.nSchool, 2]);
      logWageSS_iascM(:,:,:,1) = log_lh(simS.wageM(:,:,:,1), cS.missVal);
      logWageSS_iascM(:,:,:,2) = log_lh(simS.wageM(:,:,:,end), cS.missVal);
      pSchoolSS_iscM  = (1 ./ cS.nSchool) .* ones([cS.gS.nSim, cS.nSchool, 2]);
   else
      error('not implemented');
   end


% Outputs are by [ind, age, school, year]
[logWageM, wtM] = cs_data_so1(log_lh(simS.wageM, cS.missVal), pSchoolM, ...
   logWageSS_iascM, pSchoolSS_iscM,  tgS.aggrDataWt_asM, yearV, ageMin, ageMax, cS);

% Compute aggr stats from sim histories
%  Year range automatically matches targets
aggrS = aggr_stats_so1(logWageM, wtM, yearV, ageMin, ageMax, cS);

var_save_so1(aggrS, cS.vAggrStatsNoSelection, cS);


end