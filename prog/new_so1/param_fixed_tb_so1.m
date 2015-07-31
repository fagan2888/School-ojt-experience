function param_fixed_tb_so1(gNo, setNo)
% Show fixed parameters
%{
For calibrated parameters: simply copy code out of param_tb
Except: use cS.x instead of paramS.x
%}
% ----------------------------------------------

if nargin ~= 2
   error('Invalid nargin');
end

cS = const_so1(gNo, setNo);



% ********  Table layout

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


% ********  Body

% Demographics

ir = ir + 1;
tbM{ir,cName} = '$T$';
tbM{ir,cRole} = 'Lifespan';
tbM{ir,cValue} = sprintf('%i', cS.ageRetire);

% Cohorts
ir = ir + 1;
tbM{ir, cName} = '$c$';
tbM{ir, cRole} = 'Birth cohorts';
vStr = [sprintf('%i, ', cS.bYearV(1:3)), '...', sprintf(', %i', cS.bYearV((cS.nCohorts-2) : cS.nCohorts))];
tbM{ir, cValue} = vStr;
 
% 
% tbS.rowUnderlineV(ir) = 1;


%ir = ir + 1;
%tbM{ir, 1} = 'School';

ir = ir + 1;
tbM{ir,cName} = '$T_{s}$';
tbM{ir,cRole} = 'School duration';
TsStr = sprintf('%i, ', cS.workStartAgeV - cS.age1);
tbM{ir,cValue} = TsStr(1 : (end-2));



% *******  OJT technology

% Shows all alpha even if some are calibrated +++
   % needs to correctly handle the case where only 2 alpha are calibrated
if any(cS.calAlphaV == 0)  &&  (cS.sameAlpha == 0)
   ir = ir + 1;
   tbM{ir,cName} = '$\alpha_{s}$';
   tbM{ir,cRole} = 'Curvature of training technology';
   xStr = sprintf('%5.3f, ', cS.alphaV);
   tbM{ir,cValue} = xStr(1 : (end-2));
end
if cS.calGA == 0  &&  cS.gA ~= 0
   ir = ir + 1;
   tbM{ir,cName} = '$g_{A}$';
   tbM{ir,cRole} = 'Productivity growth rate';
   tbM{ir,cValue} = sprintf(' %5.4f', cS.gA);
end


% ********  Endowments
if cS.calPrefScale == 0
   ir = ir + 1;
   tbM{ir,cName} = '$\pi$';
   tbM{ir,cRole} = 'Psychic cost scale factor';
   tbM{ir,cValue} = sprintf('%4.3f', cS.prefScale);
end
if cS.calGPrefScale == 0  &&  cS.gPrefScale ~= 0
   ir = ir + 1;
   tbM{ir,cName} = '$g_{\pi}$';
   tbM{ir,cRole} = 'Growth rate of $\pi$';
   tbM{ir,cValue} = sprintf('%5.4f', cS.gPrefScale);
end

% Endowment correlations
if cS.calWtPA == 0
   ir = ir + 1;
   tbM{ir,cName} = '$\gamma_{ap}$';
   tbM{ir,cRole} = 'Ability weight in psychic cost';
   tbM{ir,cValue} = sprintf(' %4.3f', cS.wtPA);
end
if cS.calWtHA == 0
   ir = ir + 1;
   tbM{ir,cName} = '$\gamma_{ah}$';
   tbM{ir,cRole} = 'Governs correlation of $\ln h_{1}$ and $a$';
   tbM{ir,cValue} = sprintf(' %4.3f', cS.wtHA);
end


% *** Other

%ir = ir + 1;
%tbM{ir, 1} = 'Other';

ir = ir + 1;
tbM{ir,cName} = '$\ell_{t,s,c}$';
tbM{ir,cRole} = 'Market hours';
tbM{ir,cValue} = 'CPS data';


% Skill price nodes
ir = ir + 1;
tbM{ir,cName} = 'n/a';
tbM{ir,cRole} = 'Nodes of skill price spline';
n = length(cS.spNodeV);
nodeStr = [sprintf('%i, ', cS.spNodeV(1:3)), '...', sprintf(', %i', cS.spNodeV((n-2):n))];
tbM{ir,cValue} = nodeStr;


ir = ir + 1;
tbM{ir,cName} = '$R$';
tbM{ir,cRole} = 'Gross interest rate';
tbM{ir,cValue} = sprintf('%5.2f', cS.R);


nr = ir;
tbM = tbM(1 : nr, :);
tbS.rowUnderlineV = tbS.rowUnderlineV(1 : nr);


fid = fopen([cS.tbDir, 'param_fixed_tb.tex'], 'w');
latex_texttb_lh(fid, tbM(1:ir,:), 'Caption', 'Label', tbS);
fclose(fid);
disp('Saved table  param_fixed_tb.tex');



end