function flat_spot_cps_so1(saveFigures, gNo, setNo)
% Compute skill price series using the flat spot method
% using cps wage data
%{
Follow Bowlus and Robinson (2010) as closely as possible
They set wages in 1974 and 1975 to 1

Cannot run on server

OUT
   flatAgeM(school, 2)
      start ages of flat spots used, range
   yearV
      years in wage matrix
   logWageM(school, year)
      flat spot log wages

Checked: 2012-aug-20
%}
% ----------------------------------------------------

cS = const_so1(gNo, setNo);
if ~cS.isDataSetNo
   error_so1('Only for data set no', cS);
end

% Age range for flat spots
%  Use this age in t and the next higher in t+1
%  by [school, age range]
saveS.flatAgeM = cS.flatAgeM;


% Load wage data
outS = var_load_so1(cS.vAgeSchoolYearStats, cS);

% Years for which wage levels can be computed
saveS.yearV = max(outS.yearV(1), cS.wageYearV(1)) : min(cS.wageYearV(end), outS.yearV(end));
ny = length(saveS.yearV);

% Indices into years with wage data
yrIdxV = (saveS.yearV(1) - outS.yearV(1)) + (1 : ny);

if cS.useMedianWage == 1
   wageM = log_lh(outS.medianWageM(:,:,yrIdxV), cS.missVal);
else
   % Mean log wage, by [age, school, year]
   wageM = outS.meanLogWageTruncM(:,:,yrIdxV);
end
sizeV = size(wageM);
if ~v_check(wageM, 'f', [sizeV(1), cS.nSchool, length(yrIdxV)], -10, 10, cS.missVal)
   error_so1('Invalid');
end

saveS.logWageM = flat_spot_so(wageM, outS.massM(:,:,yrIdxV), saveS.flatAgeM, cS.missVal);


for iSchool = 1 : cS.nSchool
   % Normalize 1974 and 1975 to 0
   idxV = find(saveS.logWageM(iSchool, :) ~= cS.missVal);
   yrIdx = find(saveS.yearV == 1974);
   idx2V = idxV(1) : yrIdx;
   saveS.logWageM(iSchool, idx2V) = saveS.logWageM(iSchool, idx2V) - saveS.logWageM(iSchool, yrIdx);
   idx2V = (yrIdx + 1) : idxV(end);
   saveS.logWageM(iSchool, idx2V) = saveS.logWageM(iSchool, idx2V) - saveS.logWageM(iSchool, yrIdx + 1);
end



% ***** Save

var_save_so1(saveS, cS.vFlatSpotWages, cS);


%% **********  Plot as Bowlus/Robinson (2010) 
% figure 3
if saveFigures >= 0
   fig_new_so(saveFigures);
   
   hold on;
   for iSchool = 1 : cS.nSchool
      idxV = find(saveS.logWageM(iSchool, :) ~= cS.missVal);
      plot(saveS.yearV(idxV),  saveS.logWageM(iSchool, idxV), ...
         cS.lineStyleDenseV{iSchool}, 'color', cS.colorM(iSchool, :));
   end
   
   hold off;
   xlabel('Year');
   ylabel('Log wage');
   legend(cS.schoolLabelV, 'location', 'northeast');
   
   figure_format_so1(gca);
   save_fig_so1('flat_spot_wages', saveFigures, cS.figOpt4S, cS);
end


end