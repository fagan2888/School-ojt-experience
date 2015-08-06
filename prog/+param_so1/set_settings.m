function cS = set_settings(cInS)
% Set: Override group default parameters
%{
Updates cS, pvec
Adds cS.setS
%}
% update +++++

cS = cInS;
setNo = cS.setNo;


%% Set numbers

% Default
setS.setDefault = 1;
% Test case. Constant skill prices. No calibration
setS.setTest = 2;
% Simple case - to get calibration started
setS.setSimple = 3;
% Low subst elast
setS.setLowSubstElast = 4;
% Force sorting by ability or h1
setS.setSmallPsyCost = 9;
% Force correlation h1, a
setS.setCorrHA = 11;
% Corr h1, a  and  force sorting
setS.setSortingCorrHA = 10;

setS.dataSetNo = 901;


%% Defaults

cS.isDataSetNo = false;
setS.setStr = sprintf('set%03i', setNo);


%% Individual sets

if setNo == setS.dataSetNo
   % *******  Data sets
   cS.dbg = 111;
   cS.isDataSetNo = true;
   
else      
   % *****  Individual sets   
   if setNo == setS.setDefault
      % Keep everything at default
      
   elseif setNo == setS.setTest
      % cS.nSim = 500;
      % Skill prices = smoothed and extended data wages
      cS.spSpecS = skillPriceSpecs_so1('wageYears', 'dataWages', 'fixedGrowth', 'fixedGrowth');
      % Fix subst elasticities
      cS.pvector = cS.pvector.change('seCG',  [], [],  3, 0.5, 10, cS.calNever);
      cS.pvector = cS.pvector.change('seHS',  [], [],  5, 0.5, 10, cS.calNever);
      % Fix all alphas
      %cS.pvector = cS.pvector.calibrate('alphaHSD', cS.calNever);
      %cS.pvector = cS.pvector.calibrate('alphaHSG', cS.calNever);
      %cS.pvector = cS.pvector.calibrate('alphaCD', cS.calNever);
      %cS.pvector = cS.pvector.calibrate('alphaCG', cS.calNever);
      
%    elseif setNo == setS.setLowSubstElast
%       setS.setStr = 'low subst elast';
%       cS.seCgUb = 2;
%       cS.seHsUb = 4;
% 
%    elseif setNo == setS.setSmallPsyCost
%       % Force sorting
%       setS.setStr = 'strong sorting';
%       % Scale param for p - cohort 1
%       cS.prefScale = 0.05;
%       cS.calPrefScale = 0;
%       % Growth rate of prefScale (add this amount each period)
%       cS.gPrefScale = 0;
%       cS.calGPrefScale = 0;
%       
%    elseif setNo == setS.setCorrHA
%       % Force high correlation h1, a
%       cS.calWtHA = 1;
%       cS.wtHA = 0.75;
%       cS.wtHAMin = 0.5;
%       cS.wtHAMax = 1;    
%       setS.setStr = 'corr h a';
%       
%    elseif setNo == setS.setSortingCorrHA      
%       % Force high correlation h1, a
%       cS.calWtHA = 1;
%       cS.wtHA = 0.75;
%       cS.wtHAMin = 0.5;
%       cS.wtHAMax = 1;    
%       % Force sorting
%       % Scale param for p - cohort 1
%       cS.prefScale = 0.05;
%       cS.calPrefScale = 0;
%       % Growth rate of prefScale (add this amount each period)
%       cS.gPrefScale = 0;
%       cS.calGPrefScale = 0;
%       setS.setStr = 'sorting and corr h a';
         
   else
      error('Invalid');
   end

%else
%   error('Invalid case');
end


cS.setS = setS;

end