function cS = constants_so1
% Constants that do not depend on group or set

cS.missVal = -9191;
if rand([1,1]) < 0.02    
   cS.dbg = 111;
else
   cS.dbg = 1;
end
cS.dbg = 1; 

% When running unattended, do not pause
cS.unattended = 1;

if exist('/Users/lutz/', 'dir')    
   cS.runLocal = true;
else
   cS.runLocal = false;
end



%%  Variable codes

cS.male = 1;
cS.female = 2;
cS.sexStrV = {'men', 'women'};

cS.raceWhite = 1;
cS.raceOther = 2;


% What is calibrated when?
cS.calNever = 21;
cS.calBase = 43;
cS.calSet = 94;
cS.doCalValueV = [cS.calBase, cS.calSet, cS.calNever];


%% Data constants
% how to hook those into cps routines? +++

% Years with wage data
cS.wageYearV = 1964 : 2010;




%% Model / data constants that never change

% School groups
cS.schoolHSD = 1;    cS.iHSD = 1;
cS.schoolHSG = 2;    cS.iHSG = 2;
cS.schoolCD = 3;     cS.iCD = 3;
cS.schoolCG = 4;     cS.iCG = 4;
cS.nSchool = 4;
cS.schoolLabelV = {'HSD', 'HSG', 'CD', 'CG'};
% Figure suffixes
cS.schoolSuffixV = {'s1', 's2', 's3', 's4'};



%% For results

% Regression alpha
cS.rAlpha = 0.05;

% Show model / data in this order
cS.iModel   = 1;
cS.iData    = 2;

% Format figures for slides?
cS.slideOutput = 0;




end