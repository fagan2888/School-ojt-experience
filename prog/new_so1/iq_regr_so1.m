function coeffV = iq_regr_so1(wage_iascM, pSchool_iscM, iq_icM, cS)
% Run IQ wage regression
%{
Run pooled regression of log wage on
   school dummies
   exper cubic
   iq
   iq * experience cubic
   year dummies

Cohorts and years roughly match NLSY

IN:
   wage_iascM(ind, age, school, cohort)
   pSchool_iscM(ind, school, cohort)
   iq_icM(ind, cohort)
      std normal IQ

OUT:
   coeffV(experience)
      implied coefficient of regr at each experience level

Checked: 2014-apr-22
%}
% --------------------------------------------------

saveFigures = 0;
runSilent = 01;
% Include school * experience?
inclSchoolExper = 0;

% Years of school by group
yrSchoolV = cS.demogS.workStartAgeV - cS.demogS.age1;


%% Input check
if cS.dbg > 10
   if ~v_check(wage_iascM, 'f', [cS.nSim, cS.demogS.ageRetire, cS.nSchool, cS.nCohorts], 1e-3, 1e3, cS.missVal)
      error_so1('Invalid');
   end
   if ~v_check(pSchool_iscM, 'f', [cS.nSim, cS.nSchool, cS.nCohorts], 0, 1, [])
      error_so1('Invalid');
   end
   if ~v_check(iq_icM, 'f', [cS.nSim, cS.nCohorts], -4, 4, [])
      error_so1('Invalid');
   end
end


%% Settings

% Cohorts to use in regression: between 1958 and 1964 (to match nlsy)
iCohortV = find(cS.demogS.bYearV >= 1958  &  cS.demogS.bYearV <= 1964);
bYearV   = cS.demogS.bYearV(iCohortV);
nCohorts = length(iCohortV);

% Latest year to use (to match NLSY)
maxYear = 2005;

if runSilent == 0
   fprintf('Cohorts:  ');
   fprintf('   %i',  bYearV);
   fprintf('\n');
end



%% Make regressors
% Same dimensions as wage_iascM

logWage_iascM = log_lh(wage_iascM(:,:,:,iCohortV), cS.missVal);

sizeV = size(logWage_iascM);
experM = zeros(sizeV);
yearM  = zeros(sizeV);
iqM    = repmat(cS.missVal, sizeV);
wtM    = zeros(sizeV);
iSchoolM = zeros(sizeV);

for ic = 1 : nCohorts
   iCohort = iCohortV(ic);
   for iSchool = 1 : cS.nSchool
      % Ages to include
      maxAge = min(cS.demogS.ageRetire, age_from_year_so(bYearV(ic), maxYear, cS.ageInBirthYear));
      ageV = cS.demogS.workStartAgeV(iSchool) : maxAge;
      
      % Experience
      experM(:, ageV, iSchool, ic) = ones([cS.nSim, 1]) * (1 : length(ageV));
      
      % Year
      yearV = year_from_age_so(ageV, bYearV(ic), cS.ageInBirthYear);
      yearM(:, ageV, iSchool, ic) = ones([cS.nSim, 1]) * yearV;
      
      % IQ
      iqM(:, ageV, iSchool, ic) = iq_icM(:,iCohort) * ones([1, length(ageV)]);
      
      iSchoolM(:, ageV, iSchool, ic) = iSchool;
      
      % Weight = school prob. Weights all cohorts equally
      wtM(:, ageV, iSchool, ic) = pSchool_iscM(:, iSchool, iCohort) * ones([1, length(ageV)]);
   end
end

validM = (experM >= 1)  &  (yearM > 1900)  &  (yearM <= maxYear)  &  (logWage_iascM ~= cS.missVal);
vIdxV = find(validM == 1);

experV = experM(vIdxV) ./ 10;
iqV    = iqM(vIdxV);


%% Build regressor matrices

nObs = length(vIdxV);
yearV = unique(yearM(vIdxV));
% Highest experience power
nx = 3;

% Regressor matrix structure
nRegr = 0;
iConst = nRegr + 1;     nRegr = iConst;
iIq    = nRegr + 1;     nRegr = iIq;
iIqExperV = nRegr + (1 : nx);     nRegr = iIqExperV(end);
iSchoolV  = nRegr + (1 : (cS.nSchool-1));  nRegr = iSchoolV(end);
iExperV   = nRegr + (1 : nx);     nRegr = iExperV(end);
% School * experience
if inclSchoolExper == 1
   iSchoolExper = nRegr + 1;     nRegr = iSchoolExper;
end
iYrDummyV = nRegr + (1 : (length(yearV)-1));


xM = zeros([nObs, nRegr]);
xM(:, iConst) = 1;
xM(:, iIq) = iqV;
for ix = 1 : length(iIqExperV)
   xM(:, iIqExperV(ix)) = iqV .* (experV .^ ix);
end

% School dummies
%  and school * experience
for iSchool = 1 : length(iSchoolV)
   xM(:, iSchoolV(iSchool)) = (iSchoolM(vIdxV) == iSchool);
   if inclSchoolExper == 1
      sIdxV = find(iSchoolM(vIdxV) == iSchool);
      xM(sIdxV, iSchoolExper) = yrSchoolV(iSchool) .* experV(sIdxV);
   end
end
% Experience
for ix = 1 : length(iExperV)
   xM(:, iExperV(ix)) = experV .^ ix;
end

% Year dummies
for iy = 1 : (length(yearV) - 1)
   xM(:, iYrDummyV(iy)) = (yearM(vIdxV) == yearV(iy));
end

rsS = lsq_weighted_lh(logWage_iascM(vIdxV), xM, wtM(vIdxV), cS.rAlpha, cS.dbg);


if runSilent == 0
   fprintf('No of obs: %i   No of regressors: %i    R2: %5.2f \n', ...
      nObs, nRegr, rsS.rSquare);
   fprintf('School coefficients:  ');
   fprintf('%8.2f',  rsS.betaV(iSchoolV));
   fprintf('\n');
end


%% Compute regr coeff by exper

experV = 1 : 25;
% "Effect" of IQ and IQ * experience
coeffV = rsS.betaV(iIq) .* ones(size(experV));
for ix = 1 : length(iIqExperV)
   coeffV = coeffV + rsS.betaV(iIqExperV(ix)) * ((experV ./ 10) .^ ix);
end



%% Plot
if runSilent == 0
   plot(experV, coeffV, cS.lineStyleDenseV{1},  'color', cS.colorM(1,:));
   xlabel('Experience');
   ylabel('$\beta_{IQ}$', 'interpreter', 'latex');
   axis_range_lh([NaN, NaN, 0, NaN]);
   figure_format_so1(gca);
   save_fig_so1('iq_wage_pooled',  saveFigures,  [],  cS);
end

%% Output check
if cS.dbg > 10
   if ~v_check(coeffV, 'f', size(experV), -2, 2)
      error_so1('invalid coeffV', cS);
   end
end

end