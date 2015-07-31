function [prob_isM, sFracV, prHsgABar, prCgABar, prefScaleEntryMean] = ...
   school_prob_cal(tgSFracV, abilV, valueWork_isM, iCohort, paramS, cS)
% Calibrate parameters to match school fractions for a cohort
%{
If parameters of the cg prob function are off, it may not be feasible to get the right
   CG rate.
   Set slope parameter prCgMult >= 1 to avoid this


IN
   tgSFracV
      target school fractions
   abilV
      ability of each type
   valueWork_isM
      value of working, discounted to age 1, by [type, school]

OUT
   prob_isM
      prob of each school choice
   sFracV
      fraction in each school group
   prHsgABar, prCgABar, prefScaleEntryMean
      parameters that were calibrated
%}

dbg = cS.dbg;


%% Input check
if dbg > 10
   nTypes = length(abilV);
   validateattributes(valueWork_isM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'size', [nTypes, cS.nSchool]})
   check_lh.prob_check(tgSFracV, 1e-6);
end


%% Set parameter governing HSG probs to match HSG rate

tgHsGradRate = 1 - tgSFracV(cS.iHSD);

[prHsgABar, ~, exitFlag] = fzero(@dev_hsg, 0.5, cS.prHsgABarOptS);
if exitFlag <= 0
   error_so1('No convergence', cS);
end

% Prob that each type graduates
[~, prGradHsV] = dev_hsg(prHsgABar);

if dbg > 10
   check_lh.prob_check(prGradHsV, []);
end


%% Jointly calibrate param governing college graduation and pref for HS

prefScaleEntry = paramS.prefScaleCohortV(iCohort);

[solnV, ~, exitFlag] = fminsearch(@dev_cg, [0.5, 0], cS.schoolProbOptS);
if exitFlag <= 0
   %error_so1('No convergence', cS);
   disp('*****  No convergence finding school costs');
end

% Unpack params
prCgABar = solnV(1);
prefScaleEntryMean = solnV(2);

% School probs
[~, prob_isM, sFracV] = dev_cg(solnV);


%% Output check
if cS.dbg > 10
   check_lh.prob_check(sFracV, 1e-4);
   check_lh.prob_check(prob_isM', 1e-5);
   % check_lh.approx_equal(sFracV(:), tgSFracV, 1e-2, []);
end

sFracV = sFracV(:) ./ sum(sFracV);


return;


%% Local: deviation function for HSG rates
   function [dev, probV] = dev_hsg(aBar)
      % Prob that each type graduates
      probV = hh_so1.prob_hsg(abilV, paramS.prHsgMult, aBar, cS);
      % Avg graduation rate
      gradRate = mean(probV);
      dev = gradRate - tgHsGradRate;
   end


%% Local: deviation function for CG rates
%{
IN
   guessV
      (1)   aBar in prob of college graduation
      (2)   pref for work as HSG
%}
   function [dev, prob_isLM, sFracLV] = dev_cg(guessV)
      if abs(guessV(1)) > 2.7
         dev = 1e8;
         return;
      end
      
      % Prob that each type graduates from college
      prGradCollLV = hh_so1.prob_cg(abilV, paramS.prCgMult, guessV(1), cS);
      % School probs for each type
      prob_isLM = hh_so1.school_probs(valueWork_isM, prGradHsV, prGradCollLV, guessV(2), prefScaleEntry, cS);
      % School fractions
      sFracLV = mean(prob_isLM);
      dev = 100 .* sum((sFracLV(:) - tgSFracV(:)) .^ 2);
   end

end