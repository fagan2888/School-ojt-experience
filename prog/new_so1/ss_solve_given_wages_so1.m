function [LS_sV, skillPriceV, cohS, meanSquaredDev] = ...
   ss_solve_given_wages_so1(logSpGuessV, logWage_asM, wt_asM, gWage, tgSFracV, hours_asM, abilV, h1V, paramS, cS)
% Solve for steady state
%{
Given target age wage profiles for the representative cohort and the common wage growth rate

Steps:
   Iterate over skill prices 
      Solve for SS given skill prices
      Compute deviation from target age wage profiles

IN:
   logSpGuessV(school)
      guess for log school prices, may be []
   logWage_asM(age, school)
      target cross-sectional age wage profiles (log)
   wt_asM
      weights for deviations (sqrt of no of obs)

OUT:
   LS_sV
      aggregate labor inputs
   skillPriceV
      skill prices; up to a scale factor
   cohS
      output from sim_cohort

Change:
   faster optimization by setting options +++
   improve guesses +++
Checked: +++
%}
% -----------------------------------------



%% Input check
if cS.dbg > 10
   if ~v_check(wt_asM, 'f', [cS.demogS.ageRetire, cS.nSchool], 0, [], [])
      error_so1('Invalid');
   end
end



%% Guess: log skill prices
%{ 
Based on 
   log wage = log skill price + log efficiency
%}
if isempty(logSpGuessV)
   % improve +++
   ageV = 25 : 60;
   logSpGuessV = mean(logWage_asM(ageV,:));
   logSpGuessV = logSpGuessV(:);

   % Adjust for a rough guess of mean efficiency per hour
   iCohort = round(cS.nCohorts / 2);
   for iSchool = 1 : cS.nSchool
      hWorkStartV = school_tech_so1(h1V, abilV, iSchool, iCohort, paramS, cS);
      logSpGuessV(iSchool) = logSpGuessV(iSchool) - mean(log(hWorkStartV) + log(1.3));
   end
end


%% Optimization

% Optim options
optS = optimoptions(@fminunc,'Display','notify','algorithm', 'quasi-newton', 'TolFun', 1e-6, 'TolX', 1e-6);

% Scale weights so that deviation is of a scale the solver can use
wt_asM = wt_asM ./ sum(wt_asM(:));

% Add a constant to guesses. Otherwise they can be close to 0 and the algorithm gets confused
% about step sizes
[solnV, meanSquaredDev, exitFlag, fsOutS] = fminunc(@ss_solve_dev, logSpGuessV + 2, optS);
if exitFlag <= 0
   error_so1('Failed to solve for SS');
end
fprintf('Solving steady state. No of f evals: %i \n',  fsOutS.funcCount);

% Recover other outputs
[~, skillPriceV, LS_sV, cohS, modelWage_asM] = ss_solve_dev(solnV);


%% Show fit
if 0
   fig_new_so(0);
   for iSchool = 1 : cS.nSchool
      subplot(2,2,iSchool);
      % Ages for which to compare
      ageV = max(cS.demogS.workStartAgeV(iSchool), cS.ageRangeV(1)) : cS.ageRangeV(2);
      plot(ageV, logWage_asM(ageV,iSchool), '-',  ageV, modelWage_asM(ageV,iSchool), '--');
   end
   keyboard;
   close;
end


%% Self test
if cS.dbg > 10
   if ~v_check(LS_sV, 'f', [cS.nSchool, 1], 1e-3, 1e3, [])
      error_so1('Invalid LS');
   end
   if ~v_check(skillPriceV, 'f', [cS.nSchool, 1], 1e-3, 1e3, [])
      error_so1('Invalid skill prices');
   end
end



%% Nested

   % Deviation from skill price guesses
   %{
      IN: 
         logSpV(s) - log skill prices
      OUT:
         devV
            mean squared deviation (weighted; weights sum to 1)
            model log wage - data log wage profile
   %}
   function [devV, spV, LS_sV, cohS, modelWage_asM] = ss_solve_dev(guess2V)
      % Labor supplies, given skill prices
%       spV = guess_extract_lh(guess2V, optS.lbV, optS.ubV, optS);
      spV = exp(guess2V - 2);
      [LS_sV, cohS] = ss_solve_givensp_so1(spV, gWage, tgSFracV, hours_asM, abilV, h1V, paramS, cS);
      
      % Deviations from tg age wage profiles
      devV = zeros([cS.nSchool, 1]);
      modelWage_asM = zeros([cS.demogS.ageRetire, cS.nSchool]);
      for iSchool2 = 1 : cS.nSchool
         % Ages for which to compare
         age2V = max(cS.demogS.workStartAgeV(iSchool2), cS.ageRangeV(1)) : cS.ageRangeV(2);
         % Implied age wage profiles of representative cohort
         if cS.useMedianWage == 1
            modelV = cohS.logMedianWage_asM(age2V, iSchool2);
         else
            modelV = cohS.meanLogWageM(age2V, iSchool2);
         end
         modelWage_asM(age2V, iSchool2) = modelV;
         devV(iSchool2) = sum((logWage_asM(age2V,iSchool2) - modelV) .^ 2  .*  wt_asM(age2V,iSchool2));
      end
      
      % Return scalar dev
      devV = sum(devV);
   end


end