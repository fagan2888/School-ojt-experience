function [logWageM, wtM] = cs_data_so1(indLogWage_iascM, pSchool_iscM, indLogWageSS_iascM, pSchoolSS_iscM, ...
   dataWt_asM, yearV, ageMin, ageMax, cS)
% Make a cross-sectional dataset from simulated histories
%{
This is used to compute cross-sectional stats, exactly as they are computed in the data
The stats use fixed [age, school] weights

Each year has cS.gS.nSim * nAge persons
Only ages in ageMin:ageMax have data filled in

Uses steady state cohorts to fill in non-modeled cohorts

IN:
   indLogWage_iascM(ind, age, school, cohort)
      could be any other variable that is indexed the same way
   pSchool_iscM(ind, school, cohort)
   indLogWageSS_iascM, pSchoolSS_iscM
      the same for steady states (initial and terminal)
      for filling in non-modeled cohorts
   dataWt_asM(age, school)
      total weight of persons in an age/school cell in a year
   yearV
      years for which to return data
   ageMin, ageMax
      typically cS.aggrAgeRangeV

OUT:
   logWageM(ind, age, school, year)
   wtM(ind, age, school, year)

Checked: 2014-apr-8
%}
% ----------------------------------------------

%% Input check

nYr = length(yearV);
nBy = length(cS.bYearV);
if cS.dbg > 10
   if ~v_check(indLogWage_iascM, 'f', [cS.gS.nSim, cS.ageRetire, cS.nSchool, nBy], [], [])
      error_so1('Invalid wageM', cS);
   end
   if ~v_check(pSchool_iscM, 'f', [cS.gS.nSim, cS.nSchool, nBy], 0, 1)
      error_so1('Invalid pSchool_iscM', cS);
   end
   if ~v_check(indLogWageSS_iascM, 'f', [cS.gS.nSim, cS.ageRetire, cS.nSchool, 2], [], [])
      error_so1('Invalid wageM', cS);
   end
   if ~v_check(pSchoolSS_iscM, 'f', [cS.gS.nSim, cS.nSchool, 2], 0, 1)
      error_so1('Invalid pSchool_iscM', cS);
   end
   % Weights can be 0 for ages before work starts
   if ~v_check(dataWt_asM, 'f', [cS.ageRetire, cS.nSchool], 0, 1)
      error_so1('Invalid weights', cS);
   end
end


%% Loop over years

sizeV = [cS.gS.nSim, ageMax, cS.nSchool, nYr];
logWageM  = repmat(cS.missVal, sizeV);
wtM       = zeros(sizeV);

for iy = 1 : nYr
   year1 = yearV(iy);
   
   % Age of each model cohort
   % cohAgeV = age_from_year_so(cS.bYearV, year1, cS.ageInBirthYear);
   
   for iSchool = 1 : cS.nSchool
      % Working age range
      ageRangeV = max(ageMin, cS.workStartAgeV(iSchool)) : ageMax;
      % Birth year for each age
      bYearV    = byear_from_age_so(ageRangeV, year1, cS.ageInBirthYear);
      
      for iAge = 1 : length(ageRangeV)
         age = ageRangeV(iAge);
         if bYearV(iAge) < cS.bYearLbV(1)
            % Early cohorts: use initial SS
            iSS = 1;
         elseif bYearV(iAge) > cS.bYearUbV(cS.nCohorts)
            % Late cohorts: use terminal SS
            iSS = 2;
         else
            iSS = -1;
         end
         
         if iSS > 0
            % Use steady state iSS
            logWageV = indLogWageSS_iascM(:,age,iSchool,iSS);
            wtV = pSchoolSS_iscM(:, iSchool, iSS);
         else
            % Find the cohort for this age
            %  If model has not cohort, use closest model cohort
            [~, iCohort] = min(abs(bYearV(iAge) - cS.bYearV));
            logWageV = indLogWage_iascM(:, age, iSchool, iCohort);
            wtV = pSchool_iscM(:, iSchool, iCohort);
         end
         
         logWageM(:, age, iSchool,iy) = logWageV;
         
         % Adjust all weights to match data targets
         wtM(:, age, iSchool,iy) = wtV ./ sum(wtV) .* dataWt_asM(age, iSchool);
      end
   end
end


%% Self-test
if cS.dbg > 10
   if ~v_check(logWageM, 'f', sizeV, [], [])
      error_so1('Invalid log wage', cS);
   end
   if ~v_check(wtM, 'f', sizeV, 0, [])
      error_so1('Invalid wts', cS);
   end
end
   
   
end