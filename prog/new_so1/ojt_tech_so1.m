function [hPrimeV, dGdlV] = ojt_tech_so1(hV, sTimeV, pProductV, pAlpha, pBeta, ddh)
% OJT technology
%{
IN:
   hV, sTimeV, pProductV
      all can be scalars
%}
% --------------------------------------



GV = pProductV .* (hV .^ pAlpha) .* (sTimeV .^ pBeta);

% Impose h range
%ageNext = min(age + 1, cS.demogS.ageRetire);
hPrimeV = (1-ddh) .* hV(:) + GV(:);
%if imposeBounds == 1
%   hPrimeV = max(paramS.hRangeM(1,ageNext,iSchool,iCohort),  ...
%      min(paramS.hRangeM(2,ageNext,iSchool,iCohort), hPrimeV));
%end

% Derivatives: dG/d(study time)
if nargout == 2
   dGdlV = pBeta .* GV(:) ./ max(1e-9, sTimeV(:));
else
   dGdlV = 0;
end

if any(isnan(hPrimeV))
   error('hPrimeV nan')
end

end