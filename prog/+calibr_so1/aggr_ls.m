function lSupply_stM = aggr_ls(meanLPerHour_ascM,  aggrHours_astM, cS)
% Compute aggregate labor supply for the model, by [school, year]
%{
Where model cohorts available: use that

IN:
   meanLPerHour_ascM(age, school, cohort)
      from simS; all model cohorts
      efficiency units supplied per hours worked
      only for modeled cohorts
   aggrHours_astM
      data: aggregate hours worked in each cell
      years in cS.wageYearV only

OUT:
   lSupply_stM(school, year)
      for cS.spS.spYearV

Checked: 
%}


%% Input check

% Years for which labor inputs must be constructed
yearV = cS.spS.spYearV(1) : cS.spS.spYearV(end);
ny = length(yearV);

if cS.dbg > 10
   if ~v_check(meanLPerHour_ascM, 'f', [cS.ageRetire, cS.nSchool, cS.nCohorts], 1e-3, 1e3, cS.missVal)
      error_so1('Invalid');
   end
   validateattributes(aggrHours_astM, {'double'}, ...
      {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', [cS.ageRetire, cS.nSchool, length(cS.wageYearV)]});
end


%% Hours worked for early / late years (no data)
% Assumed constant for now

% aggrHours_asxM = nan([cS.ageRetire, cS.nSchool, 2]);
aggrHours_asxM = aggrHours_astM(:, :, [1, end]);


%% Efficiency profiles for early / late cohorts (not modeled)

% Average the first and last 5 cohorts
meanLPerHour_asxM = nan(cS.ageRetire, cS.nSchool, 2);
for ix = 1 : 2
   if ix == 1
      icV = 1 : 5;
   else
      icV = cS.nCohorts - 5 + (1 : 5);
   end
   meanLPerHour_asxM(:, :, ix) = mean(meanLPerHour_ascM(:, :, icV), 3);
end

validateattributes(meanLPerHour_asxM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
   'size', [cS.ageRetire, cS.nSchool, 2]})


%% Construct aggregates

lSupply_stM = repmat(cS.missVal, [cS.nSchool, ny]);

% Age to copy
ageV = cS.age1 : cS.ageRetire;

for t = 1 : ny
   % Index into year dimension (wageYearV)
   year1 = yearV(t);
   yrIdx = year1 - cS.wageYearV(1) + 1;
   
   % Aggregate hours by [a, s]
   if yrIdx < 1
      % first year with data
      aggrHours_asM = aggrHours_asxM(ageV, :, 1);
   elseif year1 > cS.wageYearV(end)
      % last year with data
      aggrHours_asM = aggrHours_asxM(ageV, :, 2);
   else
      % year with data
      aggrHours_asM = aggrHours_astM(ageV, :, yrIdx);
   end
   
   % Birth year for each age
   bYearV = helper_so1.byear_from_age(ageV, year1, cS.ageInBirthYear);
   byIdxV = bYearV - cS.bYearV(1) + 1;
   
   % Efficiency per hour
   eff_asM = nan(size(aggrHours_asM));
   for age = cS.age1 : cS.ageRetire
      iAge = age - cS.age1 + 1;
      
      byIdx = byIdxV(iAge);
      if byIdx < 1
         eff_asM(iAge, :)  = meanLPerHour_asxM(iAge, :, 1);
      elseif byIdx > cS.nCohorts
         eff_asM(iAge, :)  = meanLPerHour_asxM(iAge, :, 2);
      else
         eff_asM(iAge, :)  = meanLPerHour_ascM(iAge, :, byIdx);
      end
   end
   
   % Labor supply (by spYearV)
   spYrIdx = yearV(t) - cS.spS.spYearV(1) + 1;
   % Zeros are values before work starts
   lSupply_asM = max(0, eff_asM) .* max(0, aggrHours_asM);
%       matrix_lh.m_oper(eff_asM, aggrHours_asM, '*', cS.missVal, cS.dbg);
   lSupply_stM(:, spYrIdx) = sum(lSupply_asM);
end


%% Output check
if cS.dbg > 10
   validateattributes(lSupply_stM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'positive', 'size', [cS.nSchool, ny]});   
end

end