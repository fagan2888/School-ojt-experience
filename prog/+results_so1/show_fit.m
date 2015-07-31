function show_fit(saveFigures, gNo, setNo)
% Show how model fits wage profiles by cohort
% --------------------------------------------

cS = const_so1(gNo, setNo);
varS = param_so1.var_numbers;

cdS = const_data_so1(gNo);
tgS = var_load_so1(varS.vCalTargets, cdS);

% Individual level histories
simS = var_load_so1(varS.vSimResults, cS);

data_ascM = tgS.logWage_ascM;
model_ascM = simS.logWage_ascM;

valid_ascM = (tgS.wageWt_ascM > 0) .* (data_ascM ~= cS.missVal)  .*  (model_ascM ~= cS.missVal);
resid_ascM = model_ascM - data_ascM;
vIdxV      = find(valid_ascM == 1);
wt_ascM    = tgS.wageWt_ascM .* valid_ascM;


% Fit: log wage; one plot per school group
results_so1.fit_by_school(model_ascM, data_ascM, saveFigures, cS);
results_so1.fit_by_cohort(model_ascM, data_ascM, saveFigures, cS);

return % +++++


%% Histogram of residuals
if 1   
   output_so1.fig_new(saveFigures);
   hist_resid(model_ascM, data_ascM, wt_ascM, cS);
   xlabel('Residual log wage');
   output_so1.fig_format(gca);
   output_so1.fig_save('fit_resid_hist', saveFigures, [], cS);
end

% ****  By schooling
if 1
   for iSchool = 1 : cS.nSchool
%       dataV  = data_ascM(:, iSchool, :);
%       dataV  = dataV(:);
%       residV = resid_ascM(:,iSchool,:);
%       residV = residV(:);
%       wtV    = tgS.wageWt_ascM(:,iSchool,:) .* valid_ascM(:,iSchool,:);
%       wtV    = wtV(:);
%       idxV   = find(wtV > 0  &  residV ~= cS.missVal);
%       residV = residV(idxV);
%       wtV    = wtV(idxV) ./ sum(wtV(idxV));
%       dataV  = dataV(idxV);
      output_so1.fig_new(saveFigures);
      hist_resid(model_ascM(:,iSchool,:), data_ascM(:,iSchool,:), wt_ascM(:,iSchool,:), cS);
      
%       binEdgesV = -0.5 : 0.05 : 0.5;
%       binEdgesV(end) = max(binEdgesV(end), max(residV) + 0.01);
%       
%       [rStd, rMean] = std_w(residV, wtV, cS.dbg);
%       rss = sum(residV .^ 2  .* wtV) ./ sum(wtV);
%       dMean = sum(dataV .* wtV) ./ sum(wtV);
%       tss = sum((dataV - dMean) .^ 2  .* wtV) ./ sum(wtV);
%       fprintf('iSchool: %i    std resid: %5.2f    mean resid: %5.2f    tss: %5.2f    rss: %5.2f    R2: %5.2f \n', ...
%          iSchool,  rStd, rMean,  tss, rss, 1 - rss / tss);
%       
%       showPlot = 1;
%       hist_weighted(residV, wtV, binEdgesV, showPlot, cS.dbg);
      xlabel('Residual log wage');
%       text(0.3, 0.3, sprintf('R^2: %4.2f   std: %4.2f', 1-rss/tss, rStd));
      output_so1.fig_format(gca);
      output_so1.fig_save(['fit_resid_hist_', cS.schoolSuffixV{iSchool}], saveFigures, [], cS);
   end
end




end


%% Histogram of residuals
function hist_resid(modelV, dataV, wtV, cS)
% Show histogram of residuals + some stats about fit

modelV = modelV(:);
dataV  = dataV(:);
wtV    = wtV(:);

idxV   = find(dataV ~= cS.missVal  &  modelV ~= cS.missVal  &  wtV > 0);
wtV    = wtV(idxV) ./ sum(wtV(idxV));
modelV = modelV(idxV);
dataV  = dataV(idxV);
residV = modelV - dataV;
totalWt = sum(wtV);

% binEdgesV = -0.5 : 0.05 : 0.5;
% binEdgesV(end) = max(binEdgesV(end), max(residV) + 0.01);

[rStd, rMean] = std_w(residV, wtV, cS.dbg);
rss = sum(residV .^ 2  .* wtV) ./ totalWt;
dMean = sum(dataV .* wtV) ./ totalWt;
tss = sum((dataV - dMean) .^ 2  .* wtV) ./ totalWt;
fprintf('std resid: %5.2f    mean resid: %5.2f    tss: %5.2f    rss: %5.2f    R2: %5.2f \n', ...
   rStd, rMean,  tss, rss, 1 - rss / tss);

[yV, xV] = ksdensity(residV, 'weights', wtV);

plot(xV, yV);
axisV = axis;

% showPlot = 1;
% hist_weighted(residV, wtV, binEdgesV, showPlot, cS.dbg);
text(axisV(1) + 0.1 * (axisV(2)-axisV(1)), axisV(3) + 0.1 * (axisV(4)-axisV(3)), ...
   sprintf('R^2: %4.2f   std: %4.2f', 1-rss/tss, rStd), 'Fontsize', cS.figFontSize);

end

