function preamble_group_so1(gNo, setNo)
% Write latex commands that define constants for preamble of paper
% Group specific variables
%{
Common constants written by preamble_so
Variable names cannot contain numbers
Best to put data constants into the cps preamble

%}
% ------------------------------------------------

cS = const_so1(gNo, setNo);
if setNo ~= cS.dataSetNo
   error_so1('Only for data set no', cS);
end

tbFn = [cS.tbDir, 'preamble_so1.tex'];
fp = fopen(tbFn, 'w');




%% ********  Fixed parameters

% ****** Demographics

% fprintf(fp, '\\newcommand{\\ageRetire}{%i}\n', cS.ageRetire);

% No of cohorts
fprintf(fp, '\\newcommand{\\nCohorts}{%i}\n', cS.nCohorts);
% Earliest cohort
fprintf(fp, '\\newcommand{\\bYearFirst}{%i}\n', cS.bYearV(1));
% Latest cohort
fprintf(fp, '\\newcommand{\\bYearLast}{%i}\n', cS.bYearV(end));
fprintf(fp, '\\newcommand{\\yearsInCohort}{%i}\n', cS.bYearV(2) - cS.bYearV(1));


% ********  Endowments

fprintf(fp, '\\newcommand{\\lBar}{%4.1f}\n', cS.maxTrainTime);



% ******  skill prices

fprintf(fp, '\\newcommand{\\ssSkillPriceGrowth}{%i}\n', round(100 .* cS.ssSkillPriceGrowth));

fprintf(fp, '\\newcommand{\\spYearOne}{%i}\n', cS.spS.spYearV(1));
fprintf(fp, '\\newcommand{\\spYearEnd}{%i}\n', cS.spS.spYearV(end));

% Number of spline nodes
fprintf(fp, '\\newcommand{\\nSpNodes}{%i}\n', length(cS.spNodeV));

% Other
fprintf(fp, '\\newcommand{\\grossInt}{%4.2f}\n', cS.R);
fprintf(fp, ['\\newcommand{\\nSim}{', separatethousands(cS.gS.nSim, ',', 0), '}\n']);






%% *****  Save table


fclose(fp);
disp(['Saved table  ',  tbFn]);

type(tbFn);


end