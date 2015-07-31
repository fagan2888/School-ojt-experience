function run_cpsearn(gNo)
% Run cpsearn routines to generate raw data files to import

fprintf('Running cpsearn routines \n');
cS = const_data_so1(gNo);
dirS = param_so1.directories(gNo, cS.setNo);
varS = param_so1.var_numbers;
% Keep wage data for these ages
dataAgeV = cS.age1 : cS.ageRetire;

% Make earnings data accessible
go_cpsearn;

% Get cps setNo
cpsS = const_cpsearn(1);
cpsSetNo = cpsS.(cS.cpsSetNoStr);
cpsS = const_cpsearn(cpsSetNo);


%% Filter settings

fltS = import_cpsearn.filter_settings(cpsS.fltExperDefault, cpsS);

% Add some slack at the top (b/c one cpsearn routine wants it)
fltS.ageMax = cS.ageRetire + 4;

% Very little filtering
fltS.hoursMin = [];
fltS.weeksMin = [];

fltS.dropGq = false;
fltS.dropZeroEarn = false;
fltS.dropNonWageWorkers = false;

% Must count this to avoid artificial zeros
fltS.fracBusInc = cS.dataS.fracBusInc;

fltS.validate;
output_cpsearn.var_save(fltS, cpsS.vFilterSettings, [], cpsSetNo);


%% Settings for earnings profiles
% Not directly used below. Just for checking results

profS = profiles_cpsearn.settings('exper');
output_cpsearn.var_save(profS, cpsS.vProfileSettings, [], cpsSetNo);


%% Run everything

run_all_cpsearn(cpsSetNo);


%% Copy files from cpsojt to make code independent for kure

% Get age profiles
%  only for requested ages, by [by, school, age]
outS = aggr_cpsearn.byear_school_age_stats(cS.bYearLbV, cS.bYearUbV, dataAgeV, cpsSetNo);
output_so1.var_save(outS, varS.vBYearSchoolAgeStats, cS);

% Stats by [age, school, year]
outS = output_cpsearn.var_load(cpsS.vAgeSchoolYearStats, [], cpsSetNo);
output_so1.var_save(outS, varS.vAgeSchoolYearStats, cS);


% Make this here +++
%    % Copy mass by [age, school] used for aggregation
%    %  These are averages across years
%    dataWtM = var_load_cpsojt(cpsOjtS.vAvgMassAgeSchool, [], cS.cpsOjtSetNo);
%    output_so1.var_save(dataWtM, cS.vAggrCpsWeights, cS);

% Copy aggregate stats from cps
loadS = output_cpsearn.var_load(cpsS.vAggrStats, [], cpsSetNo);
output_so1.var_save(loadS, varS.vAggrCpsStats, cS);



cd(dirS.progDir);

end