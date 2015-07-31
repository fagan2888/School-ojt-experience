function flat_spot_model_so1(gNo, setNo)
% compute flat spot wages for model data
%{
OUT:
   flatWageM(school, year)
      flat spot log wages
      years relative to cS.wageYearV
   dWageV
      avg wage growth rate over available years
   yearM(school, 2)
      1st and last year available for each school group
      
Checked: 2014-apr-23
%}
% ------------------------------------------

cS = const_so1(gNo, setNo);
wageYearV = cS.wageYearV(1) : cS.wageYearV(end);
% ny = length(wageYearV);

% Load sim histories
simS = var_load_so1(cS.vSimResults, cS);
if cS.useMedianWage == 1
   logWage_ascM = simS.logMedianWage_ascM;
else
   logWage_ascM = simS.meanLogWageM;
end


% Reshape model wages by [age, school, cohort] into [age, school, year]
% Only keep years with data wages

[~, logWageM] = cohort_to_year_so1(logWage_ascM, cS.bYearV, wageYearV, cS);

% logWageM = cS.missVal .* ones([maxAge, cS.nSchool, ny]);
% 
% for iSchool = 1 : cS.nSchool
%    % Ages to keep
%    ageV = cS.flatAgeM(iSchool, 1) : maxAge;
%    for age = ageV
%       % Log model wage by cohort
%       mLogWageV = squeeze(simS.meanLogWageM(age, iSchool, :));
%       % Years for each cohort
%       yearV = year_from_age_so1(age, cS.bYearV, cS.ageInBirthYear);
%       % Indices into wageYearV
%       yrIdxV = yearV - wageYearV(1) + 1;
%       % Keep valid indices
%       idxV = find(yrIdxV >= 1  &  yrIdxV <= ny);
%       logWageM(age, iSchool, yrIdxV(idxV)) = mLogWageV(idxV);
%    end
% end

% Flat spot log wages
%  early years missing
   % potential problem: data wages do not use 3 year birth cohorts +++
flatWageM = flat_spot_so(logWageM, ones(size(logWageM)), cS.flatAgeM, cS.missVal);

% Wage changes
yearM = zeros([cS.nSchool, 2]);
dWageV = zeros([cS.nSchool, 1]);
for iSchool = 1 : cS.nSchool
   idxV = find(flatWageM(iSchool, :) ~= cS.missVal);
   % Index 1 = wageYearV(1)
   yearM(iSchool, :) = [idxV(1), idxV(end)] + (wageYearV(1) - 1);

   dWageV(iSchool) = (flatWageM(iSchool, idxV(end)) - flatWageM(iSchool, idxV(1))) ./ ...
      (yearM(iSchool,2) - yearM(iSchool,1));
end




%% Save
saveS.flatWageM = flatWageM;
saveS.yearM = yearM;
saveS.dWageV = dWageV;
var_save_so1(saveS, cS.vFlatSpotModel, cS, gNo, setNo);


%% Self test
if cS.dbg > 10
   if ~v_check(saveS.flatWageM, 'f', [cS.nSchool, length(wageYearV)], -10, 10, cS.missVal)
      error_so1('Invalid');
   end
end




end