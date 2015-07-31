function pProductV = ojt_productivity(abilV, iSchoolV, iCohort, paramS, cS)
% OJT productivity parameters for given abilities
% -------------------------------------------------------------

pProductV = exp(paramS.logAV(iSchoolV) + paramS.gA * (cS.bYearV(iCohort) - cS.bYearV(1)) + ...
   paramS.theta .* abilV);


end