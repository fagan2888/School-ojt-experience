function pvec = pvector_default(cS)
% Defaults: which params are calibrated?
%{
Only set calBase and calNever here
Experiments can override with calExper
%}

symS = param_so1.symbols;

% Collection of calibrated parameters
pvec = pvectorLH(30, cS.doCalValueV);


%% Endowments

pvec = pvec.change('abilScale', symS.abilScale, 'Ability scale factor', 0.2, 0.05, 0.3, cS.calBase);

pvec = pvec.change('h1Mean', 'h1Mean', 'mean log h1', 0, -1, 1, cS.calNever);
pvec = pvec.change('gH1', 'gH1', 'Growth rate of h1', 0, -0.05, 0.05, cS.calNever);
% Std LOG h1
pvec = pvec.change('h1Std', symS.h1Std, 'Std log h1', 0.13, 0.05, 0.5, cS.calBase);

% Endowment correlations
% Correlation h1 / a
pvec = pvec.change('wtHA', 'wtHA', 'wtHA', 0.5, 0, 2, cS.calBase);

% IQ
% allows IQ to be correlated with a and h1
pvec = pvec.change('wtIQa', 'wtIQa', 'wtIQa', 1, 0, 4, cS.calNever);
% determines IQ noise
pvec = pvec.change('stdIq', symS.stdIq, 'stdIq', 0.55, 0, 1, cS.calBase);


%% Schooling

% Scale param for p - cohort 1
pvec = pvec.change('prefScale', symS.prefScale, 'Scale parameter for preference shocks', ...
   0.5, cS.prefScaleMin, cS.prefScaleMax, cS.calBase);

pvec = pvec.change('gPrefScale', ['g(', symS.prefScale, ')'], 'Growth of scale param', ...
   0, -0.03, 0.03, cS.calNever);

% Parameters governing high school graduation rates
% pvec = pvec.change('prHsgMin', 'prHsgMin', 'Min HSG prob',  0, 0, 0.5, cS.calNever);
% pvec = pvec.change('prHsgMax', 'prHsgMax', 'Max HSG prob',  1, 0, 0.5, cS.calNever);
pvec = pvec.change('prHsgMult',  'prHsgMult',  'Scale parameter',  1.5,  1, 4, cS.calBase);

% Parameters governing college graduation rates
%  If < 1, the range of graduation rates gets too small, which causes problems with school prob
%  calibration
pvec = pvec.change('prCgMult',  'prCgMult',  'Scale parameter',  1.5,  1, 4, cS.calBase);

% % Exponential school productivity
% cS.schoolProd = 0.1; 


%% OJT

% pvec = pvec.change('alphaV', '\alpha_{s}', 'Curvature parameters', 0.4 * ones(cS.nSchool,1), ...
%    0.15 * ones(cS.nSchool,1), 0.85 * ones(cS.nSchool,1), cS.calBase);
% Default: 4 alphas
alphaMin = 0.3;
pvec = pvec.change('alphaHSD', '\alpha_{HSD}', 'Curvature', 0.4, alphaMin, 0.85, cS.calBase);
pvec = pvec.change('alphaHSG', '\alpha_{HSG}', 'Curvature', 0.4, alphaMin, 0.85, cS.calBase);
pvec = pvec.change('alphaCD',  '\alpha_{CD}', 'Curvature', 0.4, alphaMin, 0.85, cS.calBase);
pvec = pvec.change('alphaCG',  '\alpha_{CG}', 'Curvature', 0.4, alphaMin, 0.85, cS.calBase);

pvec = pvec.change('ddhHSD', '\delta_{HSD}', 'Depreciation', 0.05, 0, 0.15, cS.calBase);
pvec = pvec.change('ddhHSG', '\delta_{HSG}', 'Depreciation', 0.05, 0, 0.15, cS.calBase);
pvec = pvec.change('ddhCD',  '\delta_{CD}', 'Depreciation',  0.05, 0, 0.15, cS.calBase);
pvec = pvec.change('ddhCG',  '\delta_{CG}', 'Depreciation',  0.05, 0, 0.15, cS.calBase);

pvec = pvec.change('trainTimeMax',  'lMax', 'Max training time',  0.9,  0.5, 1, cS.calNever);
pvec = pvec.change('trainTimeMin',  'lMin', 'Min training time',  0.02, 0, 0.1, cS.calNever);

pvec = pvec.change('logAV', 'log(A)', 'Log(A)', ...
   -2 * ones([cS.nSchool, 1]),  -4 * ones([cS.nSchool, 1]),  0 * ones([cS.nSchool, 1]),  cS.calBase);
pvec = pvec.change('gA',  'g(A)', 'Growth of A',  0, -0.05, 0.05, cS.calNever);


%% Aggregate output

% Substitution elasticity between college and non-college labor
pvec = pvec.change('seCG',  '\rho_{CG}', 'Substitution elasticity',  3, 0.5, 10, cS.calBase);
pvec = pvec.change('seHS',  '\rho_{HS}', 'Substitution elasticity',  5, 0.5, 10, cS.calBase);


%% Skill prices


% % Skill price growth rates (avg over entire period)
% pvec = pvec.change('spGrowthV',  'g(w)', 'Skill price growth rates',  ...
%    0 * ones([cS.nSchool,1]), -0.03  * ones([cS.nSchool,1]), 0.03  * ones([cS.nSchool,1]), cS.calBase);
% 
% % Log skill price levels (always calibrated)
% % No skill price is normalized. Model wages are in data units
% pvec = pvec.change('spLevelV',  'w0', 'Skill price levels',  ...
%    -0.5 * ones([cS.nSchool,1]), -1  * ones([cS.nSchool,1]), 1  * ones([cS.nSchool,1]), cS.calBase);
% 

%% Other

pvec = pvec.change('R',  'R', 'Gross interest rate',  1.04, 1, 1.1, cS.calNever);



end