function pProductV = ojt_productivity(abilV, iSchoolV, iCohort, paramS, cS)
% OJT productivity parameters for given abilities
% -------------------------------------------------------------

pProductV = exp(paramS.logAV(iSchoolV) + paramS.gA * (cS.demogS.bYearV(iCohort) - cS.demogS.bYearV(1)) + ...
   paramS.abilScale .* abilV);


end