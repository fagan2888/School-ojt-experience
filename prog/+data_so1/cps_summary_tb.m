function cps_summary_tb(gNo)
% Table with summary stats for cps data
% ---------------------------------------

cS = const_data_so1(gNo);
varS = param_so1.var_numbers;
dirS = param_so1.directories(gNo, cS.setNo);

% Years to show
yearV = 1965 : 5 : 2005;
ny = length(yearV);

% Age range to report
ageRangeV = 30 : 60;

% Load summary data
outS = output_so1.var_load(varS.vAgeSchoolYearStats, cS);


%% *****  Table layout

% Rows are years
nr = 1 + ny;

% Columns
nc = 1;
nc = nc + 1;   cNobs = nc;
% no of obs in each [by, school, age] cell
%  in age range used to compute wages
nc = nc + 1;   cNobsCell = nc;
nc = nc + 1;   cNobsMinMax = nc;

tbM = cell([nr, nc]);
tbS.rowUnderlineV = zeros([nr, 1]);
tbS.rowUnderlineV(1) = 1;

% Header row
ir = 1;
tbM{ir, 1} = 'Year';
tbM{ir, cNobs} = '$N$';
tbM{ir, cNobsCell} = 'Avg $N$ per cell';
tbM{ir, cNobsMinMax} = '$N$ range';


%% ******  Table body

for iy = 1 : ny
   ir = 1 + iy;
   tbM{ir, 1} = sprintf('%i', yearV(iy));
   
   nObsV = outS.nObs_astuM(ageRangeV, :, outS.yearV == yearV(iy), cS.dataS.iuCpsEarn);
   nObsV = nObsV(nObsV(:) > 0);
   if sum(nObsV) < 1e3      error_so1('Too few obs in a year');
   end
   
   tbM{ir, cNobs} = sprintf('%i', sum(nObsV));
   
   % No of obs
   tbM{ir, cNobsCell} = sprintf('%i', round(mean(nObsV)));
   tbM{ir, cNobsMinMax} = sprintf('%i - %i', min(nObsV), max(nObsV));
   
end


%% ******  Write table

tbS.noteV = {'Notes: $N$ is the number of observations. ', ...
   'Avg $N$ per cell refers to the average number of observations in each (age, school) cell. ', ...
   '$N$ range shows the minimum and maximum number of observations in each cell. ', ...
   sprintf('Cells cover age range %i-%i.', ageRangeV(1), ageRangeV(end))};

fid = fopen([dirS.tbDir, 'cps_tb.tex'], 'w');
latex_lh.latex_texttb_lh(fid, tbM, 'Caption', 'Label', tbS);
fclose(fid);
disp('Saved table  cps_tb.tex');




end