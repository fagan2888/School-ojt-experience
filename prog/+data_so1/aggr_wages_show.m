function aggr_wages_show(saveFigures, gNo)
% Show aggregate wages
%{
%}

cS = const_data_so1(gNo);
varS = param_so1.var_numbers;
figS = const_fig_so1;

tgS = output_so1.var_load(varS.vCalTargets, cS);


%% Levels
if 1
   output_so1.fig_new(saveFigures, []);   
   hold on;
   
   for iSchool = 1 : cS.nSchool
      iLine = iSchool;
      plot(cS.wageYearV,  tgS.logWage_stM(iSchool, :),  figS.lineStyleDenseV{iLine}, 'color', figS.colorM(iLine,:));      
   end
   
   hold off;
   xlabel('Year');
   ylabel('Log wage');
   legend(cS.schoolLabelV, 'location', 'southoutside', 'orientation', 'horizontal');
   output_so1.fig_format(gca, 'line');
   output_so1.fig_save('aggr_wage', saveFigures, cS);
end


%% Relative to HSG
if 1
   output_so1.fig_new(saveFigures, []);   
   hold on;
   
   for iSchool = 1 : cS.nSchool
      iLine = iSchool;
      plot(cS.wageYearV,  tgS.logWage_stM(iSchool, :) - tgS.logWage_stM(cS.iHSG, :),  ...
         figS.lineStyleDenseV{iLine}, 'color', figS.colorM(iLine,:));      
   end
   
   hold off;
   xlabel('Year');
   ylabel('Log wage relative to HSG');
   legend(cS.schoolLabelV, 'location', 'southoutside', 'orientation', 'horizontal');
   output_so1.fig_format(gca, 'line');
   output_so1.fig_save('aggr_collprem', saveFigures, cS);
end



end