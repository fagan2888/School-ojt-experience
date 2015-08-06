function [devV, outS] = cal_dev(guessV, argS, tgS, paramS, cS)
% Deviation function for calibration
%{
Cannot use rand in this function to do things at random (seed is reset)

IN:
   argS
      scalarDev
      saveSim
         save simulation results?
      showResults
   tgS
      calibration targets; from cal_targets

OUT:
   devV
      must be double for matlab optim routines incl fminsearch
   outS
      paramS
      sFracM(school, cohort)
         school fractions
      skillPrice_stM(year, school)
         first year is birth year of first cohort
      modelWageM(age, school, cohort)
         comparable with tgS.wageM

Checked: 

Status
%}

startTimeV = clock;
varS = param_so1.var_numbers;
nc = length(cS.demogS.bYearV);
showResults = argS.showResults  ||  (startTimeV(6) < 1);
% Must be set here b/c cS is only set once during entire calibration
if startTimeV(6) < 1
   cS.dbg = 111;
end

% These params are calibrated
doCalV = cS.calBase;


%%  Input check

if cS.dbg > 10
   if any(tgS.wageWt_ascM(:) < 0)
      error('Weights cannot be negative');
   end
   % Make sure wages are scaled
   if any(tgS.logWage_ascM(:) > 4)
      error('Wages must be scaled');
   end
end



%%  Solve and simulate

paramS = cS.pvector.guess_extract(guessV, paramS, doCalV);
paramS = param_derived_so1(false, paramS, cS);


% Make guesses into skill prices by [year, school]
outS.skillPrice_stM = calibr_so1.skill_price_comp(tgS, paramS, cS);



% Save the inputs (in case matlab quits at random)
if argS.saveInputs  ||  showResults
   saveS.guessV = guessV;
   saveS.argS = argS;
   saveS.tgS = tgS;
   saveS.paramS = paramS;
   var_save_so1(saveS, varS.vCalDevInputs, cS);
end


% Simulate histories
%  by [ind, age, cohort]
%  no need to save this; it's done in sim_histories when saveSim is set
simS = hh_so1.sim_histories(tgS.sFrac_scM, outS.skillPrice_stM, argS.saveSim, paramS, cS);


% Compute aggregate labor supply (by spYearV)
outS.lSupply_stM = calibr_so1.aggr_ls(simS.meanLPerHour_ascM,  tgS.aggrHours_astM, cS);


% Production function skill weights implied by labor supplies
%  Skill weights are computed for all spYearV years
[outS.skillWeightTop_tlM, outS.skillWeight_tlM, outS.neutralAV] = calibr_so1.skill_weights(outS.lSupply_stM, ...
   outS.skillPrice_stM, paramS.aggrProdFct, cS);




%% Deviations

outS.devVector = devVector_so1(20);

% Log wage profiles
[scalarMeanDev, devS.ssd_scM] = calibr_so1.dev_wage_profiles(simS.logWage_ascM, ...
   tgS.logWage_ascM, tgS.wageWt_ascM, cS);
outS.devVector = outS.devVector.add('wageProf', scalarMeanDev);

% *****  Iq deviations

% devS.scalarIqDev = 0;
% devS.scalarBetaIqDev = 0;
% devS.scalarBetaIqExperDev = 0;
% 

if cS.hasIQ == 1
   error('Not updated'); 
%    if cS.tgIq > 0
%       % Mean IQ percentile by [no college/collge, cohort]
%       modelV = simS.meanIqPctM(2,:) - simS.meanIqPctM(1,:);
%       dataV  = tgS.iqPctM(2,:) - tgS.iqPctM(1,:);
%       devIqPctV = modelV - dataV;
%       outS.scalarIqDev = 15 * sum(devIqPctV .^ 2);
%    end
%    
%    if cS.tgBetaIq > 0
%       % Beta IQ
%       % Use cohorts that match NLSY
%       outS.betaIq = mean(simS.betaIqV(cS.demogS.bYearV >= 1957  &  cS.demogS.bYearV <= 1965));
%       outS.devBetaIq = outS.betaIq - tgS.betaIQ;
%       outS.scalarBetaIqDev = 10 .* (outS.devBetaIq .^ 2);
%    end
% 
%    % ******  Beta IQ by experience
%    if cS.tgBetaIqExper > 0
%       betaV = iq_regr_so1(simS.wageM, simS.pSchoolM, simS.iqM, cS);
%       outS.betaIqExperV = betaV(tgS.iqExperV);
%       outS.scalarBetaIqExperDev = 10 .* sum((outS.betaIqExperV(:) - tgS.betaIqExperV(:)) .^ 2);
%    end
end



%%  Penalties for deviation from linear relative skill weights (const SBTC)

[scalarSkillWeightDev, skillPriceBeforeDev, skillPriceAfterDev] = ...
   calibr_so1.skill_price_dev(outS.skillPrice_stM, outS.skillWeightTop_tlM, outS.skillWeight_tlM,  cS.spSpecS, cS);

outS.devVector = outS.devVector.add('sbtc', scalarSkillWeightDev);
outS.devVector = outS.devVector.add('sp before', skillPriceBeforeDev);
outS.devVector = outS.devVector.add('sp after', skillPriceAfterDev);


% ****  Penalty for deviation from avg growth rate of skill bias in sample
% Or: deviation from assumed steady state skill weight (wage) growth rate
% HSG only to avoid double counting

% % update this +++++
% if (cS.gS.spOutOfSample == cS.gS.spOutOfSampleSbtc)  &&  0
%    % Indices of years with wage data
%    inSampleIdxV = find(yearV >= cS.wageYearV(1)  &  yearV <= cS.wageYearV(end));
%    iSchool = cS.schoolHSG;
%    yV = log(outS.skillWeight_stM(iSchool,:))';
%    % Avg growth rate in / out of sample
%    % Before wages start
%    T1 = inSampleIdxV(1) - 1;
%    g1 = (yV(T1) - yV(1)) ./ (T1-1);
% 
%    % Middle period with wages
%    T2 = inSampleIdxV(end) + 1;
%    if 1
%       % Steady state growth rate
%       g2 = cS.ssSkillPriceGrowth;
%    else
%       g2 = (yV(T2-1) - yV(T1+1)) ./ length(inSampleIdxV);
%    end
%    
%    % After wages end
%    g3 = (yV(end)  - yV(T2)) ./ (length(yV) - T2);
%    
%    outS.skillWeightTailDev = 4 .* (abs(g3-g2) + abs(g1-g2));
% elseif cS.gS.spOutOfSample == cS.gS.spOutOfSampleOnTrend
%    % Do nothing - it is automatic
%    outS.skillWeightTailDev = 0;
% else
%    error_so1('Invalid');
% end
% 

% devS.skillWeightTailDev = 0;


%%  Overall deviation

scalarDev = outS.devVector.scalar_dev;

if argS.scalarDev == 1
   devV = scalarDev;
else
   error('Not updated');
end





%%  Iteration results
% Show all at same time (in case parallel)
if showResults  ||  (startTimeV(6) < 2)
   disp(' ');
   disp([display_lh.time_str,  sprintf('        set %i / %i    Dev: %6.4f',  cS.gNo, cS.setNo, scalarDev) ]);
end
if showResults
   devStrV = outS.devVector.collect_nonzero;
   fprintf('Deviations:    ');
   display_lh.show_string_array(devStrV, 75, cS.dbg);

   if 1
      cohIdxV = round(linspace(1, cS.nCohorts, 8));
      disp('  SSD by [school, cohort]:');
      fprintf('    Coh');
      for ic = 1 : length(cohIdxV)
         fprintf('%10i', cohIdxV(ic));
      end
      fprintf('\n');
      % One line per school groups with cohorts as columns
      for iSchool = 1 : cS.nSchool
         fprintf('    %i  ', iSchool);
         fprintf('%10.2f', devS.ssd_scM(iSchool, cohIdxV));
         fprintf('\n');
      end
   end

   disp('  Parameters that are calibrated:');
   inV = cS.pvector.calibrated_values(paramS, doCalV);
   display_lh.show_string_array(inV, 75, cS.dbg);

   
   % Guesses that hit bounds
   cS.pvector.show_close_to_bounds(paramS, doCalV, 1);
end


if cS.dbg > 10
   if any(isnan(devV))  ||  any(isinf(devV))
      error('Invalid deviations');
   end
end

outS.devS = devS;



%%  Save iteration history
if argS.saveHistory == 1
   error('Not updated');
%    % Load history file
%    [loadS, success] = output_so1.var_load(cS.vOptimHistory, cS);
%    if success == 0
%       error('Cannot load history file');
%    end
%    
%    loadS.iter = loadS.iter + 1;
%    iter = loadS.iter;
%    
%    % Only save the first maxIter steps
%    if iter <= cS.histMaxIter
%       % Make structure to save
%       histS.guessV = guessV;
%       histS.dev    = scalarDev;
%       histS.paramS = paramS;
%    
%       loadS.resultV{iter} = histS;
%       output_so1.var_save(loadS, cS.vOptimHistory, cS);
%       
%       fprintf('Iter %i   Dev: %5.2f \n',  iter, scalarDev);
%    end
else
   %fprintf('Dev %5.2f \n', scalarDev);
end


%% Clean up

outS.paramS = paramS;



end



%% Local: add deviation
%{
Add a deviation to the deviation vector (a vector of devstruct)
If all targets are NaN: ignore (data not available)
   and return missVal deviation

Only targeted data moments are added to outS.devV

IN
   wtV
      relative weights of the different deviations
      sum to 1
   scaleFactor
      multiplied into modelV and dataV for taking scalar dev
   isTarget
      is this moment used as target in calibration?
   descrStr
      short descriptive label for iteration summary
   longDescrStr
      long description of target for fit tables
   fmtStr
      sprintf format string; for formatting  OR
      'dollar'
%}
function [scalarDev, devVect] = dev_add(devVectIn, tgV, modelV, wtV, scaleFactor, isTarget, ...
   descrStr, longDescrStr, fmtStr)

   validateattributes(tgV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real'})
   validateattributes(modelV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real'})
   
      
   % For display of dollar values
   if strcmp(fmtStr, 'dollar')
      dollarFactor = 1; % +++
      modelV = modelV .* dollarFactor;
      tgV = tgV .* dollarFactor;
      fmtStr = '%.2f';
   end
   
   % Make a deviation struct
   ds = devstruct(descrStr, descrStr, longDescrStr, modelV, tgV, wtV, scaleFactor, fmtStr);
   scalarDev = ds.scalar_dev;
      
   if isTarget == 1
      % Add to deviation vector
      devVect = devVectIn.devadd(ds);
   else
      devVect = devVectIn;
   end      
end
