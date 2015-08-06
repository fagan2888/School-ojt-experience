function cS = const_so1(gNo, setNo)
% Set constants
%{
If setNo invalid: set cS.validSet = 0


Index order
   [age a, year t, h, abil, s, cohort]
   matrices are indexed by physical age

Conventions
   age 1 is in birth year
   year = [birth year] + age - 1
   present values do not discount current period values


Checked: 
%}


% Start with constants that do not depend on group or set
cS = constants_so1;


cS.gNo   = gNo;
cS.setNo = setNo;
cS.validSet = 1;

% Descriptive string
cS.setStr = 'default';

% Version. To ensure that all results are consistent
cS.version = 2;

% Iteration history: max length
cS.histMaxIter = 1e3;


% Always save iteration histories during calibration?
%  Affects kure scripts
cS.alwaysSaveHistories = 0;



%% Optimization options

% For calibrating parameter governing HS entry rate for each cohort
% in school_prob_cal
cS.prHsgABarOptS = optimset('fzero');
cS.prHsgABarOptS.TolFun = 1e-4;
cS.prHsgABarOptS.TolX = 1e-4;

% For calibrating other parameters governing school probs for each cohort
% in school_prob_cal
cS.schoolProbOptS = optimset('fminsearch');
cS.schoolProbOptS.TolFun = 1e-4;
cS.schoolProbOptS.TolX = 1e-4;



%%  Data parameters

cS.dataS = data_so1.data_const;

% Years with wage data
cS.wageYearV = 1964 : 2010;

% Compute wage growth over this age range
cS.wageGrowthAgeV = [25, 40];


% Compute cohort schooling over this age range
%  make sure this is used in cps routines +++
cS.schoolAgeRangeV = [30, 50];

% Use median or mean log wage?
cS.useMedianWage = 1;

% Data wages are not expected to be > this value (to check scaling)
cS.maxWage = 10;

% for cps data routines (as string, b/c we don't know the number)
cS.cpsSetNoStr = 'setExperDefault';

% For NLSY data routines
% cS.nlsySetNo = cS.nlsySetDefault;    % Default; all races

% Cohort definitions
% cS.cohDefStr = 'annual'; 

% Min no of wage obs to keep a cell
cS.minWageObs = 50;

% Hourly or weekly wages
%  Make sure this matches what cps profiles use +++
cS.hourlyWages = 53;
cS.weeklyWages = 33;
cS.wagePeriod = cS.weeklyWages;

% HP filter param for hours
%  make sure this is used in cps +++
cS.hpFilterHours = 20;





%%  Default model parameters
% Each param has a default value (used if not calibrated) and bounds for calibration

% Perturb guesses? For testing convergence
cS.perturbGuesses = 0;

% Keep type 1 pref shocks in this range (scala param)
cS.prefScaleMin = 0.1;
cS.prefScaleMax = 1;


% *****  Endowments

% Upper bound, in case high As produce nonsense
cS.hMax = 1e4;

% % For betaIQ, take wages at this age
cS.iqAge = 40;


% ******  OJT

% if 1: alpha(HSD) = alpha(HSG)  and alpha(CD) = alpha(CG)
% if 2: all alphas are the same
cS.twoAlphas = 1;
cS.oneAlpha  = 2;
cS.sameAlpha = 0;

% Fix mean alpha? When calibrated
   % Check code when this is enabled +++
cS.fixMeanAlpha = 0;
cS.meanAlpha = 0.5;


% Set beta = alpha?
%  Concavity is a concern
% cS.BetaEqualsAlpha = 1;
% cS.betaV = cS.alphaV;


% 1: Restrict deltas to be the same for dropouts and grads
% 2: All ddh are the same
cS.twoDdh   = 1;
cS.oneDdh   = 2;
cS.sameDdh  = 0;




% ****** Skill prices


% Fix growth of college premium?
cS.fixGCollPrem = 0;
cS.gCollPrem = 0;


% Growth rate of skill prices assumed for steady states
% cS.ssSkillPriceGrowth = 0;



% *****  Other


% Age range over which cohort wage profiles are compared with data
%  can start before workStartAgeV
% cS.ageRangeV = [20, 60];


% Percentiles of the wage distribution to use for dispersion measure
cS.wagePctV = [0.25, 0.75];



%% Grouped settings
% All of these can be overridden by groups or sets

% Demographics
cS.demogS = DemographicsSo1(18, 65, [18, 19, 21, 23]', 'annual');
cS.nCohorts = cS.demogS.nCohorts;

% Settings for skill price paths
cS.spSpecS = skillPriceSpecs_so1('wageYears', 'sbtc', 'constGrowth', 'constGrowth');

% Calibration targets
cS.calS = CalSettingsSo1;

% Calibrate base parameters only
cS.doCalV = cS.calBase;

% Also defines what is calibrated / fixed
cS.pvector = param_so1.pvector_default(cS);

%  Groups override parameters
cS = param_so1.group_settings(cS);

%  Sets override settings again
cS = param_so1.set_settings(cS);
cS.dataSetNo = cS.setS.dataSetNo;


%%  Implied parameters

% cS.dirS = param_so1.directories(cS.gNo, cS.setNo);

cS.nCohorts = cS.demogS.nCohorts;

% Last age at which positive OJT is allowed
cS.lastOjtAge = cS.demogS.ageRetire - 1;
% Age in year of birth
cS.ageInBirthYear = cS.demogS.ageInBirthYear;


if cS.useMedianWage == 1
   cS.wageStr = 'Log median wage';
else
   cS.wageStr = 'Mean log wage';
end

if cS.hasIQ == 0
   % No IQ targets => fix iq related parameters
   cS.pvector = cS.pvector.calibrate('stdIq', cS.calNever);
   cS.pvector = cS.pvector.calibrate('wtIQa', cS.calNever);
   cS.tgIq = 0;
   cS.tgBetaIq = 0;
   cS.tgBetaIqExper = 0;
end

% Scale factors for hours and wages
if cS.wagePeriod == cS.hourlyWages
   % Wage scale makes wages roughly equal to 1
   cS.wageScale = 20;
   % Scale factor for annual hours worked
   cS.hoursScale = 2e3;
elseif cS.wagePeriod == cS.weeklyWages
   cS.wageScale = 500;
   cS.hoursScale = 40;
else
   error('Invalid');
end

   


% *****  Skill price related constants
% Requires demographics to be set
% Modifies pvector

cS = param_so1.skill_price_const(cS);



if cS.sameAlpha == cS.twoAlphas
   % Only 2 alphas are calibrated
   cS.calAlphaV([cS.schoolHSD, cS.schoolCD]) = 0;
elseif cS.sameAlpha == cS.oneAlpha
   % Only 1 alpha is calibrated
   cS.calAlphaV = zeros([cS.nSchool, 1]);
   cS.calAlphaV(1) = 1;
end
if cS.sameDdh == cS.twoDdh
   % Only 2 deltas are calibrated
   cS.calDdhV([cS.schoolHSD, cS.schoolCD]) = 0;
elseif cS.sameDdh == cS.oneDdh
   % All ddh are the same
   cS.calDdhV = zeros([cS.nSchool,1]);
   cS.calDdhV(1) = 1;
end

% Alpha on a grid?
if cS.fixMeanAlpha == 1
   % Only calibrate 1st (n-1) alphas
   cS.calAlphaV = ones([cS.nSchool, 1]);
   iFix = cS.nSchool;
   cS.calAlphaV(iFix) = 0;
      
   % Set bounds to ensure that mean alpha can be attained
   cS.alphaMinV = max(cS.alphaMin, (cS.nSchool * cS.meanAlpha - cS.alphaMax) / (cS.nSchool-1)) .* ones([cS.nSchool, 1]);   
   cS.alphaMaxV = min(cS.alphaMax, (cS.nSchool * cS.meanAlpha - cS.alphaMin) / (cS.nSchool-1)) .* ones([cS.nSchool, 1]);
end

% % Alpha bounds must have positive width
% cS.alphaMaxV = max(cS.alphaMaxV,  cS.alphaMinV + 0.01);


% Skill prices
if cS.fixGCollPrem == 1
   cS.calSpGrowthV(cS.schoolCG) = 0;
   cS.spGrowthV(cS.schoolCG) = cS.spGrowthV(cS.schoolHSG) + cS.gCollPrem;
end



% Self-test
if cS.dbg > 10
   param_so1.const_check(cS);
end

end