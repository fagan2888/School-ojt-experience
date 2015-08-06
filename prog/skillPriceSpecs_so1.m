classdef skillPriceSpecs_so1
% Restrictions on skill prices
%{
inSampleType
   determines how skill prices in wageYearV range are determined
   'sbtc'
      skill prices are spline over entire spYearV range
   'dataWages'
      skill price in wageYearV are smoothed data wages

beforeSampleType
   determines how skill prices are handled / restricted before wageYearV
   'constGrowth'
      skill prices grow at constant rate, equal to rate in sample up to year beforeSpYear
   'fixedGrowth'
      skill prices grow at constant rate, equal to rate beforeGrowth

afterSampleType
   analogous to beforeSampleType

Not all combinations are implemented
%}

properties (Constant)
   sbtcYearStrV = {'wageYears', 'spYears'};
   inSampleTypeV = {'sbtc', 'dataWages'};
   beforeSampleTypeV = {'constGrowth', 'fixedGrowth'};
   afterSampleTypeV  = {'constGrowth', 'fixedGrowth'};
   % Compute in sample skill price growth rates up to this year
   beforeSpYear = 1970;
   afterSpYear = 2000;
   beforeGrowth = 0.01;
   afterGrowth = 0;
end

properties
   % Year range for constant SBTC
   %  'wageYears', 'spYears'
   sbtcYearStr

   % In sample
   % 'sbtc': constant sbtc
   % 'datawages': skill prices = smoothed data wages
   inSampleType
   
   % Before sample starts
   %  'constGrowth': skill prices grow at constant rates (same rate as in sample up to year 1970)
   %  'fixedGrowth': skill prices grow at exogenously given fixed growth rates
   beforeSampleType
   
   % After sample starts
   afterSampleType
end


methods
   % ******  Constructor
   function spS = skillPriceSpecs_so1(sbtcYearStr, inSampleType, beforeSampleType, afterSampleType)
      spS.sbtcYearStr = sbtcYearStr;
      spS.inSampleType = inSampleType;
      spS.beforeSampleType = beforeSampleType;
      spS.afterSampleType = afterSampleType;
      
      spS.validate;
   end
   
   
   % *******  Validate
   function validate(spS)
      if ~any(strcmpi(spS.sbtcYearStr, spS.sbtcYearStrV))
         error('Invalid sbtcYearStr');
      end
      if ~any(strcmpi(spS.inSampleType, spS.inSampleTypeV))
         error('Invalid inSampleType');
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