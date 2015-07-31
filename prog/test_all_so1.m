function test_all_so1(gNo, setNo)
% Run all test routines that do not require a solved model
% --------------------------------------------------

%cS = const_so1(gNo, setNo);

fprintf('\nTesting everything\n');


%% Household


hh_so1.endow_draw_test(gNo, setNo);
hh_so1.school_tech_test(gNo, setNo);
hh_so1.ojt_solve_test(gNo, setNo);
hh_so1.school_probs_test(gNo, setNo);
hh_so1.school_prob_cal_test(gNo, setNo);
hh_so1.sim_cohort_test(gNo, setNo);
hh_so1.sim_histories_test(gNo, setNo);
% 
% % Test study time function
% % t_hh_study_time_so1;
% 
% t_sim_cohort_so1(gNo, setNo)
% t_sim_histories_so1(gNo, setNo)


%% GE

% t_ge_technology_so1(gNo, setNo);
% t_ge_cal_weights_so1(gNo, setNo)
% t_ss_solve_givensp_so1(gNo, setNo);
% t_ss_solve_so1(gNo, setNo)
% t_ss_solve_given_wages_so1(gNo, setNo)
% t_aggr_ls_so1(gNo, setNo)
% t_cohort_to_year_so1(gNo, setNo)
% t_cs_data_so1(gNo, setNo);


%% Calibration

calibr_so1.skill_weights_test(gNo, setNo);
calibr_so1.skill_price_comp_test(gNo, setNo);
calibr_so1.aggr_ls_test(gNo, setNo);
calibr_so1.skill_price_dev_test(gNo, setNo)
calibr_so1.cal_dev_test(gNo, setNo);


%% Other

% t_skill_price_comp_so1(gNo, setNo);
% t_guess_make_so1(gNo, setNo);
% t_aggr_stats_from_cells_so1(gNo, setNo)
% 

end