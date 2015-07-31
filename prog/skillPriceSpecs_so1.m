classdef skillPriceSpecs_so1
% Restrictions on skill prices

properties (Constant)
   sbtcYearStrV = {'wageYears', 'spYears'};
   beforeSampleTypeV = {'constGrowth'};
   afterSampleTypeV  = {'constGrowth'};
   % Compute in sample skill price growth rates up to this year
   beforeSpYear = 1970;
   afterSpYear = 2000;
end

properties
   % Year range for constant SBTC
   %  'wageYears', 'spYears'
   sbtcYearStr
   
   % Before sample starts
   %  'constGrowth': skill prices grow at constant rates (same rate as in sample up to year 1970)
   beforeSampleType
   
   % After sample starts
   afterSampleType
end


methods
   % ******  Constructor
   function spS = skillPriceSpecs_so1(sbtcYearStr, beforeSampleType, afterSampleType)
      spS.sbtcYearStr = sbtcYearStr;
      spS.beforeSampleType = beforeSampleType;
      spS.afterSampleType = afterSampleType;
      
      spS.validate;
   end
   
   
   % *******  Validate
   function validate(spS)
      if ~any(strcmpi(spS.sbtcYearStr, spS.sbtcYearStrV))
         error('Invalid sbtcYearStr');
      end
      if ~any(strcmpi(spS.beforeSampleType, spS.beforeSampleTypeV))
         error('Invalid beforeSampleType');
      end
      if ~any(strcmpi(spS.afterSampleType, spS.afterSampleTypeV))
         error('Invalid afterSampleType');
      end
   end
end
   
end