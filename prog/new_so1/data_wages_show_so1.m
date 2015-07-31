function data_wages_show_so1(saveFigures, gNo, setNo)
% Show wage data by year
%{
Uses mean log wage with constant weights

Checked: 2014-apr-7
%}
% ---------------------------------

cS = const_so1(gNo, setNo);

saveS = var_load_so1(cS.vAggrCpsStats, cS);
% Use constant weights
iCase = saveS.iAdj;

%[yMin, yMax] = y_range_so1(saveS.medianWageYearM(:), cS.missVal);

% Compute alternative mean log wage series, from cells
% tgS = var_load_so1(cS.vCalTargets, cS);


%%  Plot
if saveFigures >= 0
   fig_new_so(saveFigures);
   hold on;
   
   for iSchool = 1 : cS.nSchool
      %idxV = find(saveS.medianWageYearM(:, iSchool) > 0);
      if cS.useMedianWage == 1
         logWageV = saveS.medianWage_stcM(iSchool, :, iCase);
         logWageV = log_lh(logWageV(:), cS.missVal);
      else
         logWageV = saveS.meanLogWageSchoolM(iSchool, :, iCase);
      end
      
      idxV = find(logWageV ~= cS.missVal);
      dataV = logWageV(idxV);
      plot(saveS.yearV(idxV), dataV, '-', 'Color', cS.colorM(iSchool,:));
      plot(saveS.yearV(idxV), hpfilter(dataV, cS.hpFilterParam), '-', 'Color', cS.colorM(iSchool,:));
      
%       % From cell data
%       wageV = tgS.meanLogWageSchoolYearM(iSchool,:);
%       idxV = find(wageV ~= cS.missVal);
%       plot(cS.wageYearV(idxV),  wageV(idxV) + log(cS.wageScale),  '--',  'color',  cS.colorM(iSchool,:));
   end
   
   hold off;
   %axisV = axis;
   %axis([axisV(1:2), 0, yMax]);  
   xlabel('Year');
   title('Mean log wage by school and year');
   
   figure_format_so(gca);
   save_fig_so('wage_school_year', saveFigures, [], cS);
end


end