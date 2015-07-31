function aggr_stats_save_so1(gNo, setNo)
% Compute and save aggregate wage stats
%{
Need to be consistent here. Use SS solutions to fill in non-modeled cohorts

All aggregate stats use time invariant data hours(age, school) as weights!
These cannot be used to compute equilibrium objects!

Checked: 2014-apr-8
%}
% -----------------------------------------------

cS = const_so1(gNo, setNo);

% Compute resid std
% doStdResid = 1;
tgS = var_load_so1(cS.vCalTargets, [], gNo, cS.dataSetNo);
yearV = cS.wageYearV(1) : cS.wageYearV(end); 
% Age range to use for aggregate stats
ageMin = cS.aggrAgeRangeV(1);
ageMax = cS.aggrAgeRangeV(end);


% Load
% calS = var_load_so1(cS.vCalResults, cS);
simS = var_load_so1(cS.vSimResults, cS);
ssV  = var_load_so1(cS.vSteadyStates, cS);
paramS = var_load_so1(cS.vParams, cS);


%% Collect steady state matrices

ssCohortV = [1, cS.nCohorts];
logWageSS_iascM = repmat(cS.missVal, [cS.gS.nSim, cS.ageRetire, cS.nSchool, 2]);
sTimeSS_iascM   = repmat(cS.missVal, [cS.gS.nSim, cS.ageRetire, cS.nSchool, 2]);
tEndowSS_iascM  = repmat(cS.missVal, [cS.gS.nSim, cS.ageRetire, cS.nSchool, 2]);
pSchoolSS_iscM  = repmat(cS.missVal, [cS.gS.nSim, cS.nSchool, 2]);
for iSS = 1 : 2
   logWageSS_iascM(:,:,:,iSS) = log_lh(ssV{iSS}.cohS.wageM, cS.missVal);
   pSchoolSS_iscM(:,:,iSS) = ssV{iSS}.cohS.pSchoolM;
   sTimeSS_iascM(:,:,:,iSS)  = ssV{iSS}.cohS.sTimeM;
   for iSchool = 1 : cS.nSchool
      tEndowSS_iascM(:,:,iSchool,iSS) = ones([cS.gS.nSim,1]) * paramS.tEndow_ascM(:,iSchool,ssCohortV(iSS))';
   end
end

   if 1  % +++++ trying alternative comp of non modeled cohorts
      logWageSS_iascM(:,:,:,1) = log_lh(simS.wageM(:,:,:,1), cS.missVal);
      logWageSS_iascM(:,:,:,2) = log_lh(simS.wageM(:,:,:,end), cS.missVal);
   end



%%  Make sim histories into data by year, with weights matching aggrDataWtM


% Outputs are by [ind, age, school, year]
[logWageM, wtM] = cs_data_so1(log_lh(simS.wageM, cS.missVal), simS.pSchoolM, logWageSS_iascM, pSchoolSS_iscM, ...
   tgS.aggrDataWt_asM, yearV, ageMin, ageMax, cS);

% Compute aggr stats from sim histories
%  Year range automatically matches targets
aggrS = aggr_stats_so1(logWageM, wtM, yearV, ageMin, ageMax, cS);

var_save_so1(aggrS, cS.vAggrStats, cS);



%%  Average study time by year

% Study time by [ind, age, school, year]
[sTimeM, wtM] = cs_data_so1(simS.sTimeM, simS.pSchoolM, sTimeSS_iascM, pSchoolSS_iscM, ...
   tgS.aggrDataWt_asM, yearV, ageMin, ageMax, cS);

% Time endowments
tEndowM = zeros(size(simS.sTimeM));
for iCohort = 1 : cS.nCohorts
   for iSchool = 1 : cS.nSchool
      tEndowM(:,:,iSchool,iCohort) = ones([cS.gS.nSim,1]) * paramS.tEndow_ascM(:,iSchool,iCohort)';
   end
end
% Outputs are by [ind, age, school, year]
tEndowM = cs_data_so1(tEndowM, simS.pSchoolM, tEndowSS_iascM, pSchoolSS_iscM, ...
   tgS.aggrDataWt_asM, yearV, ageMin, ageMax, cS);

% Years with wage data
nYr = length(yearV);
saveS.avgSTime_tV   = zeros([nYr, 1]);
saveS.avgTEndow_tV  = zeros([nYr, 1]);

% Loop over years
for iy = 1 : nYr
   % Make a matrix of wages and weights by [ind, age, school]
   yrSTimeM  = sTimeM(:, ageMin:ageMax, :, iy);
   yrTEndowM = tEndowM(:, ageMin:ageMax, :, iy);
   yrWtM     = wtM(:, ageMin:ageMax, :, iy) .* (yrSTimeM >= 0);
   
   idxV = find(yrWtM > 0);
   tWt = sum(yrWtM(idxV));
   saveS.avgSTime_tV(iy)  = sum(yrSTimeM(idxV)  .* yrWtM(idxV)) ./ tWt;
   saveS.avgTEndow_tV(iy) = sum(yrTEndowM(idxV) .* yrWtM(idxV)) ./ tWt;
end

if cS.dbg > 10
   if ~v_check(saveS.avgSTime_tV, 'f', [nYr, 1], 0, max(tEndowM(:)), [])
      error_so1('Invalid');
   end
   if ~v_check(saveS.avgTEndow_tV, 'f', [nYr, 1], 0, max(tEndowM(:)), [])
      error_so1('Invalid');
   end
end

saveS.yearV = yearV;
var_save_so1(saveS, cS.vAggrSTime, cS);


end