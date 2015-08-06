function cohort_profiles(gNo)
% Save cohort wage profiles
%{
Wages are in data units

Median wage = [median earnings incl zeros] / [mean hours]

Cannot run on server

Checked: 2014-mar-20
%}
% --------------------------------------------

cS = const_data_so1(gNo);
varS = param_so1.var_numbers;


% Years with wage data
saveS.wageYearV = cS.wageYearV;
% Keep wage data for these ages
dataAgeV = cS.demogS.age1 : cS.demogS.ageRetire;
nBy = length(cS.demogS.bYearV);


% ***  Load data
% Wages NOT in model units
outS = output_so1.var_load(varS.vBYearSchoolAgeStats, cS);
if ~isequal(outS.ageV, dataAgeV)
   error_so1('Ages do not match', cS);
end


%% Stats: not smoothed
% Simply copy from outS. But indexing order is different.

% Size of outputs
% Save by physical age
sizeV = [cS.demogS.ageRetire, cS.nSchool, length(cS.demogS.bYearV)];


srcFieldV = {'wageMedian', 'earnMedian', 'nObs', 'mass', 'weeksMean'};
tgFieldV  = srcFieldV;
% scaleFactorV = [1 / cS.wageScale, 1 / cS.wageScale, 1, 1, 1];
scaleFactorV = ones(size(srcFieldV));
minValueV = [-100, -100, 0, 0, 0];

for iField = 1 : length(srcFieldV)
   srcField = [srcFieldV{iField}, '_csauM'];
   % Only uses persons with wages
   srcData_csaM = outS.(srcField)(:,:,:, cS.dataS.iuCpsEarn);
   tgData_ascM = repmat(cS.missVal, sizeV);
   
   for iBy = 1 : nBy
      for iSchool = 1 : cS.nSchool
         tgData_ascM(dataAgeV, iSchool, iBy) = srcData_csaM(iBy, iSchool, dataAgeV);
      end
   end
   
   % Scale the field and copy into output structure
   missingM = tgData_ascM < minValueV(iField);
   tgData_ascM = tgData_ascM ./ scaleFactorV(iField);
   tgData_ascM(missingM) = cS.missVal;

   tgField = [tgFieldV{iField}, '_ascM'];
   saveS.(tgField) = tgData_ascM;
   
   validateattributes(tgData_ascM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'size', sizeV})
end


% Median wage = [median earnings incl zeros] / [mean hours]
% saveS.wageMedian_ascM = saveS.earnMedian_ascM ./ max(1, saveS.weeksMean_ascM);
% saveS.wageMedian_ascM(saveS.earnMedian_ascM < 0  |  saveS.weeksMean_ascM < 0) = 0;


% %%  Smoothed profiles
% 
% saveS.meanLogWageSmoothM = repmat(cS.missVal, sizeV);
% saveS.stdLogWageSmoothM  = repmat(cS.missVal, sizeV);
% 
% % Mean / median (smoothed)
% saveS.meanMedianWageSmoothM = repmat(cS.missVal, sizeV);
% 
% % Wage percentiles, smoothed for each cohort to make a smooth age profile
% nPct = length(cS.wagePctV);
% % Find each percentile index in loaded data
% idxPctV = zeros([nPct, 1]);
% for iPct = 1 : nPct
%    idxPctV(iPct) = find(abs(outS.wagePctUbV - cS.wagePctV(iPct)) < 0.01);
% end
% if ~v_check(idxPctV, 'f', [nPct, 1], 1, 100)
%    error('Invalid idxPctV');
% end
% saveS.wagePctM = repmat(cS.missVal, [nPct, cS.demogS.ageRetire, cS.nSchool, cS.nCohorts]);
% 
% % Hp filter
% for iSchool = 1 : cS.nSchool
%    for iBy = 1 : nBy
%       % *****  Mean log wage
%       profileV = squeeze(saveS.meanLogWageM(:, iSchool, iBy));
%       nObsV    = squeeze(saveS.nObsM(:, iSchool, iBy));
%       idxV = find(nObsV >= cS.minWageObs  &  profileV > -10);
%       % Make sure ages are consecutive
%       if length(idxV) ~= idxV(end) - idxV(1) + 1
%          error('Ages have gaps');
%       end
%       
%       % HP filter
%       smoothV = hpfilter(profileV(idxV), cS.hpFilterParam); 
%       saveS.meanLogWageSmoothM(idxV, iSchool, iBy) = smoothV;
%       
%       
%       % *****  Std log wage
%       profileV = squeeze(saveS.stdLogWageM(:, iSchool, iBy));
%       nObsV    = squeeze(saveS.nObsM(:, iSchool, iBy));
%       idxV = find(nObsV >= cS.minWageObs  &  profileV > 0);
%       % Make sure ages are consecutive
%       if length(idxV) ~= idxV(end) - idxV(1) + 1
%          error('Ages have gaps');
%       end
%       
%       % HP filter
%       smoothV = hpfilter(profileV(idxV), cS.hpFilterStd);
%       saveS.stdLogWageSmoothM(idxV, iSchool, iBy) = smoothV;
%       
%       
%       % *****  Truncated mean / median (smoothed
%       meanV = outS.meanWageTruncM(iBy, iSchool, :);
%       meanV = meanV(:);
%       medianV = outS.medianWageM(iBy,  iSchool, :);
%       medianV = medianV(:);
%       idxV = find(meanV > 0  &  medianV > 0);
%       
%       saveS.meanMedianWageSmoothM(dataAgeV(idxV), iSchool, iBy) = ...
%          hpfilter(meanV(idxV) ./ medianV(idxV), cS.hpFilterParam);
%       
%       
%       
%       % *****  Wage distribution
%       for iPct = 1 : nPct
%          % outS. is indexed differently; by dataAgeV
%          profileV = repmat(cS.missVal, [cS.demogS.ageRetire, 1]);
%          profileV(dataAgeV) = squeeze(outS.wagePctM(idxPctV(iPct), iBy, iSchool, :));
%          % Observations should really be by percentile cell
%          nObsV = saveS.nObsM(:, iSchool, iBy);
%          % Compensate for not having obs by percentile by requiring more
%          % obs per age
%          idxV = find(nObsV >= 5 * cS.minWageObs  &  profileV(:) > 0);
% 
%          if length(idxV) > 5
%             % Make sure ages are consecutive
%             if length(idxV) ~= idxV(end) - idxV(1) + 1
%                idxV = idxV(idxV == idxV(1) - 1 + (1 : length(idxV))');
%             end
% 
%             % HP filter (same as mean log wages)
%             if length(idxV) > 5
%                smoothV = hpfilter(profileV(idxV), cS.hpFilterParam);
%                saveS.wagePctM(iPct, idxV, iSchool, iBy) = smoothV;
%             end
%          end
%       end
%    end
% end



% Save
output_so1.var_save(saveS, varS.vDataProfiles, cS);




end