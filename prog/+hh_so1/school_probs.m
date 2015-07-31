function prob_isM = school_probs(valueWork_isM, prGradHsV, prGradCollV, prefHs, prefScaleEntry, cS)
% Compute school probs for a given set of agents
%{
IN
   valueWork_isM
      value of working by [ind, school]
      discounted to age 1
   abilV
      abilities
   prGradHsV
      prob grad HS
   prGradCollV
      prob grad college, if try
   prefHs
      mean value added to work as HSG option at entry choice
   prefScaleEntry
      type I shock scale factor at college entry
%}


% Expected value given college entry
evCollegeV = prGradCollV(:) .* valueWork_isM(:, cS.iCG)  +  ...
   (1 - prGradCollV(:)) .* valueWork_isM(:, cS.iCD);

% Type I extreme value decision probs
prob_isM = econ_lh.extreme_value_decision([valueWork_isM(:, cS.iHSG) + prefHs,  evCollegeV],  prefScaleEntry, cS.dbg);

probEnterV = prob_isM(:, 2);

% Prob of each s choice
prob_isM = [1 - prGradHsV(:),  prGradHsV(:) .* (1 - probEnterV),  prGradHsV(:) .* probEnterV .* (1 - prGradCollV(:)),  ...
   prGradHsV(:) .* probEnterV .* prGradCollV(:)];


if cS.dbg > 10
   validateattributes(prob_isM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>=', 0,  '<=', 1, ...
      'size', size(valueWork_isM)})
   prSumV = sum(prob_isM, 2);
   if any(abs(prSumV - 1) > 1e-5)
      error_so1('Sums not 1', cS);
   end
end


end