function cS = var_numbers

%%  Model Variables: 1 - 199

% Calibration results
cS.vCalResults = 1;
% Calibrated parameters
cS.vParams = 8;

% Hh Policy functions
cS.vHhSolution = 3;

% Random variables to reuse for simulating histories
cS.vRandomVars = 2;
% Sim stats. Computed after calibration is done
cS.vSimStats = 11;
% Aggregate stats implied by model
cS.vAggrStats = 17;
% Aggregate study times
cS.vAggrSTime = 18;

% History of globalsearch_lh
cS.vOptimHistory = 6;
cS.vOptimHistoryTemp = 7;

% Inputs to calibration deviation
cS.vCalDevInputs = 9;

% Pv of lifetime earnings, mean log, by [school, cohort]
% also with random school assignment
%cS.vPvLty = 10;
% Results of pvearn_notraining
cS.pvEarnNoTraining = 13;

% Selection experiments
% Effect on wage paths
%cS.vSelectionPath = 12;
% Aggregate stats with random school assignment
cS.vAggrStatsNoSelection = 19;

% Flat spot wage path from model
cS.vFlatSpotModel = 14;

% Results of perturbing ddh and R
cS.vPerturbR = 15;
cS.vPerturbDdh = 16;

% Reserved for testing: 90 - 99

cS.vErrorData = 91;


% Preamble results are collected here
cS.vPreambleData = 17;


% *******  Saved as single, loaded as double: 151-199
% Save / load with the usual function

% Simulated histories
cS.vSimResults = 151;
% Simulated steady state solutions
cS.vSteadyStates = 152;



%%  Data variables: 201-300

% Range of data variables
cS.dataVarRangeV = [201, 300];

% Stats by [age, school, year]. Simply copied from cpsojt
cS.vAgeSchoolYearStats = 201;

% Stats by [birth year, school, age]. Simply copied from cpsojt
cS.vBYearSchoolAgeStats = 208;

% Data wage profiles
cS.vDataProfiles = 202;

% Schooling by cohort
cS.vCohortSchool = 203;

% Age hours profiles
cS.vCohortHours = 204;

% Data constants, for preamble etc
cS.vDataConstants = 205;

% Data wages by year
% cS.vDataWageYear = 206;

% CPS population weights by [age, school]. For computing constant composition aggregates
% Mass in each cell. Averaged over years
cS.vAggrCpsWeights = 210;

% Aggregate CPS wage stats
cS.vAggrCpsStats = 211;

% Flat spot wages
cS.vFlatSpotWages = 207;

% Calibration targets
% Calibration targets
cS.vCalTargets = 209;

% IQ targets (from NLSY)
cS.vTgIq = 213; 


end