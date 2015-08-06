function [LS_sV, cohS] = ss_solve_givensp_so1(spV, gSp, tgSFracV, hours_asM, abilV, h1V, paramS, cS)
% Solve steady state given skill prices
%{
Steps:
   Solve hh problem for representative cohort

IN:
   spV(s)
      skill prices
      levels don't matter for labor supplies
   gSp
      growth rate of skill prices
      constant; same for all s
   tgSFracV
      school fractions (to be matched by setting school costs)
   hours_asM
      hours worked by (phys age, school)
   abilV, h1V
      endowments of agents to be simulated

OUT:
   LS_sV
      aggregate labor supplies
   cohS
      output of sim_cohort

Checked: 2014-apr-8
%}
% ---------------------------------------

%% Input check

nInd = length(abilV);

if cS.dbg > 10
   for iSchool = 1 : cS.nSchool
      if ~v_check(hours_asM(cS.demogS.workStartAgeV(iSchool) : cS.demogS.ageRetire, iSchool), 'f', [], 1e-3, 1e3, [])
         error_so1('Invalid');
      end
   end
   if ~v_check(h1V, 'f', [nInd, 1], 1e-2, 1e2, [])
      error_so1('Invalid');
   end
end


%% Hh problem
% The skill price levels do not matter. Only relative levels and growth rates

% Skill prices by MODEL age, school
T = cS.demogS.ageRetire - cS.demogS.age1 + 1;
grFactorV = (1 + gSp) .^ (0 : (T-1))';
skillPriceM = grFactorV * spV(:)';

sCostGuessV = zeros([cS.nSchool, 1]);
calSCost = 1;
% Parameters that vary by cohort are fixed at first cohort
%  e.g. psy cost scale
iCohort = 1;

cohS = sim_cohort_so1(h1V, abilV, skillPriceM, tgSFracV, sCostGuessV,  ...
   iCohort, calSCost, paramS, cS);


%% Aggr labor supply by schooling
% Age profiles of labor supplies aggregate into total

LS_sV = zeros([cS.nSchool, 1]);

for iSchool = 1 : cS.nSchool
   ageRangeV = cS.demogS.workStartAgeV(iSchool) : cS.demogS.ageRetire;
   
   % Labor efficiency by [age, school]
   effV = cohS.meanLPerHour_asM(ageRangeV,iSchool);
   if cS.dbg > 10
      if ~v_check(effV, 'f', [length(ageRangeV), 1], 1e-2, 1e2, [])
         error_so1('Invalid eff');
      end
   end

   % Labor supplies
   LS_sV(iSchool) = sum(effV .* hours_asM(ageRangeV, iSchool));       
end


% Skill weights implied by aggregate labor supplies
% outS.skillWeight_sV = ge_weights_so1(outS.LS_sV, spV, paramS.rhoHS, paramS.rhoCG, cS);



%% Output check
if cS.dbg > 10
   if ~v_check(LS_sV, 'f', [cS.nSchool, 1], 1e-3, 1e4, [])
      error_so1('Invalid');
   end
end


end