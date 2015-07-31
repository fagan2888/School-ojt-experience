function sim_cohort_test(gNo, setNo)

fprintf('\nTest: sim cohort\n');

cS = const_so1(gNo, setNo);
cS.dbg = 111;
paramS = param_load_so1(gNo, setNo);

n = 1e2;
h1CohortV = 1 + rand([n,1]);
abilV = randn([n,1]);
% Skill price by phy age
T = cS.ageRetire;
skillPrice_asM = linspace(1,2,T)' * ones([1, cS.nSchool]);
sFracV = ones([cS.nSchool,1]);
tgSFracV = sFracV ./ sum(sFracV);
iCohort = 2;

prHsgABar = 0.2;
prCgABar = 0.3;
prefScaleEntryMean = 0.2;

for calSCost = [true, false]
   hh_so1.sim_cohort(h1CohortV, abilV, skillPrice_asM, tgSFracV,  ...
      calSCost, prHsgABar, prCgABar, prefScaleEntryMean, iCohort, paramS, cS);
end


end