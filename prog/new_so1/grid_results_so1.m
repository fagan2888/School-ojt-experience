function grid_results_so1(gridNo, gNo)
% Precompute results for grids
% ----------------------------------------

gS = grids_so1(gridNo, gNo);
setNoV = gS.setNoV;
%cS = const_so1(gNo, gS.saveNo);

% Make sure all results are current
for i1 = 1 : length(setNoV)
   recompute_so1(gNo, setNoV(i1));
end

% % Perturb R
% outS = grid_perturb_stats_so1(0, cS.dR, gNo, gS.setNoV);
% var_save_so1(outS, cS.vPerturbR, cS, gNo, gS.saveNo);
% 
% % Perturb delta
% outS = grid_perturb_stats_so1(cS.dDdh, 0, gNo, gS.setNoV);
% var_save_so1(outS, cS.vPerturbDdh, cS, gNo, gS.saveNo);

end