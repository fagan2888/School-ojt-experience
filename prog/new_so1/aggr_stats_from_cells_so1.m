function saveS = aggr_stats_from_cells_so1(in_ascM, wt_asM, cS)
% Compute aggregate wage stats from [age, school, cohort] cell data
%{
Cohorts are cS.demogS.bYearV

IN
   in_ascM(age, school, cohort)
      e.g. tgS.wageM
   wt_asM(age, school)
      e.g. tgS.aggrDataWtM

OUT
   indexed by cS.wageYearV
   out_stM(school, year)
      average of in_ascM using fixed weights in each year
   out_YoungOld_stM
      average of in_ascM using fixed weights
      for young / middle /old
   collPrem_YoungOldYearM(age, year)
      college premium young / middle / old, by year
%}
% -----------------------------------------------------------

nBy = length(cS.demogS.bYearV);
ageMax = size(in_ascM, 1);
% Indexed by cS.wageYearV
nYr = length(cS.wageYearV);


%% Input check
if cS.dbg > 10
   if ~v_check(in_ascM, 'f', [ageMax, cS.nSchool, nBy], [], [])
      error('Invalid');
   end
   if ~v_check(wt_asM, 'f', [cS.demogS.ageRetire, cS.nSchool], 0, 1)
      error('Invalid');
   end
end


%% *****  Stats by [school, year]

% Age range consistent with other computation of aggr stats
ageRangeV = cS.aggrAgeRangeV(1) : cS.aggrAgeRangeV(2);

saveS.out_stM = repmat(cS.missVal, [cS.nSchool, nYr]);

% by young / old (def as for college premium)
ngAge = size(cS.youngOldAgeM, 1);
saveS.out_YoungOld_stM = repmat(cS.missVal, [ngAge, cS.nSchool, nYr]);

for iy = 1 : nYr
   year1 = cS.wageYearV(iy);
   
   % Age of each model cohort
   cohAgeV = age_from_year_so(cS.demogS.bYearV, year1, cS.ageInBirthYear);
   
   for iSchool = 1 : cS.nSchool
      % Data by age for this year
      data_aV = repmat(cS.missVal, [cS.demogS.ageRetire, 1]);
      for age = ageRangeV(:)'
         % Find the cohort for this age
         %  If model has not cohort, use closest model cohort
               % this could cause trouble with reused random vars +++
               % important: this uses cohort 1 for most ages in early years +++
         [~, iCohort] = min(abs(cohAgeV - age));
         
         data_aV(age) = in_ascM(age, iSchool, iCohort);
      end
      % Weights: constant composition cell weights
      wtV = wt_asM(ageRangeV, iSchool);
      saveS.out_stM(iSchool, iy) = sum(data_aV(ageRangeV) .* wtV) ./ sum(wtV);
      
      % *** Mean by [young/middle/old, year]
      for i1 = 1 : ngAge
         % Ages to use
         age2V = cS.youngOldAgeM(i1, 1) : cS.youngOldAgeM(i1, 2);
         wtV = wt_asM(age2V, iSchool);
         saveS.out_YoungOld_stM(i1, iSchool, iy) = sum(data_aV(age2V) .* wtV) ./ sum(wtV);
      end
   end
end

if cS.dbg > 10
   if ~v_check(saveS.out_stM, 'f', [cS.nSchool, nYr], min(in_ascM(:)), max(in_ascM(:)), [])
      error_so1('Invalid');
   end
   if ~v_check(saveS.out_YoungOld_stM, 'f', [ngAge, cS.nSchool, nYr], min(in_ascM(:)), max(in_ascM(:)), [])
      error_so1('Invalid');
   end
end


%% College premium young old

saveS.collPrem_YoungOldYearM = repmat(cS.missVal, [ngAge, nYr]);
for i1 = 1 : ngAge
   cgV  = saveS.out_YoungOld_stM(i1, cS.schoolCG, :);
   hsgV = saveS.out_YoungOld_stM(i1, cS.schoolHSG, :);
   idxV = find(cgV ~= cS.missVal  &  hsgV ~= cS.missVal);
   saveS.collPrem_YoungOldYearM(i1, idxV) = cgV(idxV) - hsgV(idxV);
end

if ~v_check(saveS.collPrem_YoungOldYearM, 'f', [ngAge, nYr], -100, 100, cS.missVal)
   error_so1('Invalid');
end


%% Aggregate college premium by year

saveS.collPrem_tV = repmat(cS.missVal, [nYr, 1]);

cgV  = saveS.out_stM(cS.schoolCG, :);
hsgV = saveS.out_stM(cS.schoolHSG, :);
idxV = find(cgV ~= cS.missVal  &  hsgV ~= cS.missVal);
saveS.collPrem_tV(idxV) = cgV(idxV) - hsgV(idxV);



end