function sTimeV = ojt_tech_inv_so1(hPrimeV, hV, pProduct, pAlpha, pBeta, ddh)
% Compute the study time l that yields hPrime tomorrow

% Must be extremely efficient
% --------------------------------------------------------------

% *****  Input check
% if cS.dbg > 10
%    if all(iCohort ~= (1 : cS.nCohorts))
%       error('Invalid iCohort');
%    end
%    if all(iSchool ~= (1 : cS.nSchool))
%       error('Invalid iSchool');
%    end
% end



% *******  Main

dhV = hPrimeV - (1 - ddh) .* hV;

if pAlpha == pBeta
   sTimeV = (dhV ./ pProduct) .^ (1 ./ pAlpha)  ./  hV;
else
   sTimeV = (dhV ./ pProduct ./ (hV .^ pAlpha)) .^ (1 ./ pBeta);
end

% When changes in h are negative: invalid
sTimeV(dhV < 0) = -9;



end