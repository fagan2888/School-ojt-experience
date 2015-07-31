function betaIq = iq_regr_fixed_age_so1(wage_iasM, pSchool_isM, iqV, iqAge, cS)
% Regress log wage at fixed age on IQ, school dummies
%{
IN
   iqAge
      at at which wages are observed
%}
% --------------------------------------------------

nSim = size(wage_iasM, 1);

% Use at most this many observations
nObs = min(nSim, 2e3);

% School dummies
sDummyM = zeros([cS.nSchool * nObs, cS.nSchool-1]);
% Log wage
yV = zeros([cS.nSchool * nObs, 1]);
% IQ
iqRegrV = zeros(size(yV));
% Weight = school prob
wtV = zeros(size(yV));

% Make regressors
for iSchool = 1 : cS.nSchool
   idxV = (iSchool-1) * nObs + (1 : nObs);
   yV(idxV) = log(wage_iasM(1:nObs, iqAge, iSchool));
   iqRegrV(idxV) = iqV(1 : nObs);
   wtV(idxV) = pSchool_isM(1 : nObs, iSchool);
   if iSchool > 1
      sDummyM(idxV, iSchool-1) = 1;
   end
end

% Weighted least squares
betaV = lscov([ones(size(yV)), iqRegrV, sDummyM], yV, wtV);

betaIq = betaV(2);

if ~v_check(betaIq, 'f', [1,1], -1, 4, [])
   error_so1('Invalid betaIq');
end

         
end