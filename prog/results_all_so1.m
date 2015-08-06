function results_all_so1(gNo, setNo)
% Generate all results and tex file to show them
% --------------------------------------------------

cS = const_so1(gNo, setNo);
saveFigures = 1;


% Check that calibration is "correct"


% Delete existing output files
minAge = 7;
results_so1.delete_old_results(gNo, setNo, minAge, 'noConfirm');

% Set up preamble
results_so1.preamble_init(cS);
   
% 
%    % Show convergence history
%    cal_hist_show_so1(saveFigures, gNo, setNo);
% 


%% Fit

% Age wage profiles by cohort
results_so1.show_fit(saveFigures, gNo, setNo);
% Schooling by cohort
results_so1.fit_school_cohort(saveFigures, gNo, setNo);
% Aggregate wage stats
% +++++  results_so1.fit_aggr_wages(saveFigures, gNo, setNo);


%% Parameters

results_so1.skill_prices_show(saveFigures, gNo, setNo);

%    cal_show_so1(saveFigures, gNo, setNo);
%    % Mean log wage profiles + wage growth over life-cycle
%    cal_fit_so1(saveFigures, gNo, setNo);
%    % IQ targets
%    betaiq_age_so1(saveFigures, gNo, setNo);
% 
%    % Show sim results
%    sim_show_so1(saveFigures, gNo, setNo);
% 
%    flat_spot_model_so1(gNo, setNo);
%    flat_spot_show_so1(saveFigures, gNo, setNo);
% 
% 
%    % ***  Parameters
% 
%    % Fixed parameters
%    param_fixed_tb_so1(gNo, setNo);
% 
%    % Calibrated parameters
%    param_tb_so1([], gNo, setNo)
% 
%    % Write preamble with variables for tex files
%    preamble_so1(gNo, setNo);


% *** Aggregate wage stats

%    aggr_wage_stats_show_so1(saveFigures, gNo, setNo);
%    % Lifetime earnings stats
%    % +++++aggr_lty_show_so1(saveFigures, gNo, setNo);
%    % Aggregate study time
%    % +++++aggr_stime_show_so1(saveFigures, gNo, setNo);
%    % How does model get college premium young / old?
%       % redundant given aggr wage stats?
%    collprem_show_so1(saveFigures, gNo, setNo);
%    % How does model get changing returns to experience?
%    %     also has how changing returns to experience are achieved
%    % +++++wage_growth_so1(saveFigures, gNo, setNo);
% 
% 
%    % ***  Selection results
% 
%    selection_show_so1(saveFigures, gNo, setNo);
% 
%    % ***  Counterfactual results
% 
%    % +++++cf_results_so1(gNo, setNo);
% 
%    % Explaining the rise in schooling
%    % +++++rising_school_so1(saveFigures, gNo, setNo);


%%  GE results
% Compare skill weights with what you would get with hours as labor supply
results_so1.skill_weights_show(saveFigures, gNo, setNo)
% 
% 
%    % ***  This must be run last. It crashes on kure
%    if cS.runLocal == 1
%       % Show age profiles by cohort: h, study time
%       age_profile_show_so1(saveFigures, gNo, setNo);
%    end


% Write preamble
results_so1.preamble_make(gNo, setNo);

% Copy results for paper
%  results_so1.paper_figures(gNo);

end