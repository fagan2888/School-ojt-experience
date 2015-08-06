function [scalarSkillWeightDev, scalarBeforeDev, scalarAfterDev] = ...
   skill_price_dev(skillPrice_stM, skillWeightTop_tlM, skillWeight_tlM,  spS, cS)
% Deviation from skill price restrictions
%{
IN
   skillPrice_stM
   skillWeightTop_tlM
   skillWeight_tlM
   spS :: skillPriceSpecs_so1

OUT
   scalarSkillWeightDev
      deviation from constant SBTC
%}

spYearV = (cS.spS.spYearV(1) : cS.spS.spYearV(end))';
nsp = length(spYearV);


%% Input check
if cS.dbg > 10
   if ~isa(spS, 'skillPriceSpecs_so1')
      error('Invalid');
   end
   validateattributes(skillPrice_stM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
      'size', [cS.nSchool, nsp]})
end



%% Allocate output values

scalarSkillWeightDev = 0;
scalarBeforeDev = 0;
scalarAfterDev = 0;

if strcmpi(cS.spSpecS.inSampleType, 'dataWages')
   % Skill prices are fixed. No penalties
   return;
end


%% Deviations from constant relative skill weight growth
% Regress log(mu(s)) - log(mu(HS)) on linear trend. Take TSS

if strcmpi(cS.spSpecS.inSampleType, 'sbtc')
   % Year range over which const sbtc is assumed
   if strcmpi(spS.sbtcYearStr, 'spYears')
      sbtcYearV = spYearV;
   elseif strcmpi(spS.sbtcYearStr, 'wageYears')
      sbtcYearV = (cS.wageYearV(1) : cS.wageYearV(end))';
   else
      error_so1('Invalid', cS);
   end

   % Indices into skillWeight matrices
   yrIdxV = sbtcYearV - spYearV(1) + 1;

   devSkillWeightV = zeros([cS.nSchool, 1]);
   % Regress on linear time trend (intercept is automatic)
   xM = sbtcYearV(:) - sbtcYearV(1);
   for iSchool = 1 : cS.nSchool
      if iSchool == cS.iCG
         % Top level nest
         yV = log(skillWeightTop_tlM(yrIdxV, 2)) - log(skillWeightTop_tlM(yrIdxV,1));
      else
         % Lower level nest
         yV = log(skillWeight_tlM(yrIdxV,iSchool)) - log(skillWeight_tlM(yrIdxV,cS.schoolHSG));
      end

      if iSchool ~= cS.schoolHSG
         %mdl = fitlm(xM, yV);
         %residV = mdl.Residuals.Raw;
         [~, ~, residV] = regress(yV, xM);
         devSkillWeightV(iSchool) = (residV(:)' * residV(:)) ./ length(residV);
      end
   end
   
   validateattributes(devSkillWeightV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>=', 0, ...
      'size', [cS.nSchool, 1]})
   scalarSkillWeightDev = 250 * mean(devSkillWeightV);
   
else
   error('Invalid');
end
   



%% Before sample
if strcmp(spS.beforeSampleType, 'constGrowth')
   % Skill prices grow at constant rate
   % Same rate as in sample to 1970
   
   % In sample growth rate
   yrIdx2 = spS.beforeSpYear - spYearV(1) + 1;
   yrIdx1 = cS.wageYearV(1) - spYearV(1) + 1;
   dy = yrIdx2 - yrIdx1;
   logSkillPrice_stM = log(skillPrice_stM(:, [yrIdx1, yrIdx2]));
   sampleGrowth_sV = (logSkillPrice_stM(:, 2) - logSkillPrice_stM(:, 1)) ./ dy;
   
   % Before sample growth rates
   %beforeGrowth_sV = (log(skillPrice_stM(:, yrIdxV(1))) - log(skillPrice_stM(:, 1))) ./ yrIdxV(1);
   
   % Cumulative growth from spYear 1 to wage year 1
   cumGrowth_sV = (cS.wageYearV(1) - spYearV(1)) .* sampleGrowth_sV;
   
   % Log skill prices before sample starts
   beforeLogSkillPrice_stM = log(skillPrice_stM(:, 1 : (yrIdx1-1)));

   beforeDevV = zeros([cS.nSchool, 1]);
   for iSchool = 1 : cS.nSchool
      % Project skill prices backwards to spYearV(1)
      tgLogSkillPrice_tV = logSkillPrice_stM(iSchool, 1) - cumGrowth_sV(iSchool) + ...
         sampleGrowth_sV(iSchool) .* (0 : (cS.wageYearV(1) - spYearV(1) - 1));
      % Check
      if length(tgLogSkillPrice_tV) ~= (cS.wageYearV(1) - spYearV(1))
         error('Invalid');
      end
      if abs(tgLogSkillPrice_tV(end) + sampleGrowth_sV(iSchool) - logSkillPrice_stM(iSchool, 1)) > 1e-4
         error('Invalid');
      end
      % Deviation: sum of squared deviations from constant growth path
      beforeDevV(iSchool) = 1e3 .* sum((beforeLogSkillPrice_stM(iSchool, :) - tgLogSkillPrice_tV) .^ 2);
   end
   
   validateattributes(beforeDevV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
      'size', [cS.nSchool, 1]})
   scalarBeforeDev = mean(beforeDevV);
   
else
   error_so1('Invalid', cS);
end

   

%% After sample
if strcmp(spS.afterSampleType, 'constGrowth')
   % In sample growth rate
   yrIdx1 = spS.afterSpYear - spYearV(1) + 1;
   yrIdx2 = cS.wageYearV(end) - spYearV(1) + 1;
   dy = yrIdx2 - yrIdx1;
   logSkillPrice_stM = log(skillPrice_stM(:, [yrIdx1, yrIdx2]));
   sampleGrowth_sV = (logSkillPrice_stM(:, 2) - logSkillPrice_stM(:, 1)) ./ dy;
   
   % Log skill prices before sample starts
   afterLogSkillPrice_stM = log(skillPrice_stM(:, (yrIdx2+1) : end));
   tAfter = spYearV(end) - cS.wageYearV(end);
   if size(afterLogSkillPrice_stM, 2) ~= tAfter
      error_so1('Invalid', cS);
   end

   afterDevV = zeros([cS.nSchool, 1]);
   for iSchool = 1 : cS.nSchool
      % Project skill prices backwards to spYearV(1)
      tgLogSkillPrice_tV = logSkillPrice_stM(iSchool, 2) + ...
         sampleGrowth_sV(iSchool) .* (1 : tAfter);
      % Deviation: sum of squared deviations from constant growth path
      afterDevV(iSchool) = 1e3 .* sum((afterLogSkillPrice_stM(iSchool, :) - tgLogSkillPrice_tV) .^ 2);
   end
   
   validateattributes(afterDevV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
      'size', [cS.nSchool, 1]})
   scalarAfterDev = mean(afterDevV);

else
   error_so1('Invalid');
end



end