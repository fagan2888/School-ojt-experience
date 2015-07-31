function run_data_so1(gNo)
% Run all data routines. Needs to be done only once
%{
Only this code should depend on cps data directly

Checked: 
%}
% -------------------------------------------------

cS = const_data_so1(gNo);
setNo = cS.dataSetNo;
% dirS = param_so1.directories(gNo, setNo);
% varS = param_so1.var_numbers;

saveFigures = 1;


% % Make earnings data accessible
% go_cpsearn;
% cd(dirS.progDir);

% Get cps setNo
% cpsS = const_cpsearn(1);
% cpsSetNo = cpsS.(cS.cpsSetNoStr);
% cpsS = const_cspearn(cpsSetNo);

% Keep wage data for these ages
% dataAgeV = cS.age1 : cS.ageRetire;




%    % IQ targets
%    iq_targets_so1(gNo, setNo);



%% Compute stats from cps data files


% Make fraction in each school group by by
data_so1.cohort_school(gNo);

% Make a file with cohort age wage profiles
data_so1.cohort_profiles(gNo);

% Cohort hours or weeks profiles
data_so1.cohort_hours(gNo)
data_so1.cohort_hours_show(saveFigures, gNo);

% Summary stats table for cps data
data_so1.cps_summary_tb(gNo);

% Flat spot wages
% flat_spot_cps_so1(saveFigures, gNo, setNo);

% Make calibration targets
%  Must be done last
data_so1.cal_targets(gNo);



%% Show cal targets 

data_so1.cal_targets_show(saveFigures, gNo);

data_so1.aggr_wages_show(saveFigures, gNo);
data_so1.cohort_school_show(saveFigures, gNo);
data_so1.tg_hours_show(saveFigures, gNo);
data_so1.cohort_profiles_show(saveFigures, gNo);


% How well does a quartic in experience fit?
data_so1.quartic_model(saveFigures, gNo)

% Data wages by year (stats not in cal_targets)
% data_wages_show_so1(saveFigures, gNo, setNo);

% Aggregate labor supply and college premium
%  Graph like AKK 2008
data_so1.aggr_ls_collprem(saveFigures, gNo);


%  +++ preamble_group_so1(gNo, setNo);

   
end