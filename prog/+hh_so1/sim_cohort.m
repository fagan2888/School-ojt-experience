function [outS, ojtS, schoolS] = sim_cohort(h1CohortV, abilV, skillPrice_asM, tgSFracV,  ...
   calSCost, prHsgABar, prCgABar, prefScaleEntryMean, iCohort, paramS, cS)
% Solve + simulate one cohort
%{
Two cases
   calSCost is false
      take school costs as given and just solve
   calSCost is true
      find school costs to match tgSFracV

IN
   skillPrice_asM(age, school)
   h1CohortV
      at cS.demogS.age1
      random endowments
   prHsgABar, prCgABar, prefScaleEntryMean
      guesses for parameters that govern school choice
      or actual values if these are not calibrated
   tgSFracV(school)
      tg school fractions
   calSCost
      calibrate school costs or use the guess (for counterfactuals)?

OUT:
   ojtS: solution to OJT part

   schoolS: solution to school part

   outS:  aggregates      
      Simulated life histories for each person, for each school group
         hM(ind,age,school), sTimeM, wageM
      pvLtyAge1M(ind, school)
         pv lifetime earnings, discounted to age 1

Checked: 

Change:
   efficiency: compute log only once (perhaps trivial) +++
   efficiency: do not compute mean log / std log wage unless needed +++
%}


%%  Input check

if cS.dbg > 10
   if ~isequal(size(skillPrice_asM), [cS.demogS.ageRetire, cS.nSchool])
      error_so1('skill prices should be by model age', cS);
   end
   check_lh.prob_check(tgSFracV, 1e-5);
   if calSCost ~= false  &&  calSCost ~= true
      error_so1('calSCost must be Bool', cS);
   end
end


%% ****  OJT
% Compute pvLty for each school choice, discounted to age 1

ojtS = hh_so1.ojt_solve(h1CohortV, abilV, skillPrice_asM, iCohort, paramS, cS);


   
%%  School choice

if calSCost
   % Calibrate school costs
   [pSchool_isM, schoolS.sFracV, schoolS.prHsgABar, schoolS.prCgABar, schoolS.prefScaleEntryMean] = ...
      hh_so1.school_prob_cal(tgSFracV, abilV, log(ojtS.pvLtyAge1_isM), iCohort, paramS, cS);
else
   % Just return the parameters given as guesses
   schoolS.prHsgABar = prHsgABar;
   schoolS.prCgABar = prCgABar;
   schoolS.prefScaleEntryMean = prefScaleEntryMean;
end   
   

% *******  Individual school probs

% Prob that each type graduates HS and college
schoolS.prGradHsV  = hh_so1.prob_hsg(abilV, paramS.prHsgMult, schoolS.prHsgABar, cS);
schoolS.prGradCollV = hh_so1.prob_cg(abilV, paramS.prCgMult,  schoolS.prCgABar,  cS);

schoolS.pSchool_isM = hh_so1.school_probs(log(ojtS.pvLtyAge1_isM), schoolS.prGradHsV, schoolS.prGradCollV, ...
   schoolS.prefScaleEntryMean, paramS.prefScaleCohortV(iCohort), cS);


% ******  Self test
if (cS.dbg > 10)  &&  calSCost
   if ~check_lh.approx_equal(pSchool_isM, schoolS.pSchool_isM, 1e-4, 1e3)
      error_so1('Did not recover school probs', cS);
   end
   check_lh.prob_check(schoolS.pSchool_isM', 1e-5);
   check_lh.prob_check(schoolS.prGradHsV, []);
   check_lh.prob_check(schoolS.prGradCollV, []);

%    % Check that school fractions are correct
%    sFrac2V = mean(pSchool_isM);
%    if max(abs(sFrac2V(:) - tgSFracV(:))) > 1e-3
%       error_so1('Wrong school fraction comp', cS);
%    end
end


%%  Cohort stats

ageRetire = cS.demogS.ageRetire;
% outS.meanLogWageM = cS.missVal .* ones([ageRetire, cS.nSchool]);
% outS.stdLogWageM  = cS.missVal .* ones([ageRetire, cS.nSchool]);
% This is log median or mean log, depending settings
outS.logWage_asM = cS.missVal .* ones([ageRetire, cS.nSchool]);
outS.meanLPerHour_asM  = cS.missVal .* ones([ageRetire, cS.nSchool]); 

for iSchool = 1 : cS.nSchool
   workAgeV = cS.demogS.workStartAgeV(iSchool) : cS.demogS.ageRetire;
   % Mass of persons in this school group
   massV = schoolS.pSchool_isM(:,iSchool);
   massV = massV ./ sum(massV);

   for age = workAgeV
      if cS.useMedianWage
         outS.logWage_asM(age,iSchool) = ...
            log(distrib_lh.weighted_median(ojtS.wage_itsM(:, age,iSchool), massV, cS.dbg));
      else
         error('Not implemented');
      end
      
      % Mean efficiency
      tEndow = max(1e-4, paramS.tEndow_ascM(age,iSchool,iCohort));
      lPerHourV = ojtS.h_itsM(:,age,iSchool).* (tEndow - ojtS.sTime_itsM(:,age,iSchool)) ./ tEndow;
      outS.meanLPerHour_asM(age,iSchool) = sum(massV .* lPerHourV);
   end
end


% *****   Self-test
if cS.dbg > 10
   validateattributes(outS.logWage_asM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', [ageRetire, cS.nSchool]});
   validateattributes(outS.meanLPerHour_asM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', [ageRetire, cS.nSchool]});
end
   
   
end