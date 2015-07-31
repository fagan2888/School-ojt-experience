function preamble_so1(gNo, setNo)
% Write latex commands that define constants for preamble of paper
%{
Common constants written by preamble_so
Group constants written by preamble_group_so1
Variable names cannot contain numbers
Best to put data constants into the cps preamble

Not clear how to include any of this into paper. Preamble would have to pull values from many sets
%}
% ------------------------------------------------

cS = const_so1(gNo, setNo);

paramS = var_load_so1(cS.vParams, cS);
calS   = var_load_so1(cS.vCalResults, cS);

tbFn = [cS.tbDir, 'preamble_so1.tex'];
fp = fopen(tbFn, 'w');


%% Fixed parameters (typically set in group preamble)



%%  Potentially Calibrated parameters

% No of calibrated params, but that includes skill price spline params
nCalParams = length(calS.solnV);
fprintf(fp, '\\newcommand{\\nCalParams}{%i}\n', nCalParams);
% No of calibrated skill price parameters
nSplineParams = length(paramS.logWNodeM(:));
fprintf(fp, '\\newcommand{\\nSpParams}{%i}\n', nSplineParams);
% No of calibrated params, not counting splines, but counting skill weights
%  Code is not robust. Take out levels and growth rates of skill prices. Put in same for skill
%  weights
fprintf(fp, '\\newcommand{\\nCalParamsNet}{%i}\n', nCalParams - nSplineParams);


fprintf(fp, '\\newcommand{\\pTheta}{%4.2f}\n', paramS.theta);
%fprintf(fp, '\\newcommand{\\pAlpha}{%4.2f}\n', paramS.alpha);
fprintf(fp, '\\newcommand{\\gHEndow}{%3.1f}\n', 100 .* paramS.gH1);
%fprintf(fp, '\\newcommand{\\ddh}{%4.1f}\n', 100 .* (1 - paramS.ddh1));

% Range of alphas, to nearest 0.05
alphaV = round(paramS.alphaV .* 20) ./ 20;
fprintf(fp, '\\newcommand{\\alphaLow}{%3.1f}\n', min(alphaV));
fprintf(fp, '\\newcommand{\\alphaHigh}{%3.1f}\n', max(alphaV));

% Range of deltas, to nearest 0.005
ddhV = round(paramS.ddhV .* 1000) ./ 1000;
fprintf(fp, '\\newcommand{\\ddhLow}{%3.1f}\n',  100 .* min(ddhV));
fprintf(fp, '\\newcommand{\\ddhHigh}{%3.1f}\n', 100 .* max(ddhV));




%% **********  Results


fclose(fp);
disp(['Saved table  ',  tbFn]);

type(tbFn);


end