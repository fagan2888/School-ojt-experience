function hWorkStartV = school_tech(h1V, abilV, iSchool, iCohort, paramS, cS)
% Human capital accumulation in school
%{
% IN:
%  h1V(ind)
%     h at age 1
%  iSchool
      scalar

% OUT:
%  hWorkStartV
%     h at start of work, by ind
%}
% ----------------------------------------------

if cS.dbg > 10
   validateattributes(h1V, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>', 0.01, ...
      '<', 100,  'size', size(abilV)})
end

% Productivities, same as OJT for CG
pProductV = hh_so1.ojt_productivity(abilV, cS.iCG, iCohort, paramS, cS);
pAlpha = paramS.alphaV(cS.iCG);
ddh = paramS.ddhV(cS.iCG);


hV = h1V;
% Study full time in school
   % +++ wrong; scale matters here (of time endowment)
sTimeV = ones(size(hV));

% Accumulate for duration of school
for t = 1 : cS.demogS.schoolLengthV(iSchool)
   % For now: use OJT technology
   %    hV = ojt_tech_so1(hV, sTimeV, pProductV, paramS.alphaV(iSchool), paramS.alphaV(iSchool), paramS.ddhV(iSchool));
   hV = hV .* (1 - ddh) + pProductV .* ((hV .* sTimeV) .^ pAlpha);
end
hWorkStartV = hV;

if cS.dbg > 10
   validateattributes(hWorkStartV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
      'size', size(h1V)})
end

end