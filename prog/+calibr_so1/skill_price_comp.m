function skillPrice_stM = skill_price_comp(tgS, paramS, cS)
% Compute skill prices by [school, year]
%{

Checked: 
%}
% -------------------------------------------------------

% Years with skill prices
% spYearV = (cS.spS.spYearV(1) : cS.spS.spYearV(2))';
nsp = cS.spS.spYearV(2) - cS.spS.spYearV(1) + 1;

% Skill prices, by [year relative to cS.spS.spYearV(1)]
skillPrice_stM = repmat(cS.missVal, [cS.nSchool, nsp]);

if strcmpi(cS.spSpecS.inSampleType, 'sbtc')
   % Spline for entire period
   for iSchool = 1 : cS.nSchool
      fieldStr = sprintf('logWNode_s%iV', iSchool);
      skillPrice_stM(iSchool, :) = exp(spline(cS.spS.spNodeIdxV,  paramS.(fieldStr),  1 : nsp));
   end

elseif strcmpi(cS.spSpecS.inSampleType, 'dataWages')
   for iSchool = 1 : cS.nSchool
      % IN sample: smoothed data wages
      yV = exp(hpfilter(tgS.logWage_stM(iSchool, :), 10));
      wageV = nan(nsp, 1);
      yrIdxV = cS.wageYearV - cS.spS.spYearV(1) + 1;
      wageV(yrIdxV) = yV ./ yV(1);
   
      % OUT of sample
      if strcmpi(cS.spSpecS.beforeSampleType, 'fixedGrowth')  &&  strcmpi(cS.spSpecS.afterSampleType, 'fixedGrowth')
         % Extend out of sample using constant growth rates
         skillPrice_stM(iSchool, :) = vector_lh.extend_const_growth(wageV, ...
            cS.spSpecS.beforeGrowth, cS.spSpecS.afterGrowth, cS.dbg);
      else
         error('Not implemented');
      end
   end
   
else
   error_so1('Invalid', cS);
end

if cS.dbg > 10
   validateattributes(skillPrice_stM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>', 1e-2, ...
      '<', 1e4, 'size', [cS.nSchool, nsp]});
end


end