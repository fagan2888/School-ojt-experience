function aggr_ls_collprem(saveFigures, gNo)
% Show aggregate labor supply college/non-college vs college premium
%{
Checked: +++
%}

cS = const_data_so1(gNo);
yearV = cS.wageYearV;
nYr = length(yearV);
varS = param_so1.var_numbers;
figS = const_fig_so1;

tgS = var_load_so1(varS.vCalTargets, cS);


%%  Construct labor by school


% Hours by college / non-college
% Count half of CD as unskilled; as in Autor et al 
hours2M = zeros([2, nYr]);
hours2M(1, :) = sum(tgS.aggrHours_stM(cS.schoolHSD,:) + tgS.aggrHours_stM(cS.schoolHSG,:) + ...
   0.5 .* tgS.aggrHours_stM(cS.schoolCD, :));
hours2M(2, :) = 0.5 .* tgS.aggrHours_stM(cS.schoolCD, :) + tgS.aggrHours_stM(cS.schoolCG, :);
relLSV = log_lh(hours2M(2,:) ./ hours2M(1,:), cS.missVal)';
if ~v_check(relLSV, 'f', [nYr, 1], cS.missVal, [])
   error('Invalid');
end

% Detrend
idxV = find(relLSV ~= cS.missVal);
gLS = (relLSV(idxV(end)) - relLSV(idxV(1))) ./ (idxV(end) - idxV(1));
relLSV(idxV) = relLSV(idxV) - gLS .* (idxV - idxV(1));


%%  College premium
% Years match cS.wageYearV
% Constant composition wage premium

collPremV = (tgS.logWage_stM(cS.schoolCG,:) - tgS.logWage_stM(cS.schoolHSG,:))';
if ~v_check(collPremV, 'f', [nYr, 1], cS.missVal, [])
   error('Invalid');
end

% Detrend
idxV = find(collPremV ~= cS.missVal);
gLS = (collPremV(idxV(end)) - collPremV(idxV(1))) ./ (idxV(end) - idxV(1));
collPremV(idxV) = collPremV(idxV) - gLS .* (idxV - idxV(1));


%%  Plot

output_so1.fig_new(saveFigures);
idxV = find(relLSV ~= cS.missVal  &  collPremV ~= cS.missVal);
hold on;
iLine = 1;
plot(yearV(idxV),  relLSV(idxV) - relLSV(idxV(1)),  figS.lineStyleDenseV{iLine}, 'color', figS.colorM(iLine,:));
iLine = iLine + 1;
plot(yearV(idxV),  collPremV(idxV) - collPremV(idxV(1)),  figS.lineStyleDenseV{iLine}, 'color', figS.colorM(iLine,:));
hold off;

xlabel('Year');
legend({'Rel LS', 'Coll prem'}, 'location', 'best');
output_so1.fig_format(gca, 'line');
output_so1.fig_save('aggr_ls_collprem', saveFigures, cS);


%% Relative labor supplies
if 1
   output_so1.fig_new(saveFigures);
   hold on;
   for iSchool = 1 : cS.nSchool
      iLine = iSchool;
      yV = tgS.aggrHours_stM(iSchool, :) ./ tgS.aggrHours_stM(iSchool, 1);
      plot(cS.wageYearV,  log(yV),  figS.lineStyleDenseV{iLine}, 'color', figS.colorM(iLine,:));
   end
   hold off;

   xlabel('Year');
   ylabel('Log hours');
   legend(cS.schoolLabelV, 'location', 'best');
   output_so1.fig_format(gca, 'line');
   output_so1.fig_save('aggr_ls', saveFigures, cS);
end


end