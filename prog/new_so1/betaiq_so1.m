function betaIQ = betaiq_so1(logWageM, pSchoolM, iqV, cS)
% Estimate betaIQ. Regression of log wage at a fixed age / experience on school dummies
% and std normal IQ
%{
IN
   logWageM(ind, school)
      for the fixed age / experience
   iqV
      std normal IQ; same for all school groups for an ind
   pSchoolM(ind, school)
      school probabilities

Checked: +++
%}
% -----------------------------------------------------------------

%% Input check
if cS.dbg > 10
   [nInd, nSchool] = size(logWageM);
   if ~v_check(logWageM, 'f', [nInd, cS.nSchool], -20, 20)
      error_so1('invalid logWageM', cS);
   end
   if ~v_check(pSchoolM, 'f', [nInd, cS.nSchool], 0, 1)
      error_so1('invalid pSchoolM', cS);
   end
   if ~v_check(iqV(:), 'f', [nInd, 1],  [], [])
      error_so1('invalid iqv', cS);
   end
end


%% Main

% Keep this many observations
nObs = min(cS.gS.nSim, 2e3);

% School dummies
sDummyM = zeros([cS.nSchool * nObs, cS.nSchool-1]);
yV = zeros([cS.nSchool * nObs, 1]);
iqRegrV = zeros(size(yV));
wtV = zeros(size(yV));

for iSchool = 1 : cS.nSchool
   % Location of obs for this school group
   idxV = (iSchool-1) * nObs + (1 : nObs);
   yV(idxV) = logWageM(1:nObs, iSchool);
   % Std normal IQ
   iqRegrV(idxV) = iqV(1 : nObs);
   wtV(idxV) = pSchoolM(1 : nObs, iSchool);
   if iSchool > 1
      sDummyM(idxV, iSchool-1) = 1;
   end
end

% Weighted least squares
betaV = lscov([ones(size(yV)), iqRegrV, sDummyM], yV, wtV);
betaIQ = betaV(2);   


%% Output check
if cS.dbg > 10
   if ~v_check(betaIQ, 'f', [1,1], [], [])
      error_so1('invalid betaIQ', cS);
   end
end

   
end