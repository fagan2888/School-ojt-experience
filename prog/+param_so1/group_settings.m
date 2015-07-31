function [gS, pvec] = group_settings(pvecIn, gNo)
%{
Groups determine
- calibration targets
- data construction
- restriction on the model (e.g. g(A) = 0, alpha(HS)=alpha(HSD))
- tgIq: weight on IQ targets

IN
   pvec :: pvectorLH

%}

pvec = pvecIn;


%% Group numbers

gS.gDefault = 1;
% 2 alphas, 2 deltas
gS.gTwoAlpha = 2;
% Same with IQ targets
gS.gIqTg = 3;
% Testing
gS.gTest = 4;


%% Default Model Features

% No of persons to simulate in each cohort
gS.nSim = 1e3;


% Does model have any IQ targets?
gS.hasIQ = 0;

% % Year range over which constant sbtc is assumed
% gS.sbtcAllYears = 21;
% gS.sbtcWageYears = 23;     % only gS.wageYearV (in sample)
% gS.sbtcYears = gS.sbtcAllYears;
% 
% % How to handle out of sample skill prices
% % Penalty from constant SBTC
% gS.spOutOfSampleSbtc = 39;
% % On growth trend in first / last year of skill prices (these years are arbitrary +++)
% gS.spOutOfSampleOnTrend = 41;
% gS.spOutOfSample = gS.spOutOfSampleSbtc;


% Settings for skill price paths
gS.spS = skillPriceSpecs_so1('wageYears', 'constGrowth', 'constGrowth');


%% Default calibration targets

% tgStdLogWage: weight on std log wage targets

% Target constant growth of all skill weights
gS.tgGSkillWeight = false;

% gS.calWtIQa = 0;
% Target IQ percentiles
gS.tgIq = 0;
%  Tg beta iq
gS.tgBetaIq = 0;
%  Tg betaIQ by experience
gS.tgBetaIqExper = 0;



if gNo == gS.gDefault
   
elseif gNo == gS.gTest
   gS.nSim = 100;
   
elseif gNo == gS.gTwoAlpha  ||  gNo == 3  ||  gNo == 4
   % Restrictive case. To check convergence / identification
   gS.sameAlpha = gS.twoAlphas;
   gS.sameDdh   = gS.twoDdh;
   % A does not grow
   gS.calGA = 0;
   gS.gA    = 0;
   % h1 does not grow
   gS.calGH1 = 0;
   gS.gH1 = 0;
   % Pref shocks constant
   %gS.calGPrefScale = 0;
   %gS.gPrefScale = 0;
   % No a in pref shock
   gS.calWtPA = 0;
   gS.wtPA = 0;
   % Theta is fixed
   gS.calTheta = 0;
   gS.theta = 0.15;

   if gNo == 3  ||  gNo == 4
      % IQ targets
      gS.hasIQ = 1;
      gS.tgBetaIqExper = 1;
      gS.tgIq = 1;
      gS.tgBetaIq = 0;
      % IQ = a
      gS.wtIQa = 1;
      gS.calWtIQa = 0;
      gS.calStdIq = 1;
      % Need to allow for correlation alpha, psy cost
      gS.calWtPA = 1;
      % Need to calibrate theta
      gS.calTheta = 1;
      if gNo == 4
         % More skill price nodes
         gS.spNodeGap = 5;
         % Const sbtc only in sample
         gS.sbtcYears = gS.sbtcWageYears;
         % Out of sample: on trend in 1st / last year
         gS.spOutOfSample = gS.spOutOfSampleOnTrend;
      end
   end
   
elseif gNo == 5
   % Cal g(A)
   gS.calGA = 1;
elseif gNo == 6
   % Shut down potentially unidentified params
   gS.calGA = 0;
   gS.gA    = 0;
   gS.calWtPA = 0;
   gS.wtPA    = 0;
   gS.calWtHA = 0;
   gS.wtHA    = 0;
   %gS.calGPrefScale = 0;
   %gS.gPrefScale = 0;
else
   error('Invalid gNo');
end


end