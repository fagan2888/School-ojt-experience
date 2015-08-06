function outS = sim_histories(tgSFrac_scM, skillPrice_stM, saveSim, paramS, cS)
% Simulate household histories
%{
Also solves school choice and OJT problems

IN:
   tgSFrac_scM
      fraction in each school group by [s, cohort]
      school costs params adjust to get those exactly right
   skillPrice_stM(school, year)
      year 1 is cS.spS.spYearV(1)
   saveSim 
      save sim histories

OUT:
   outS
      aggregates needed for calibration and smaller stuff
   simS (saved)
      contains all the fields of outS   AND
      individual histories (can be saved)


Checked: 
%}

nSim = cS.nSim;
nc = length(cS.demogS.bYearV);
nSchool = cS.nSchool;
% Calibrate school costs
calSCost = true;



%%  Input check
if cS.dbg > 10
   nsp = cS.spS.spYearV(end) - cS.spS.spYearV(1) + 1;
   validateattributes(skillPrice_stM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
      'size', [cS.nSchool, nsp]})
   check_lh.prob_check(tgSFrac_scM, 1e-5);
end


%%  Draw h1, a, iq

[simS.abil_icM, h1M, simS.iq_icM, iqPctM] = hh_so1.endow_draw(paramS, cS);




%%  Loop over cohorts

% h1 endowments (mean may differ by cohort)
simS.h1_icM = zeros([nSim, nc]);
% Histories are saved for each person / school choice
sizeV = [nSim, cS.demogS.ageRetire, cS.nSchool, nc];
simS.h_itscM     = zeros(sizeV);
simS.sTime_itscM = zeros(sizeV);
simS.wage_itscM  = cS.missVal .* ones(sizeV);
% Skill prices for each cohort
simS.skillPrice_ascM = zeros([cS.demogS.ageRetire, cS.nSchool, nc]);
% Present value of lifetime earnings, discounted to age 1
simS.pvLtyAge1_iscM = zeros([nSim, cS.nSchool, nc]);
% Individual school probs
simS.pSchool_iscM = zeros([nSim, cS.nSchool, nc]);

% outS.meanLogWageM = cS.missVal .* ones([cS.demogS.ageRetire, cS.nSchool, nc]);
% outS.stdLogWageM  = cS.missVal .* ones([cS.demogS.ageRetire, cS.nSchool, nc]);
outS.logWage_ascM = repmat(cS.missVal, [cS.demogS.ageRetire, cS.nSchool, nc]);
% Mean labor supply per hour worked. For computing aggregate labor inputs
outS.meanLPerHour_ascM = repmat(cS.missVal, [cS.demogS.ageRetire, cS.nSchool, nc]);
% School fractions
outS.sFrac_scM = zeros([cS.nSchool, nc]);

if cS.hasIQ == 1
   % Mean IQ pct score [college / no college, cohort]
   outS.meanIqPctM = zeros([2, nc]);
   % Regress log wage on std normal afqt
   outS.betaIqV = repmat(cS.missVal, [nc, 1]);
   iqAge = cS.iqAge;
end


for ic = 1 : nc
   % Adjust mean for this cohort
   h1Factor = exp(paramS.meanLogH1V(ic));
   % Ind endowments at age 1
   h1CohortV = h1M(:,ic) .* h1Factor;

   % First year the cohort is cS.demogS.age1, cS.demogS.ageRetire
   yrIdxV = helper_so1.year_from_age([cS.demogS.age1, cS.demogS.ageRetire], cS.demogS.bYearV(ic), cS.ageInBirthYear) - cS.spS.spYearV(1) + 1;
   simS.skillPrice_ascM(cS.demogS.age1 : cS.demogS.ageRetire, :, ic) = skillPrice_stM(:, yrIdxV(1) : yrIdxV(2))';

   % Simulate cohort
   % Should have better guesses from past iterations
   prHsgABar = 0;
   prCgABar = 0;
   prefScaleEntryMean = 0;
   [cohS, ojtS, schoolS] = hh_so1.sim_cohort(h1CohortV, simS.abil_icM(:,ic), simS.skillPrice_ascM(:, :, ic),   ...
      tgSFrac_scM(:,ic),  calSCost, prHsgABar, prCgABar, prefScaleEntryMean, ic, paramS, cS);
%    cohS = sim_cohort_so1(h1CohortV, simS.abil_icM(:,ic), skillPrice_stM(:,yrIdxV(1) : yrIdxV(2))', tgSFrac_scM(:,ic), ...
%       sCostGuessM(:,ic), ic, calSCost, paramS, cS);
         
   simS.h1_icM(:, ic) = h1CohortV;
   simS.h_itscM(:,:,:,ic) = ojtS.h_itsM;
   simS.sTime_itscM(:,:,:,ic) = ojtS.sTime_itsM;
   simS.wage_itscM(:,:,:,ic) = ojtS.wage_itsM;
   outS.meanLPerHour_ascM(:,:,ic) = cohS.meanLPerHour_asM;
%    outS.meanLogWageM(:,:,ic) = cohS.meanLogWageM;
%    outS.stdLogWageM(:,:,ic)  = cohS.stdLogWageM;
   outS.logWage_ascM(:,:,ic) = cohS.logWage_asM;
   simS.pSchool_iscM(:,:,ic) = schoolS.pSchool_isM;
   simS.pvLtyAge1_iscM(:,:,ic)  = ojtS.pvLtyAge1_isM;
   outS.sFrac_scM(:, ic) = schoolS.sFracV;


   if cS.hasIQ == 1
      error('Not updated');
      if cS.tgIq > 0
         % Mean IQ percentile [college / no college]
         % Prob of choosing college
         pCollegeV = simS.pSchool_iscM(:,cS.schoolCD, ic) + simS.pSchool_iscM(:, cS.schoolCG, ic);
         % Each person is weighted with prob of attending college
         outS.meanIqPctM(:,ic) = [sum(iqPctM(:,ic) .* pCollegeV) ./ sum(pCollegeV),  ...
            sum(iqPctM(:,ic) .* (1-pCollegeV)) ./ sum(1 - pCollegeV)];
      end
      
      % Regress mean log wage on std normal iq and school dummies
      % Use a subset of observations
      if cS.tgBetaIq > 0
         outS.betaIqV(ic) = iq_regr_fixed_age_so1(cohS.wageM, cohS.pSchoolM, simS.iq_icM(:,ic), iqAge, cS);
      end
   end
end


% Save simulated histories (when calibration is done)
if saveSim == 1
   varS = param_so1.var_numbers;
   % Also copy everything from outS, so we have it in one place
   simS = struct_lh.merge(simS, outS, cS.dbg);
   output_so1.var_save(simS, varS.vSimResults, cS);
end


%% Self test
if cS.dbg > 10
   validateattributes(outS.logWage_ascM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', [cS.demogS.ageRetire, cS.nSchool, cS.nCohorts]})
   
   if cS.tgIq > 0
      if ~v_check(outS.meanIqPctM, 'f', [2, cS.nCohorts], 0, 1, [])
         error_so1('Invalid');
      end
   end
   
   % Check mean log h1 by cohort
   meanLogH1V = zeros([cS.nCohorts, 1]);
   for iCohort = 1 : cS.nCohorts
      % Mean log h1
      meanLogH1V(iCohort) = mean(log(simS.h1_icM(:,iCohort)));
   end
   h1DevV = meanLogH1V - paramS.meanLogH1V(:);
   if max(abs(h1DevV)) > 1e-3   
      error_so1('Mean log h1 wrong', cS);
   end
   
   % Mean abilities
   abilMeanV = mean(simS.abil_icM);
   if max(abs(abilMeanV)) > 1e-3
      error_so1('Mean ability wrong', cS);
   end

end


end