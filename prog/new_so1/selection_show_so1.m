function selection_show_so1(saveFigures, gNo, setNo)
% Show results of switching off school selection
%{
%}
% ----------------------------------------------------

cS = const_so1(gNo, setNo);


aggrS = var_load_so1(cS.vAggrStats, cS);
yearV = aggrS.yearV;
nCase = 2;
legendV = {'Baseline', 'No selection'};


%% Compute stats to be shown

% Wage premium, relative to HSG at fixed age
skillPremM = zeros([nCase, cS.nSchool, length(yearV)]);
for iCase = 1 : nCase
   if iCase == 1
      loadVar = cS.vAggrStats;
   elseif iCase == 2
      loadVar = cS.vAggrStatsNoSelection;
   else
      error('Invalid');
   end
   [aggrS, success] = var_load_so1(loadVar, cS);
   
   if success == 1
      if cS.useMedianWage == 1
         logWage_stM = aggrS.logMedianWage_stM;
      else
         logWage_stM = aggrS.meanLogWage_stM;
      end
      
      for iSchool = 1 : cS.nSchool
         skillPremM(iCase,iSchool,:) = logWage_stM(iSchool,:) - logWage_stM(cS.schoolHSG,:);
      end
   end
end



%% Evolution of all skill premiums
if 1
   for iSchool = 1 : cS.nSchool
      fig_new_so(saveFigures);
      hold on;
      for iCase = 1 : nCase
         plot(yearV, squeeze(skillPremM(iCase,iSchool,:)), cS.lineStyleDenseV{iCase}, 'color', cS.colorM(iCase,:));
      end

      hold off;
      xlabel('Year');
      ylabel('Log wage gap relative to HSG');
      legend(legendV, 'location', 'northwest');
      figure_format_so1(gca);
      save_fig_so1(['sel_prem_', cS.schoolSuffixV{iSchool}], saveFigures, [], cS);
   end   
end




end