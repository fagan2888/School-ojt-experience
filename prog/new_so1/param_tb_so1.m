function param_tb_so1(paramS, gNo, setNo)
% Show calibrated parameters
% ----------------------------------------------

if nargin ~= 3
   error('Invalid nargin');
end

cS = const_so1(gNo, setNo);
saveFigures = 1;

if isempty(paramS)
   paramS = var_load_so1(cS.vParams, cS);
end

%simStatS = var_load_so1(cS.vSimStats, cS);


%% Figure: school costs
if 1
   loadS = var_load_so1(cS.vSimResults, cS);

   fig_new_so(saveFigures);
   hold on;
   for iSchool = 1 : cS.nSchool
      plot(cS.demogS.bYearV,  loadS.sCostM(iSchool,:), cS.lineStyleV{iSchool}, 'color', cS.colorM(iSchool,:));
   end
   
   hold off;
   xlabel('Birth year');
   ylabel('School cost');
   legend(cS.schoolLabelV, 'location', 'south', 'orientation', 'horizontal');
   figure_format_so(gca);
   save_fig_so('param_school_cost', saveFigures, [], cS);
   
   clear loadS;
end



%% ********  Table layout

nc = 0;
nc = nc + 1;   cName = nc;
nc = nc + 1;   cRole = nc;
nc = nc + 1;   cValue = nc;

nr = 20;
tbM = cell([nr, nc]);
tbS.rowUnderlineV = zeros([nr, 1]);
tbS.showOnScreen = 1;

% Header
ir = 1;
tbS.rowUnderlineV(ir) = 1;
tbM{ir,cName} = 'Parameter';
tbM{ir,cRole} = 'Description';
tbM{ir,cValue} = 'Value';


%% ********  Body: OJT

ir = ir + 1;
tbM{ir, cName} = 'On-the-job training';

if cS.calA == 1
   ir = ir + 1;
   tbM{ir,cName} = '$A_{s}$';
   tbM{ir,cRole} = 'Productivity';
   logAStr = sprintf('%4.2f, ', exp(paramS.logAV));
   tbM{ir,cValue} = logAStr(1 : (end-2));
end
if cS.calGA == 1
   ir = ir + 1;
   tbM{ir,cName} = '$g_{A}$';
   tbM{ir,cRole} = 'Productivity growth rate [pct]';
   tbM{ir,cValue} = sprintf(' %4.2f', 100 .* paramS.gA);
end
% Shows all alpha, even if not all are calibrated +++
if any(cS.calAlphaV == 1)
   ir = ir + 1;
   tbM{ir,cName} = '$\alpha_{s}$';
   tbM{ir,cRole} = 'Curvature';
   alphaStr = sprintf('%4.2f, ', paramS.alphaV);
   tbM{ir,cValue} = alphaStr(1 : (end-2));
end
% if cS.calBeta == 1
%    ir = ir + 1;
%    tbM{ir,cName} = '$\beta$';
%    tbM{ir,cRole} = 'Curvature';
%    betaStr = sprintf('%4.2f, ', paramS.betaV);
%    tbM{ir,cValue} = betaStr(1 : (end-2));
% end
if any(cS.calDdhV == 1)
   ir = ir + 1;
   tbM{ir,cName} = '$\delta_{s}$';
   tbM{ir,cRole} = 'Depreciation rate';
   ddhStr = sprintf('%4.3f, ', paramS.ddhV);
   tbM{ir,cValue} = ddhStr(1 : (end-2));
end


% ir = ir + 1;
% tbM{ir, cName} = 'Schooling';
% if cS.calB == 1
%    ir = ir + 1;
%    tbM{ir,cName} = '$B$';
%    tbM{ir,cRole} = 'Productivity';
%    tbM{ir,cValue} = sprintf('%4.3f', paramS.B);
% end


%% *****  Endowments

ir = ir + 1;
tbM{ir, cName} = 'Endowments';

if cS.calH1Std == 1
   ir = ir + 1;
   tbM{ir,cName} = '$\sigma_{h1}$';
   tbM{ir,cRole} = 'Dispersion of $h_{1}$';
   tbM{ir,cValue} = sprintf('%4.3f', paramS.h1Std);
end
if cS.calGH1 == 1
   ir = ir + 1;
   tbM{ir,cName} = '$g_{h1}$';
   tbM{ir,cRole} = 'Growth rate of $h_{1}$ [pct]';
   tbM{ir,cValue} = sprintf('%4.2f', 100 .* paramS.gH1);
end

if cS.calTheta == 1
   ir = ir + 1;
   tbM{ir,cName} = '$\theta$';
   tbM{ir,cRole} = 'Ability scale factor';
   tbM{ir,cValue} = sprintf('%4.3f', paramS.abilScale);
end
if cS.calPrefScale == 1
   ir = ir + 1;
   tbM{ir,cName} = '$\pi_{1}$';
   tbM{ir,cRole} = 'Psychic cost scale factor';
   tbM{ir,cValue} = sprintf('%4.3f', paramS.prefScale);
end
if cS.calGPrefScale == 1
   ir = ir + 1;
   tbM{ir,cName} = '$g_{\pi}$';
   tbM{ir,cRole} = 'Growth rate of $\pi$ [pct]';
   tbM{ir,cValue} = sprintf('%4.2f', 100 .* paramS.gPrefScale);
end

% Endowment correlations
if cS.calWtPA == 1
   ir = ir + 1;
   tbM{ir,cName} = '$\gamma_{ap}$';
   tbM{ir,cRole} = 'Ability weight in psychic cost';
   tbM{ir,cValue} = sprintf(' %4.3f', paramS.wtPA);
end
if cS.calWtHA == 1
   ir = ir + 1;
   tbM{ir,cName} = '$\gamma_{ah}$';
   tbM{ir,cRole} = 'Governs correlation of $\ln h_{1}$ and $a$';
   tbM{ir,cValue} = sprintf(' %4.3f', paramS.wtHA);
end
% if cS.calWtHP == 1
%    ir = ir + 1;
%    tbM{ir,cName} = '$\gamma_{hp}$';
%    tbM{ir,cRole} = 'Governs correlation of $\ln h_{1}$ and $\pi$';
%    tbM{ir,cValue} = sprintf(' %4.3f', paramS.wtHP);
% end

% IQ
if cS.calStdIq == 1
   ir = ir + 1;
   tbM{ir,cName} = '$\sigma_{IQ}$';
   tbM{ir,cRole} = 'Noise in IQ';
   tbM{ir,cValue} = sprintf(' %4.3f', paramS.stdIq);   
end
if cS.calWtIQa == 1
   ir = ir + 1;
   tbM{ir,cName} = '$\gamma_{IQ,a}$';
   tbM{ir,cRole} = 'Governs correlation of $a$ and $IQ$';
   tbM{ir,cValue} = sprintf(' %4.3f', paramS.wtIQa);
end



%% ****  Other 
if 01
   ir = ir + 1;
   tbM{ir, cName} = 'Other';


   % *****  Skill prices
   if any(cS.calSpGrowthV)
      ir = ir + 1;
      tbM{ir,cName} = '$\Delta w_{s}$';
      tbM{ir,cRole} = sprintf('Skill price growth rate, %i-%i [pct]', cS.wageYearV(1), cS.wageYearV(end));
      xStr = sprintf('%4.2f, ', 100 .* paramS.spGrowthV);   
      tbM{ir,cValue} = xStr(1 : (end-2));
   end
   
   % Substitution elasticities (GE)
   if cS.calSubstElast == 1
      ir = ir + 1;
      tbM{ir,cName} = '$(1 + \rho_{HS})^{-1}$, $(1 + \rho_{CG})^{-1}$';
      tbM{ir,cRole} = 'Substitution elasticities';
      xStr = sprintf('%4.2f, ', [paramS.seHS, paramS.seCG]);   
      tbM{ir,cValue} = xStr(1 : (end-2));
   end
end


%% *****  Save table

nr = ir;
tbM = tbM(1 : nr, :);
tbS.rowUnderlineV = tbS.rowUnderlineV(1 : nr);


fid = fopen([cS.tbDir, 'param_tb.tex'], 'w');
latex_texttb_lh(fid, tbM(1:ir,:), 'Caption', 'Label', tbS);
fclose(fid);
disp('Saved table  param_tb.tex');



end