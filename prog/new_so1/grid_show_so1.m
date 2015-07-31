function grid_show_so1(saveFigures, gridNo, gNo)
% Compare several sets that vary one parameter along a grid
% ---------------------------------------------------

cS = const_so1(gNo, 1);
gS = grids_so1(gridNo, gNo);
figDir = gS.outDir;

% Delete old output files
delete([figDir, '*.eps']);

setNoV = gS.setNoV;
saveNo = gS.saveNo;
%prefixStr = gS.gridStr;
xLabelStr = gS.xLabelStr;
xV = gS.xValueV;

% Scale growth rates
if gridNo == cS.gridGW2  ||  gridNo == cS.gridGH1  ||  gridNo == cS.gridGW4
   xV = 100 .* xV;
end


% So that figures are saved in right dir
cS = const_so1(gNo, saveNo);

nSet = length(setNoV);


% Show flat spot wages
% grid_flat_spot_show_so1(saveFigures, gridNo, gNo);
% Show effect of perturbing R
% grid_perturb_show_so1(saveFigures, gridNo, gNo);


%%  Assemble results

descrV = cell([nSet, 1]);
versionV = zeros([nSet, 1]);
exitFlagV = zeros([nSet, 1]);

% Overall deviation
devV     = zeros([nSet, 1]);
devMeanV = zeros([nSet, 1]);
%devIqAgeV   = zeros([nSet, 1]);
% devIqExperV = zeros([nSet, 1]);
% iqDevV      = zeros([nSet, 1]);

% betaIqV = zeros([nSet, 1]);

thetaV      = zeros([nSet, 1]);
prefScaleV  = zeros([nSet, 1]);
gPrefScaleV = zeros([nSet, 1]);
avgAlphaV = zeros([nSet, 1]);
alphaM    = zeros([cS.nSchool, nSet]);
deltaM    = zeros([cS.nSchool, nSet]);
avgDeltaV = zeros([nSet, 1]);
wtPAV     = zeros([nSet, 1]);
wtHAV     = zeros([nSet, 1]);
h1StdV    = zeros([nSet, 1]);
gH1V      = zeros([nSet, 1]);
% Growth rate of h1 for each school group (at start of life, not work)
gH1M     = zeros([cS.nSchool, nSet]);
% Skill price growth rates over sample period
spGrowthM = zeros([cS.nSchool, nSet]);

% Aggregates
aggrSTimeM = zeros([cS.nSchool, nSet]);
aggrSTimeV = zeros([nSet, 1]);
% Log h growth over first X years of work
aggrHGrowthM = zeros([cS.nSchool, nSet]);
aggrHGrowthV = zeros([nSet, 1]);

% Selection
% avg across cohorts: mean log h1(CG) - HSG
selH1V = zeros([nSet, 1]);
selAbilV = zeros([nSet, 1]);
% College wage premium, with and without selection; avg across years
selCollPremM = zeros([2, nSet]);

for iSet = 1 : nSet
   setNo = setNoV(iSet);
   cSetS = const_so1(gNo, setNo);
   
   descrV{iSet} = cSetS.setStr;
   
   % ****  Calibrated params
   paramS = var_load_so1(cSetS.vParams, cSetS);
   paramS = param_derived_so1(0, paramS, cSetS);
   avgAlphaV(iSet) = mean(paramS.alphaV);
   alphaM(:, iSet) = paramS.alphaV;
   avgDeltaV(iSet) = mean(paramS.ddhV);
   deltaM(:,iSet)  = paramS.ddhV;
   prefScaleV(iSet) = paramS.prefScale;
   gPrefScaleV(iSet) = paramS.gPrefScale;
   wtPAV(iSet) = paramS.wtPA;
   wtHAV(iSet) = paramS.wtHA;
   gH1V(iSet)  = 100 .* paramS.gH1;
   h1StdV(iSet)   = paramS.h1Std;
   thetaV(iSet)   = paramS.theta;
   
   % ****  Fit
   [calStatS, success, versionV(iSet)] = var_load_so1(cSetS.vCalResults, cSetS);
   if success == 1
      outS = calStatS.calDevS;

      exitFlagV(iSet) = calStatS.exitFlag;

%       if isfield(outS, 'betaIq')
%          betaIqV(iSet) = outS.betaIq;
%       end

      devV(iSet)     = calStatS.dev;
      devMeanV(iSet) = outS.scalarMeanDev;
      %devIqAgeV(iSet)= outS.scalarBetaIqAgeDev;
%       devIqExperV(iSet) = outS.scalarBetaIqExperDev;
%       if isfield(outS, 'scalarIqDev')
%          iqDevV(iSet) = outS.scalarIqDev;
%       end

      % ****  sim stats
      [simStatS, success] = var_load_so1(cS.vSimStats, cSetS);
      if success == 1
         spGrowthM(:, iSet) = 100 .* simStatS.spModelGrowthV;
         if iSet == 1
            spGrowthDataV = 100 .* simStatS.spDataGrowthV;
         end

         selH1V(iSet)   = mean(simStatS.logH1Mean_scM(cS.schoolCG, :) - simStatS.logH1Mean_scM(cS.schoolHSG, :));
         selAbilV(iSet) = mean(simStatS.abilMean_scM(cS.schoolCG, :) - simStatS.abilMean_scM(cS.schoolHSG, :));
         gH1M(:, iSet)  = 100 .* (simStatS.logH1Mean_scM(:, cS.nCohorts) - simStatS.logH1Mean_scM(:, 1)) ...
            ./ (cS.bYearV(cS.nCohorts) - cS.bYearV(1));
         
         % Avg fraction of time spend studying
         aggrSTimeM(:,iSet) = mean(simStatS.meanSTimeFracM, 2);
         aggrSTimeV(iSet)   = mean(simStatS.meanSTimeFracV);
         
         % Avg h growth
         for iSchool = 1 : cS.nSchool
            %ageV = cS.workStartAgeV(iSchool) - 1 + cS.wageGrowthExperV;
            %growthV = squeeze(simStatS.meanLogHM(ageV(2),iSchool,:) - simStatS.meanLogHM(ageV(1),iSchool,:));
            aggrHGrowthM(iSchool, iSet) = mean(simStatS.hGrowthM(iSchool, :));
         end
         aggrHGrowthV(iSet) = mean(simStatS.hGrowthV);
      end      
      
   end
   
   % Selection: College wage premium with and without selection
   %  Averaged over years
   % Wage premium, relative to HSG at fixed age
%    for iCase = 1 : 2
%       if iCase == 1
%          loadVar = cS.vAggrStats;
%       elseif iCase == 2
%          loadVar = cS.vAggrStatsNoSelection;
%       else
%          error('Invalid');
%       end
%       [aggrS, success] = var_load_so1(loadVar, cSetS);
%       if success == 1
%          selCollPremM(iCase,iSet) = mean(aggrS.meanLogWageSchoolM(cS.schoolCG,:) - aggrS.meanLogWageSchoolM(cS.schoolHSG,:));
%       end
%    end

   
%    [loadS, success] = var_load_so1(cS.vSelectionStats, cSetS);
%    if success == 1
%       % Revision to college premium
%       % Mean log wage by [selection, school], avg across cohorts
%       wageM = mean(squeeze(loadS.meanLogWageM(:,cS.wageRefAge,:,:)), 3);
%       if ~isequal(size(wageM), [2, cS.nSchool])
%          error_so1('Invalid sum', cS);
%       end
%       selRevCwpV(iSet) = (wageM(loadS.caseNoSelect,cS.schoolCG) - wageM(loadS.caseNoSelect,cS.schoolHSG)) - ...
%          (wageM(loadS.caseBase,cS.schoolCG) - wageM(loadS.caseBase,cS.schoolHSG));
%    end
end


% Alpha grid: use actual alphas, not grid
%  b/c alphas are in a range in calibration
if gridNo == cS.gridAlpha  % ||  gridNo == cS.grid2Alpha  ||  gridNo == cS.grid1Alpha
   xV = avgAlphaV;
   % x values by [schooling, set]
   xSchoolM = alphaM;
else
   xSchoolM = ones([cS.nSchool, 1]) * xV(:)';
end


%% *******  Aggregates

% Aggr h growth by school
fig_new_so(saveFigures);
hold on;
for iSchool = 1 : cS.nSchool
   plot(xSchoolM(iSchool,:), aggrHGrowthM(iSchool,:), cS.lineStyleV{iSchool}, 'color', cS.colorM(iSchool,:));
end
xlabel(xLabelStr, 'interpreter', 'latex');
ylabel('Aggr. h growth', 'interpreter', 'latex');
legend(cS.schoolLabelV, 'location', 'southoutside', 'orientation', 'horizontal');
figure_format_so(gca, setNo);
save_fig_so([figDir, 'aggr_hgrowth_school'], saveFigures, [], cS);

% Aggr h growth
fig_new_so(saveFigures);
plot(xV, aggrHGrowthV, cS.lineStyleV{1}, 'color', cS.colorM(1,:));
xlabel(xLabelStr, 'interpreter', 'latex');
ylabel('Aggr. h growth', 'interpreter', 'latex');
figure_format_so(gca, setNo);
save_fig_so([figDir, 'aggr_hgrowth'], saveFigures, [], cS);


% Aggr study time by school
fig_new_so(saveFigures);
hold on;
for iSchool = 1 : cS.nSchool
   plot(xSchoolM(iSchool,:), aggrSTimeM(iSchool,:), cS.lineStyleV{iSchool}, 'color', cS.colorM(iSchool,:));
end
xlabel(xLabelStr, 'interpreter', 'latex');
ylabel('Aggr. training time', 'interpreter', 'latex');
%axis_range_lh([NaN, NaN, 0, NaN]);
legend(cS.schoolLabelV, 'location', 'southoutside', 'orientation', 'horizontal');
figure_format_so(gca, setNo);
save_fig_so([figDir, 'aggr_stime_school'], saveFigures, [], cS);


% Aggr study time
fig_new_so(saveFigures);
plot(xV, aggrSTimeV, cS.lineStyleV{1}, 'color', cS.colorM(1,:));
xlabel(xLabelStr, 'interpreter', 'latex');
ylabel('Aggr. training time', 'interpreter', 'latex');
%axis_range_lh([NaN, NaN, 0, NaN]);
figure_format_so(gca, setNo);
save_fig_so([figDir, 'aggr_stime'], saveFigures, [], cS);



%% **********  Results: Parameters

% alpha
fig_new_so(saveFigures);
hold on;
for iSchool = 1 : cS.nSchool
   plot(xSchoolM(iSchool,:), alphaM(iSchool,:), cS.lineStyleV{iSchool}, 'color', cS.colorM(iSchool,:));
end
% plot(xV, avgAlphaV, cS.lineStyleV{1});
% plot(xV, mean(alphaM(1 : cS.schoolHSG, :)),  cS.lineStyleV{2}, 'color', cS.colorM(2,:));
% plot(xV, mean(alphaM(cS.schoolCD : cS.nSchool, :)),  cS.lineStyleV{3}, 'color', cS.colorM(3,:));
xlabel(xLabelStr, 'interpreter', 'latex');
ylabel('$\alpha$', 'interpreter', 'latex');
axis_range_lh([NaN, NaN, 0, NaN]);
legend(cS.schoolLabelV, 'location', 'south', 'orientation', 'horizontal');
figure_format_so(gca, setNo);
save_fig_so([figDir, 'param_alpha'], saveFigures, [], cS);

% delta
fig_new_so(saveFigures);
hold on;
for iSchool = 1 : cS.nSchool
   plot(xSchoolM(iSchool,:), deltaM(iSchool,:), cS.lineStyleV{iSchool}, 'color', cS.colorM(iSchool,:));
end
hold off
xlabel(xLabelStr, 'interpreter', 'latex');
ylabel('$\delta$', 'interpreter', 'latex');
legend(cS.schoolLabelV, 'location', 'south', 'orientation', 'horizontal');
axis_range_lh([NaN, NaN, 0, NaN]);
figure_format_so(gca, setNo);
save_fig_so([figDir, 'param_delta'], saveFigures, [], cS);

% pi
fig_new_so(saveFigures);
plot(xV, prefScaleV, cS.lineStyleV{1});
xlabel(xLabelStr, 'interpreter', 'latex');
ylabel('$\pi$', 'interpreter', 'latex');
axis_range_lh([NaN, NaN, 0, NaN]);
figure_format_so(gca, setNo);
save_fig_so([figDir, 'param_prefscale'], saveFigures, [], cS);

% g(h1)
fig_new_so(saveFigures);
plot(xV, gH1V, cS.lineStyleV{1});
xlabel(xLabelStr, 'interpreter', 'latex');
ylabel('g(h1)', 'interpreter', 'latex');
figure_format_so(gca, setNo);
save_fig_so([figDir, 'growth_gh1'], saveFigures, [], cS);

% gamma a/p
fig_new_so(saveFigures);
plot(xV, wtPAV, cS.lineStyleV{1});
xlabel(xLabelStr, 'interpreter', 'latex');
ylabel('$\gamma_{a,p}$', 'interpreter', 'latex');
figure_format_so(gca, setNo);
save_fig_so([figDir, 'param_gamma_ap'], saveFigures, [], cS);

% gamma a/h
fig_new_so(saveFigures);
plot(xV, wtHAV, cS.lineStyleV{1});
xlabel(xLabelStr, 'interpreter', 'latex');
ylabel('$\gamma_{a,h}$', 'interpreter', 'latex');
figure_format_so(gca, setNo);
save_fig_so([figDir, 'param_gamma_ah'], saveFigures, [], cS);

% theta = std(a)
fig_new_so(saveFigures);
plot(xV, thetaV, cS.lineStyleV{1});
xlabel(xLabelStr, 'interpreter', 'latex');
ylabel('$\theta$', 'interpreter', 'latex');
figure_format_so(gca, setNo);
save_fig_so([figDir, 'endow_theta'], saveFigures, [], cS);

% theta / (1-alpha)
fig_new_so(saveFigures);
plot(xV, thetaV ./ (1 - mean(alphaM)'), cS.lineStyleV{1});
xlabel(xLabelStr, 'interpreter', 'latex');
ylabel('$\theta / (1 - \alpha)$', 'interpreter', 'latex');
figure_format_so(gca, setNo);
save_fig_so([figDir, 'endow_theta_alpha'], saveFigures, [], cS);

% std(h1)
fig_new_so(saveFigures);
plot(xV, h1StdV, cS.lineStyleV{1});
xlabel(xLabelStr, 'interpreter', 'latex');
ylabel('$\sigma(h1)$', 'interpreter', 'latex');
figure_format_so(gca, setNo);
save_fig_so([figDir, 'endow_h1_std'], saveFigures, [], cS);



%%  Deviations

% Several deviations
if 1
   [~, yMax1] = fig_yrange_lh(devV);
   [~, yMax2] = fig_yrange_lh([0, 2 * min(devV)]);
   yMax = min([yMax1, yMax2]);
   legendV = cell([8,1]);
   iLine = 0;
   fig_new_so(saveFigures);
   hold on;
   
   iLine = iLine + 1;
   plot(xV, devV, cS.lineStyleV{iLine}, 'color', cS.colorM(iLine,:));
   legendV{iLine} = 'Overall';
   
   iLine = iLine + 1;
   plot(xV, devMeanV, cS.lineStyleV{iLine}, 'color', cS.colorM(iLine,:));
   legendV{iLine} = 'Mean';
   
%    iLine = iLine + 1;
%    plot(xV, devStdV, cS.lineStyleV{iLine}, 'color', cS.colorM(iLine,:));
%    legendV{iLine} = 'Std';
   
%    if any(iqDevV > 0)  &&  cS.gS.tgIq > 0
%       iLine = iLine + 1;
%       plot(xV, iqDevV, cS.lineStyleV{iLine}, 'color', cS.colorM(iLine,:));
%       legendV{iLine} = 'IQ';
%    end
   
%    if any(devIqExperV > 0)  &&  cS.gS.tgBetaIqExper > 0
%       iLine = iLine + 1;
%       plot(xV, devIqExperV, cS.lineStyleV{iLine}, 'color', cS.colorM(iLine,:));
%       legendV{iLine} = 'IQ exp';
%    end
   
   hold off;
   xlabel(xLabelStr, 'interpreter', 'latex');
   ylabel('Deviation', 'interpreter', 'latex');
   legend(legendV(1:iLine),  'location', 'southoutside', 'orientation', 'horizontal');
   axis_range_lh([NaN, NaN, 0, yMax]);
   figure_format_so(gca, setNo);
   save_fig_so([figDir, 'dev_mult'], saveFigures, [], cS);   
end

% overall deviation
fig_new_so(saveFigures);
plot(xV, devV, cS.lineStyleV{1});
axis_range_lh([NaN, NaN, NaN, min(max(devV) + 0.05, 5 * min(devV))]);
xlabel(xLabelStr, 'interpreter', 'latex');
ylabel('Deviation', 'interpreter', 'latex');
figure_format_so(gca, setNo);
save_fig_so([figDir, 'dev'], saveFigures, [], cS);


% if cS.gS.tgIq > 0
%    % IQ deviation
%    fig_new_so(saveFigures);
%    plot(xV, iqDevV, cS.lineStyleV{1});
%    xlabel(xLabelStr, 'interpreter', 'latex');
%    ylabel('IQ deviation', 'interpreter', 'latex');
%    figure_format_so(gca, setNo);
%    save_fig_so([figDir, 'dev_iq'], saveFigures, [], cS);
% end
% if cS.gS.tgBetaIq > 0
%    % beta IQ
%    fig_new_so(saveFigures);
%    plot(xV, betaIqV, cS.lineStyleV{1});
%    xlabel(xLabelStr, 'interpreter', 'latex');
%    ylabel('$\beta_{IQ}$', 'interpreter', 'latex');
%    axis_range_lh([NaN, NaN, 0, NaN]);
%    figure_format_so(gca, setNo);
%    save_fig_so([figDir, 'iq_beta'], saveFigures, [], cS);
% end


%% *******  Selection

% College premium with and without selection
fig_new_so(saveFigures);
hold on;
for iCase = 1 : 2
   plot(xV, selCollPremM(iCase,:), cS.lineStyleV{iCase}, 'color', cS.colorM(iCase,:));
end
hold off;
xlabel(xLabelStr, 'interpreter', 'latex');
ylabel('College premium');
figure_format_so(gca, setNo);
save_fig_so([figDir, 'sel_rev_cwp'], saveFigures, [], cS);


% Mean log h1: CG - HSG
fig_new_so(saveFigures);
plot(xV, selH1V, cS.lineStyleV{1});
xlabel(xLabelStr, 'interpreter', 'latex');
ylabel('Mean log h1, CG - HSG');
figure_format_so(gca, setNo);
save_fig_so([figDir, 'sel_h1_cg_hsg'], saveFigures, [], cS);

% Mean effective abil: CG - HSG
fig_new_so(saveFigures);
plot(xV, selAbilV, cS.lineStyleV{1});
xlabel(xLabelStr, 'interpreter', 'latex');
ylabel('Mean ability, CG - HSG');
figure_format_so(gca, setNo);
save_fig_so([figDir, 'sel_abil_cg_hsg'], saveFigures, [], cS);

% Growth rate of h1 | s
fig_new_so(saveFigures);
hold on;
for iSchool = 1 : cS.nSchool
   plot(xSchoolM(iSchool,:), gH1M(iSchool,:), cS.lineStyleV{iSchool}, 'color', cS.colorM(iSchool,:));
end
hold off;
xlabel(xLabelStr, 'interpreter', 'latex');
ylabel('g(h1 | s)');
legend(cS.schoolLabelV, 'location', 'south', 'orientation', 'horizontal');
figure_format_so(gca, setNo);
save_fig_so([figDir, 'growth_gh1_school'], saveFigures, [], cS);



%%  Skill prices

% Growth rates of skill prices rel to HSG
fig_new_so(saveFigures);
hold on;
plot(xV, spGrowthM(cS.schoolCG,:) - spGrowthM(cS.schoolHSG,:), cS.lineStyleV{1});
plot(xV, (spGrowthDataV(cS.schoolCG) - spGrowthDataV(cS.schoolHSG)) .* ones(size(xV)), cS.lineStyleV{2});
hold off;
xlabel(xLabelStr, 'interpreter', 'latex');
ylabel('g(college premium) [pct]');
axisV = axis;
if axisV(3) > 0
   axis_range_lh([NaN, NaN, 0, NaN]);
end
figure_format_so(gca, setNo);
save_fig_so([figDir, 'sp_g_cwp'], saveFigures, [], cS);

% Growth rate of skill price HSG and R2
% fig_new_so(saveFigures);
% sortM = sortrows([spGrowthM(cS.schoolHSG,:)',  avgR2V(:)]);
% plot(sortM(:,1), sortM(:,2), cS.lineStyleV{1});
% xlabel('g(w2)', 'interpreter', 'latex');
% ylabel('$R^{2}$', 'interpreter', 'latex');
% axis_range_lh([NaN, NaN, r2AxisRangeV(1), r2AxisRangeV(2)]);
% figure_format_so(gca, setNo);
% save_fig_so([figDir, 'gw2_r2'], saveFigures, [], cS);


% Growth rate of skill prices
fig_new_so(saveFigures);
for iSchool = 1 : cS.nSchool
   subplot(2,2,iSchool);
   hold on;
   plot(xSchoolM(iSchool,:), spGrowthM(iSchool,:), cS.lineStyleV{1});
   plot(xSchoolM(iSchool,:), spGrowthDataV(iSchool) .* ones(size(xV)), cS.lineStyleV{2});
   hold off;
   xlabel(xLabelStr, 'interpreter', 'latex');
   ylabel('g(skill price) [pct]');
   figure_format_so(gca, setNo);
end
save_fig_so([figDir, 'sp_g_sp'], saveFigures, cS.figOpt4S, cS);


% g(h1) against g(w2)
fig_new_so(saveFigures);
sortM = sortrows([spGrowthM(cS.schoolHSG,:)',  gH1V(:)]);
plot(sortM(:,1), sortM(:,2), cS.lineStyleV{1});
xlabel('g(w2)', 'interpreter', 'latex');
ylabel('g(h1)', 'interpreter', 'latex');
figure_format_so(gca, setNo);
save_fig_so([figDir, 'growth_gw2_gH1'], saveFigures, [], cS);




%%  Training gain
if 0
   error('Not updated');   % +++
   meanLogGainM = zeros([cS.nSchool, nSet]);
   for iSet = 1 : nSet
      setNo = setNoV(iSet);
      [gainM, success] = var_load_so1(cS.vTrainingGains, [], gNo, setNo);
      if success == 1
         meanLogGainM(:, iSet) = mean(gainM, 2);
      end
   end
   % Sets with data
   tIdxV = find(meanLogGainM(2,:) ~= 0);
      
   % ****  Training gain against x
   % 1 plot per school group
   if length(tIdxV) > 1
      for iSchool = 1 : cS.nSchool
         fig_new_so(saveFigures);
         iLine = 1;
         plot(xSchoolM(iSchool,tIdxV), meanLogGainM(iSchool,tIdxV), cS.lineStyleV{iLine}, 'color', cS.colorM(iLine,:));
         xlabel(xLabelStr, 'interpreter', 'latex');
         ylabel('Mean log gain');
         %legend(cS.schoolLabelV, 'location', 'south', 'orientation', 'horizontal');
         axis_range_lh([NaN, NaN, 0, NaN]);
         figure_format_so(gca, setNo);
         save_fig_so([figDir, 'train_gain_', cS.schoolSuffixV{iSchool}], saveFigures, [], cS);
      end
   end

   % *** Training gain against alpha
   if length(tIdxV) > 1
      fig_new_so(saveFigures);
      hold on;
      for iSchool = 1 : cS.nSchool
         sortM = sortrows([alphaM(iSchool,tIdxV)',  meanLogGainM(iSchool,tIdxV)']);
         plot(sortM(:,1), sortM(:,2), cS.lineStyleV{iSchool}, 'color', cS.colorM(iSchool,:));
      end
      hold off;
      xlabel('$\alpha$', 'interpreter', 'latex');
      ylabel('Mean log gain');
      legend(cS.schoolLabelV, 'location', 'south', 'orientation', 'horizontal');
      axis_range_lh([NaN, NaN, 0, NaN]);
      figure_format_so(gca, setNo);
      save_fig_so([figDir, 'train_gain_alpha'], saveFigures, [], cS);
   end
end


%%  Table
if 1
   % Columns are sets
   nc = 1 + nSet;
   
   % Rows are parameters / outcomes
   ir = 1;
   ir = ir + 1;   rSetNo = ir;
   ir = ir + 1;   rVersion = ir;
   ir = ir + 1;   rExitFlag = ir;
   ir = ir + 1;   rDev = ir;
   ir = ir + 1;
   ir = ir + 1;   rAlphaHSG = ir;
   ir = ir + 1;   rAlphaCG = ir;
   ir = ir + 1;   rPrefScale = ir;
   ir = ir + 1;   rGPrefScale = ir;
   ir = ir + 1;   rGH1 = ir;
   ir = ir + 1;
   ir = ir + 1;   rStdH1 = ir;
   ir = ir + 1;   rTheta = ir;
   ir = ir + 1;   rThetaAlpha = ir;
   nr = ir;
   tbM = cell([nr, nc]);
   tbS.rowUnderlineV = zeros([nr, 1]);
   tbS.rowUnderlineV(1) = 1;
   tbS.showOnScreen = 1;
   
   % ****  Headers
   tbM{rSetNo, 1} = 'Set';
   tbM{rVersion, 1} = 'Version';
   tbM{rExitFlag, 1} = 'Exit flag';
   tbM{rDev, 1} = 'Dev';
   tbM{rPrefScale, 1}   = 'pi';
   tbM{rGPrefScale, 1}  = 'g(pi)';
   tbM{rAlphaHSG, 1}    = 'alpha HSG';
   tbM{rAlphaCG,  1} = 'alpha CG';
   tbM{rStdH1,  1}   = 'std h1';
   tbM{rGH1, 1}   = 'g(h1)';
   tbM{rTheta, 1}    = 'theta';
   tbM{rThetaAlpha,1} = 'theta/1-alpha';
   
   % ****  Table body
   for iSet = 1 : nSet
      ic = iSet + 1;
      tbM{1, ic} = descrV{iSet};
      tbM{rSetNo, ic}    = sprintf('%i', setNoV(iSet));
      tbM{rVersion, ic}  = sprintf('%i', versionV(iSet));
      tbM{rExitFlag, ic} = sprintf('%i', exitFlagV(iSet));
      tbM{rDev, ic}     = sprintf('%4.2f', devV(iSet));

      tbM{rPrefScale, ic}  = sprintf('%4.2f', prefScaleV(iSet));
      tbM{rStdH1, ic}      = sprintf('%4.2f', h1StdV(iSet));
      tbM{rGH1, ic}        = sprintf('%4.1f', gH1V(iSet));
      tbM{rTheta, ic}      = sprintf('%4.2f', thetaV(iSet));
      tbM{rThetaAlpha, ic} = sprintf('%4.2f', thetaV(iSet) ./ (1 - mean(alphaM(:,iSet))));
      tbM{rGPrefScale, ic} = sprintf('%4.1f', 100 .* gPrefScaleV(iSet));
      tbM{rAlphaHSG, ic}   = sprintf('%4.2f', alphaM(cS.schoolHSG, iSet));
      tbM{rAlphaCG, ic}    = sprintf('%4.2f', alphaM(cS.schoolCG, iSet));
   end
   
   fid = fopen([figDir, 'tb_grid.tex'], 'w');
   latex_texttb_lh(fid, tbM, 'Caption', 'Label', tbS);
   fclose(fid);
   disp('Saved table  tb_grid.tex');
end




end