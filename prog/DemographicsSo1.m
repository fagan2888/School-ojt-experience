%{
Model demographics
To update a field: directly update in structure and call "derived"
%}
classdef DemographicsSo1
   properties
      cohDefStr
      bYearV
      bYearLbV
      bYearUbV
      nCohorts
      byShowV
      resultCohort   % show this cohort if only 1 is shown
      cohStrV
      
      age1
      ageRetire
      workStartAgeV
      schoolLengthV
      % For each cohort / school: first and last years of work
      workYear1_scM
      workYear2_scM
      
      % Constants
      ageInBirthYear
   end
   
   
   methods
      % ********  Constructor
      function dS = DemographicsSo1(age1, ageRetire, workStartAgeV, cohDefStr)
         dS.cohDefStr = cohDefStr;
         dS.workStartAgeV = workStartAgeV;
         dS.age1 = age1;
         dS.ageRetire = ageRetire;
         dS.ageInBirthYear = 1;
         dS = dS.derived;
      end
      
      
      % *******  Set derived properties
      function dS = derived(dS)
         dS.schoolLengthV = dS.workStartAgeV - dS.age1;

         [dS.bYearV, bYearWindow, dS.byShowV, ~, dS.cohStrV] = param_so1.cohort_defs(dS.cohDefStr);
         dS.bYearLbV = dS.bYearV - bYearWindow;
         dS.bYearUbV = dS.bYearV + bYearWindow;
         dS.nCohorts = length(dS.bYearV);
         [~, dS.resultCohort] = min(abs(dS.bYearV - 1950));
         
         nSchool = length(dS.schoolLengthV);
         dS.workYear1_scM = zeros([nSchool, dS.nCohorts]);
         dS.workYear2_scM = zeros([nSchool, dS.nCohorts]);
         for iSchool = 1 : nSchool
            dS.workYear1_scM(iSchool,:) = dS.bYearV + dS.workStartAgeV(iSchool) - dS.ageInBirthYear;
            dS.workYear2_scM(iSchool,:) = dS.bYearV + dS.ageRetire - dS.ageInBirthYear;
         end
         
         dS.validate;
      end
      
      
      % ********  Validate
      function validate(dS)
         validateattributes(dS.age1, {'double'}, {'finite', 'nonnan', 'nonempty', 'integer', 'scalar', ...
            '>=', 15, '<=', 19})
         validateattributes(dS.ageRetire, {'double'}, {'finite', 'nonnan', 'nonempty', 'integer', 'scalar', ...
            '>', 60, '<', 70})
         validateattributes(dS.workStartAgeV, {'double'}, {'finite', 'nonnan', 'nonempty', 'integer', '>=', 15, ...
            '<=', 30})
         validateattributes(dS.schoolLengthV, {'double'}, {'finite', 'nonnan', 'nonempty', 'integer', '>=', 0})
      end
   end
   
end