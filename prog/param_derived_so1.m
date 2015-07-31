function paramS = param_derived_so1(updateTimeM, param0S, cS)
% Set derived params
% Also override params that are not calibrated
%{
IN
   updateTimeM
      update time endowments from loaded data?
      switch off when running calibration for efficiency
%}
% -------------------------------------------------

% paramS = param0S;

% Fix all parameters that are not calibrated (doCal no in cS.doCalV)
%  also add missing params
paramS = cS.pvector.struct_update(param0S, cS.doCalV);



%% Add missing fields

if 0
   % Update when skill price handling clarified +++++
   % In case the skill price stucture has changed
   nsp = length(cS.spNodeV) - length(cS.spNodeZeroV);
   if ~isequal(size(paramS.logWNodeM), [cS.nSchool, nsp])
      dn = nsp - size(paramS.logWNodeM, 2);
      if dn > 0
         paramS.logWNodeM = [paramS.logWNodeM, zeros([cS.nSchool,1]) * ones([1, dn])];
      else
         paramS.logWNodeM = paramS.logWNodeM(:, 1:nsp);
      end
   end
end

%%  Time endowments

% Load hours profiles
% by [phys age, school, cohort], in model units
if ~isfield(paramS, 'tEndow_ascM')
   updateTimeM = true;
elseif ~isequal(size(paramS.tEndow_ascM), [cS.ageRetire, cS.nSchool, cS.nCohorts])
   updateTimeM = true;
end
if updateTimeM
   cdS = const_data_so1(cS.gNo);
   varS = param_so1.var_numbers;
   tgS = var_load_so1(varS.vCalTargets, cdS);

   % Avoid values very close to 0 which would run into computational issues
   paramS.tEndow_ascM = max(paramS.trainTimeMin + 0.01, tgS.hours_ascM);
   clear cdS;
end

validateattributes(paramS.tEndow_ascM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
   '<', 10,  'size', [cS.ageRetire, cS.nSchool, cS.nCohorts]})


%% Schooling

% Pref scale by cohort
%  bound from below; otherwise trouble with school choice calibration
paramS.prefScaleCohortV = max(cS.prefScaleMin, paramS.prefScale .* (1 + paramS.gPrefScale) .^ (cS.bYearV - cS.bYearV(1)));


%%  OJT

paramS.alphaV = [paramS.alphaHSD; paramS.alphaHSG; paramS.alphaCD; paramS.alphaCG];
paramS.ddhV = [paramS.ddhHSD; paramS.ddhHSG; paramS.ddhCD; paramS.ddhCG];

% Impose non-calibrated alpha
%  Only when mean alpha not fixed (then n-1 alphas are calibrated and the other is implied)
if cS.fixMeanAlpha
   error('Not updated');
end
if cS.sameAlpha == 1
   error('Not updated');
   % Only 2 alphas are calibrated
   paramS.alphaV(cS.schoolHSD) = paramS.alphaV(cS.schoolHSG);
   paramS.alphaV(cS.schoolCD)  = paramS.alphaV(cS.schoolCG);
elseif cS.sameAlpha == 2
   error('Not updated');
   % All alpha are the same
   paramS.alphaV(2:cS.nSchool) = paramS.alphaV(1);
end

% if cS.calBeta == 0
%    paramS.betaV = cS.betaV;
% end
% if cS.BetaEqualsAlpha == 1
%    paramS.betaV = paramS.alphaV;
% end

if cS.sameDdh == 1
   error('Not updated');
   % Only 2 deltas are calibrated
   paramS.ddhV(cS.schoolHSD) = paramS.ddhV(cS.schoolHSG);
   paramS.ddhV(cS.schoolCD)  = paramS.ddhV(cS.schoolCG);
elseif cS.sameDdh == 2
   error('Not updated');
   paramS.ddhV(2 : cS.nSchool) = paramS.ddhV(1);
end



%% Endowments


% Mean log h1 for each cohort
paramS.meanLogH1V = zeros([cS.nCohorts, 1]);
% Loop over cohorts
for iCohort = 1 : cS.nCohorts
   % Mean log h1 grows at gH1 per year
   paramS.meanLogH1V(iCohort) = paramS.h1Mean + paramS.gH1 * (cS.bYearV(iCohort) - cS.bYearV(1));
end


%%  Skill prices + aggregate technology

if cS.fixGCollPrem == 1
   error('Not updated');
   % Fixed growth of college premium
   if cS.calSpGrowthV(cS.schoolCG) == 1
      error('Not compatible');
   end
   paramS.spGrowthV(cS.schoolCG) = paramS.spGrowthV(cS.schoolHSG) + cS.gCollPrem;
end


% Substitution elasticities
paramS.rhoCG = 1 - 1 / paramS.seCG;
paramS.rhoHS = 1 - 1 / paramS.seHS;


% Aggregate production function (nested ces object)
%  Top level: CG vs the rest
paramS.aggrProdFct = ces_nested_lh(paramS.seCG,  [cS.nSchool-1, 1], [paramS.seHS, 1]);



% Check params
param_so1.param_check(paramS, cS)


end