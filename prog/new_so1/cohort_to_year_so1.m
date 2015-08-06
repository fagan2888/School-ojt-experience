function [outM, out2M] = cohort_to_year_so1(in_ascM, bYearV, yearV, cS)
% Make a matrix by [age,school,cohort] into a matrix by 
% [age,school,year]
%{
Use nearest cohort where model does not have the cohort that produces the right age for a given year

IN:
   in_ascM(age,school,cohort)
   bYearV
      birth years for the cohorts

OUT:
   outM(age,school,year)
      using adjacent cohorts where needed
   out2M
      same without using adjacent cohorts

Checked: t_cohort_to_year_so1
%}
% ---------------------------------------------------------

%% Input check

[ageMax, ~, nc] = size(in_ascM);
nYr = length(yearV);
if cS.dbg > 10
   if ~v_check(in_ascM, 'f', [ageMax, cS.nSchool, nc], [], [])
      error_so1('Invalid', cS);
   end
   if ~v_check(bYearV, 'i', [nc, 1], 1900, 2020, [])
      error_so1('Invalid');
   end
end


%% Main

outM  = repmat(cS.missVal, [ageMax, cS.nSchool, nYr]);
out2M = outM;

for iy = 1 : nYr
   year1 = yearV(iy);
   
   % Age of each model cohort
   cohAgeV = age_from_year_so(bYearV, year1, cS.ageInBirthYear);

   for iSchool = 1 : cS.nSchool
      % Working age range
      ageRangeV = cS.demogS.workStartAgeV(iSchool) : ageMax;
      for age = ageRangeV(:)'
         % Find the cohort for this age
         %  If model has not cohort, use closest model cohort
         [~, iCohort] = min(abs(cohAgeV - age));
         outM(age,iSchool,iy) = in_ascM(age, iSchool, iCohort);
         
         % The same without using adjacent cohorts
         iCohort = find(cohAgeV == age);
         if ~isempty(iCohort)
            out2M(age,iSchool,iy) = in_ascM(age, iSchool, iCohort);
         end
      end
   end
end

if cS.dbg > 10
   if ~v_check(outM, 'f', [ageMax, cS.nSchool, nYr], [], [])
      error_so1('Invalid', cS);
   end
end

end