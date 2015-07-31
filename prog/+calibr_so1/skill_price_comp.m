function skillPrice_stM = skill_price_comp(paramS, cS)
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


for iSchool = 1 : cS.nSchool
   fieldStr = sprintf('logWNode_s%iV', iSchool);
   skillPrice_stM(iSchool, :) = exp(spline(cS.spS.spNodeIdxV,  paramS.(fieldStr),  1 : nsp));
end


if cS.dbg > 10
   validateattributes(skillPrice_stM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>', 1e-2, ...
      '<', 1e4, 'size', [cS.nSchool, nsp]});
end


end