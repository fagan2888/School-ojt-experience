function cohort_hours(gNo)
% Make and save a cohort hours / weeks profile
%{
Use CPS hours profiles
Smooth them
Fit a quartic and use to extrapolate to unobserved ages

Make be hours per week or weeks per year
Scaled into model units using cS.hoursScale

OUT
   hoursRawM(phys age, school, cohort)
      raw data
   hoursM
      same, but smoothed and extended to all ages

Checked: 2014-apr-7
%}
% -------------------------------------

cS = const_so1(gNo, 1);
cS = const_so1(gNo, cS.dataSetNo);
varS = param_so1.var_numbers;

maxAge = cS.ageRetire;  

% Smooth more strongly. We only want fairly low frequency movements
hpFilterParam = cS.hpFilterHours;

% CPS hours, raw, by [by, school, phys age]
% byLbV = cS.bYearLbV;
% byUbV = cS.bYearUbV;
% nBy = length(byLbV);

loadS = output_so1.var_load(varS.vBYearSchoolAgeStats, cS);

if cS.wagePeriod == cS.hourlyWages
   hoursRawM = loadS.hoursMean_csauM;
elseif cS.wagePeriod == cS.weeklyWages
   hoursRawM = loadS.weeksMean_csauM;
else
   error('Not valid');
end
% Pick out the right universe
hoursRawM = hoursRawM(:,:,:, cS.dataS.iuCpsEarn);

saveS.hoursRaw_ascM = repmat(cS.missVal, [maxAge, cS.nSchool, cS.nCohorts]);
for iSchool = 1 : cS.nSchool
   for iBy = 1 : cS.nCohorts
      hoursV = hoursRawM(iBy, iSchool, 1:maxAge);
      hoursV = hoursV(:);
      
      % If there are a few missing values in the interior: interpolate
      vIdxV = find(hoursV > 0);
      if length(vIdxV) ~= vIdxV(end) - vIdxV(1) + 1
         if any(diff(vIdxV) > 3)
            error('Hours gap too large');
         end
         hoursV(vIdxV(1) : vIdxV(end)) = interp1(vIdxV, hoursV(vIdxV),  vIdxV(1) : vIdxV(end), 'linear');
      end
      
      saveS.hoursRaw_ascM(1:maxAge,iSchool,iBy) =  hoursV./ cS.hoursScale;
   end
end




%%  Fit a polynomial

% Fitted profiles by [age, school]
saveS.hoursFit_asM = repmat(cS.missVal, [cS.ageRetire, cS.nSchool]);

for iSchool = 1 : cS.nSchool
   disp(' ');
   disp(['Hours regression for school group ', cS.schoolLabelV{iSchool}]);
   
   % Potential no of obs
   n = cS.nCohorts * (cS.ageRetire - cS.workStartAgeV(iSchool) + 1);

   % Regressors
   yV = zeros([n, 1]);
   xAgeV = zeros([n, 1]);
   byDummyM = zeros([n, cS.nCohorts]);
   %sDummyM  = zeros([n, cS.nSchool]);

   % No of obs so far
   nObs = 0;
   for iBy = 1 : cS.nCohorts
      % Ages to keep
      ageV = (cS.workStartAgeV(iSchool) : cS.ageRetire)';
      
      hoursV = squeeze(saveS.hoursRaw_ascM(ageV,iSchool,iBy));
      idxV = find(hoursV > 0);
     
      nNewV = nObs + (1 : length(idxV));
      yV(nNewV) = hoursV(idxV);
      xAgeV(nNewV) = ageV(idxV);
      byDummyM(nNewV, iBy) = 1;
      %sDummyM(nNewV, iSchool) = 1;
      nObs = nNewV(end);
   end
   
   yV = yV(1 : nObs);
   xAgeV = xAgeV(1 : nObs);
   byDummyM = byDummyM(1 : nObs, :);

   % Drop empty dummies
   cntV = sum(byDummyM);
   byIdxV = find(cntV > 2);
   byIdxV = byIdxV(2 : end);
   
   xAgeV = xAgeV ./ 10;
   xM = [ones([nObs,1]), xAgeV, xAgeV .^ 2, xAgeV .^ 3, xAgeV .^ 4, byDummyM(:, byIdxV)];
   
   rsS = regress_lh.regr_stats_lh(yV, xM, cS.rAlpha, cS.dbg);
   
   
   % Fitted profile (up to intercept)
   xAgeV = ageV(:) ./ 10;
   nObs = length(xAgeV);
   x2M = [ones([nObs,1]), xAgeV, xAgeV .^ 2, xAgeV .^ 3, xAgeV .^ 4, zeros([nObs, length(byIdxV)])];
   fitV = x2M * rsS.betaV;
   
   saveS.hoursFit_asM(ageV, iSchool) = fitV;
end




%%  Smooth and extend to unobserved ages

% Smoothed profiles
saveS.hours_ascM = repmat(cS.missVal, [maxAge, cS.nSchool, cS.nCohorts]);

for iSchool = 1 : cS.nSchool
   age1 = cS.workStartAgeV(iSchool);
   age2 = cS.ageRetire;
   
   % Fitted profile
   hoursFitV = saveS.hoursFit_asM(1 : age2, iSchool);
   hoursFitV = hoursFitV(:);
   
   for iBy = 1 : cS.nCohorts
      hoursV = squeeze(saveS.hoursRaw_ascM(:, iSchool, iBy));
      idxV = find(hoursV > 0);
      % Make sure ages are consecutive
      if length(idxV) ~= idxV(end) - idxV(1) + 1
         error('Ages have gaps');
      end
      
      % HP filter
      smoothV = repmat(cS.missVal, [maxAge, 1]);
      smoothV(idxV) = hpfilter(hoursV(idxV), hpFilterParam);
      
      % Extend using fitted profiles
      if idxV(1) > cS.workStartAgeV(iSchool)
         smoothV(age1 : idxV(1)) = hoursFitV(age1 : idxV(1)) ./ hoursFitV(idxV(1)) .* smoothV(idxV(1));
      end
      
      if idxV(end) < cS.ageRetire
         smoothV(idxV(end) : age2) = hoursFitV(idxV(end) : age2) ./ hoursFitV(idxV(end)) .* smoothV(idxV(end));
      end
      
      saveS.hours_ascM(:, iSchool, iBy) = smoothV;
   end
end
if ~v_check(saveS.hours_ascM, 'f', [maxAge, cS.nSchool, cS.nCohorts], [], 4000)
   error_so1('Invalid hours', cS);
end


% Save
output_so1.var_save(saveS, varS.vCohortHours, cS);



end