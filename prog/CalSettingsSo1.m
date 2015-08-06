classdef CalSettingsSo1
   % Defines how calibration is done
   
   properties
      % What are calibration targets?
      tgGSkillWeight
      tgIq
      tgBetaIq
      tgBetaIqExper
      
      % Deviations from age wage profiles
      profileDevAgeRangeV
      % Drop first N years after work start from comparison
      profileDevDropYears
   end
   
   methods
      % *********  Constructor
      function calS = CalSettingsSo1
      % Default calibration targets

         % Target constant growth of all skill weights
         calS.tgGSkillWeight = false;

         % gS.calWtIQa = 0;
         % Target IQ percentiles
         calS.tgIq = false;
         %  Tg beta iq
         calS.tgBetaIq = false;
         %  Tg betaIQ by experience
         calS.tgBetaIqExper = false;
         
         
         % Deviations from age wage profiles
         calS.profileDevAgeRangeV = [20, 60];
         calS.profileDevDropYears = 2;
      end
   end

end
      
