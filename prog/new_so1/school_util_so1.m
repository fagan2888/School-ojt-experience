function util_isM = school_util_so1(logVSchool_isM, abilV, sCostV, iCohort, paramS, cS)
% Utility from attaining each school level
% the X(s)) term used to compute school probabilities equals exp(util_isM ./ pi)
%{
IN:
   logVSchool_isM(ind, school)
      value of each school level w/o psy cost and school cost
      log PV LTY
   abilV
      ability levels
   sCostV
      school costs

%}
% --------------------------------------------------

nInd = length(abilV);
dTsV = cS.schoolLengthV - cS.schoolLengthV(1);
util_isM = logVSchool_isM  +  ones([nInd,1]) * sCostV(:)'  + ...
   paramS.wtPA .* ((abilV + cS.abilMean) * dTsV(:)');


end