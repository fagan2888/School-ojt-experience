function recompute_so1(gNo, setNo)
% Recompute all results. To make sure they are up to date
% -------------------------------------------------------

cS = const_so1(gNo, setNo);

saveHistory = 0;
calibrate_so1('none', saveHistory, gNo, setNo);
% ind_histories_so1(gNo, setNo);
sim_stats_so1(gNo, setNo);
% Aggregate stats (with constant age/school composition)
aggr_stats_save_so1(gNo, setNo);
% The same, taking out school sorting
% selection_stats_so1(gNo, setNo);
% Test 
% calibr_so1.cal_check(cS);


end