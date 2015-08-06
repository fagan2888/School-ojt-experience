function [LS_sV, skillPriceV, cohS] = ...
   ss_solve_so1(skillWeightV, gSkillWeight, tgSFracV, hours_asM, abilV, h1V, paramS, cS)
% Solve for steady state
%{
Given skill bias params and their common growth rate

Steps:
   Iterate over skill prices 
      Solve for SS given skill prices
      Compute deviation from target skill weights

OUT:
   LS_sV
      aggregate labor inputs
   skillPriceV
      skill prices; up to a scale factor
   cohS
      output from sim_cohort

Change:
   faster optimization by setting options +++
Checked: +++
%}
% -----------------------------------------



%% Guess: log skill prices

% Construct labor supplies from h1 * hours
guessLS_sV = zeros([cS.nSchool, 1]);
for iSchool = 1 : cS.nSchool
   ageRangeV = cS.demogS.workStartAgeV(iSchool) : cS.demogS.ageRetire;
   guessLS_sV(iSchool) = 1.2 .* mean(h1V) .* sum(hours_asM(ageRangeV, iSchool));  
end

% Implied skill prices
mpV = ge_technology_so1(guessLS_sV, skillWeightV, paramS.rhoHS, paramS.rhoCG, cS);

logSpGuessV = log(mpV);


%% Optimization

% Optim options
optS = optimoptions(@fsolve,'Display','off','Jacobian','off');

[solnV, ~, exitFlag] = fsolve(@ss_solve_dev, logSpGuessV, optS);
if exitFlag <= 0
   error_so1('Failed to solve for SS');
end

% Recover skill prices
skillPriceV = exp(solnV);

% Recover other outputs
[~, LS_sV, cohS] = ss_solve_dev(solnV);


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
   %}
   function [devV, LS_sV, cohS] = ss_solve_dev(logSpV)
      % Labor supplies
      spV = exp(logSpV);
      [LS_sV, cohS] = ss_solve_givensp_so1(spV, gSkillWeight, tgSFracV, hours_asM, abilV, h1V, paramS, cS);
      % Implied skill prices
      spNewV = ge_technology_so1(LS_sV, skillWeightV, paramS.rhoHS, paramS.rhoCG, cS);
      devV = spNewV - spV;
   end


end