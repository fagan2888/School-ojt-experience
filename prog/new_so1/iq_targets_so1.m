function iq_targets_so1(gNo, setNo)
% Construct IQ targets
%{
OUT
   experV
      experience levels (redundant)
   betaIQV
      beta IQ by experience 
      from pooled wage regression
%}
% ------------------------------------

cS = const_so1(gNo, setNo);

nlsS = const_sonls(cS.nlsySetNo);

% Load NLSY results of regressing log wage on AFQT etc
loadS = var_load_sonls(nlsS.vRegrWageAfqt, cS.nlsySetNo);
% Highest exponent included
nx = length(loadS.betaAfqtV) - 1;

% Experience range to show
experV = 1 : 25;
coeffV = zeros(size(experV));
for ix = 1 : (nx + 1)
   coeffV = coeffV + experV .^ (ix-1) * loadS.betaAfqtV(ix);
end


% Save
saveS.experV = experV;
saveS.betaIQV = coeffV;
var_save_so1(saveS, cS.vTgIq, cS);

end