function preamble_make(gNo, setNo)
% Write data for preamble
%{
Various functions can add to preamble.
It must be initialized with preamble_init first
%}

cS = const_so1(gNo, setNo);
varS = param_so1.var_numbers;
calS = var_load_so1(varS.vCalResults, cS);
paramS = var_load_so1(varS.vParams, cS);


%% Notation for model parameters
% Each potentially calibrated parameter gets a newcommand

for i1 = 1 : cS.pvector.np
   nameStr = cS.pvector.nameV{i1};
   if length(nameStr) > 1
      ps = cS.pvector.retrieve(nameStr);
      results_so1.preamble_add(nameStr,  ps.symbolStr,  ps.descrStr,  cS);
   end
end


%% Other model notation

outS = param_so1.symbols;
fnV = fieldnames(outS);
for i1 = 1 : length(fnV)
   results_so1.preamble_add(fnV{i1},  outS.(fnV{i1}),  'Symbol', cS);
end


%% Data constants

% +++ cpi base year : where is it set?
add_one('cpiBaseYear',  2010, '%i',  'CPI base year',  cS);
add_one('dataYearOne',  cS.wageYearV(1) + 1, '%i', 'Data year 1', cS);
add_one('dataYearLast', cS.wageYearV(end) + 1, '%i', 'Data year N', cS);
add_one('wageYearOne',  cS.wageYearV(1), '%i', 'Wage year 1', cS);
add_one('wageYearLast', cS.wageYearV(end), '%i', 'Wage year N', cS);

demogS = cS.demogS;
add_one('bYearFirst', demogS.bYearV(1), '%i', 'Birth year 1', cS);
add_one('bYearLast', demogS.bYearV(end), '%i', 'Birth year N', cS);
add_one('nCohorts', demogS.nCohorts, '%i', 'No of cohorts', cS);
add_one('ageOne', demogS.age1, '%i', 'Age 1', cS);
add_one('ageRetire', demogS.ageRetire, '%i', 'Retirement age', cS);
add_one('ageOneHSD',  demogS.workStartAgeV(cS.iHSD), 'i', 'Work start', cS);
add_one('ageOneHSG',  demogS.workStartAgeV(cS.iHSG), 'i', 'Work start', cS);
add_one('ageOneCG',  demogS.workStartAgeV(cS.iCG), 'i', 'Work start', cS);

dataS = cS.dataS;
add_one('ageRangeYoung', sprintf('%i-%i', dataS.ageRangeYoungOldM(1, :)), '%s', 'Young ages', cS);
add_one('ageRangeMiddle', sprintf('%i-%i', dataS.ageRangeYoungOldM(2, :)), '%s', 'Middle ages', cS);
add_one('ageRangeOld', sprintf('%i-%i', dataS.ageRangeYoungOldM(3, :)), '%s', 'Old ages', cS);

add_one('hpParamHours', cS.hpFilterHours, '%i', 'Smoothing hours', cS);


%% Model constants

% *****  Skill prices

add_one('spYearOne',  cS.spS.spYearV(1), '%i', 'sp year 1', cS);
add_one('spYearLast', cS.spS.spYearV(end), '%i', 'sp year N', cS);
add_one('nSpNodes', cS.spS.nsp, '%i', 'No of sp nodes', cS);

add_one('nSim', cS.nSim, '%i', 'No of sim households', cS);


% *****  Aggregation
add_one('wageAgeRangeOne', cS.ageRangeV(1), '%i', 'wage age 1', cS);
add_one('wageAgeRangeLast', cS.ageRangeV(end), '%i', 'wage age N', cS);
add_one('schoolAgeRangeOne', cS.schoolAgeRangeV(1), '%i', 'for school aggregation', cS);
add_one('schoolAgeRangeLast', cS.schoolAgeRangeV(end), '%i', 'for school aggregation', cS);



%%  Potentially Calibrated parameters

add_one('grossInt', paramS.R, '%.2f', 'Gross interest rate', cS);

% No of calibrated params, but that includes skill price spline params
nCalParams = length(calS.solnV);
add_one('nCalParams', nCalParams, '%i', 'No of calibrated params', cS);
% No of calibrated skill price parameters
nSplineParams = cS.nSchool * cS.spS.nsp;
add_one('nSpParams', nSplineParams, '%i', 'No of spline params', cS);


% Range of alphas, to nearest 0.05
alphaV = round(paramS.alphaV .* 20) ./ 20;
add_one('alphaLow', min(alphaV), '%.1f', 'Min alpha', cS);
add_one('alphaHigh', max(alphaV), '%.1f', 'Max alpha', cS);

% Range of deltas, to nearest 0.005
ddhV = round(paramS.ddhV .* 1000) ./ 1000;
add_one('ddhLow',  100 .* min(ddhV), '%.1f', 'Min delta', cS);
add_one('ddhHigh',  100 .* max(ddhV), '%.1f', 'Max delta', cS);



results_so1.preamble_write(cS);

end



function add_one(nameStr, value, fmtStr, descrStr, cS)
   if isa(value, 'char')
      valueStr = value;
   elseif length(value) == 1
      valueStr = sprintf(fmtStr, value);
   else
      error('Not implemented');
   end
   results_so1.preamble_add(nameStr, valueStr, descrStr, cS);
end