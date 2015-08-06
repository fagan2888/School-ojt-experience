function fit_school_cohort(saveFigures, gNo, setNo)

figS = const_fig_so1;
dirS = param_so1.directories(gNo, setNo);
varS = param_so1.var_numbers;
cS = const_so1(gNo, setNo);
simS = var_load_so1(varS.vSimResults, cS);

cdS = const_data_so1(gNo);
tgS = var_load_so1(varS.vCalTargets, cdS);

if 1
   output_so1.fig_new(saveFigures);
   
   hold on;
   for iSchool = 1 : cS.nSchool
      plot(cS.demogS.bYearV,  tgS.sFrac_scM(iSchool,:),    figS.lineStyleDenseV{1},  'Color', figS.colorM(iSchool,:));
      plot(cS.demogS.bYearV,  simS.sFrac_scM(iSchool,:), figS.lineStyleDenseV{2},  'Color', figS.colorM(iSchool,:));
   end
   hold off;
   
   axisV = axis;
   axisV(3) = 0;
   axis(axisV);
   xlabel('Birth year');
   ylabel('Fraction in each school group');
   legend({'Data', 'Model'}, 'location', 'southoutside', 'orientation', 'horizontal');

   output_so1.fig_format(gca, 'line');
   figFn = 'school_cohort';
   output_so1.fig_save(fullfile(dirS.fitDir, figFn), saveFigures, cS);
   %return;
end


