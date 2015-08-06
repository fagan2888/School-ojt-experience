function t_ss_solve_given_wages_so1(gNo, setNo)

fprintf('\nTest: solve ss given wages\n');

cS = const_so1(gNo, setNo);
cS.dbg = 111;
paramS = param_set_so1(gNo, setNo);
paramS = param_derived_so1(1, paramS, cS);

gWage = 0.02;
tgSFracV = linspace(1, 2, cS.nSchool)';
tgSFracV = tgSFracV ./ sum(tgSFracV);

nInd = 1e2;
abilV = linspace(-1, 1, nInd)';
h1V   = linspace(1, 2, nInd)';

hours_asM = linspace(1, 2, cS.demogS.ageRetire)' * linspace(2, 3, cS.nSchool);

logWage_asM = linspace(0, 1, cS.demogS.ageRetire)' * linspace(1, 2, cS.nSchool);
wt_asM = linspace(10, 20, cS.demogS.ageRetire)' * linspace(2, 1, cS.nSchool);

tic
[LS_sV, skillPriceV, cohS] = ...
   ss_solve_given_wages_so1([], logWage_asM, wt_asM, gWage, tgSFracV, hours_asM, abilV, h1V, paramS, cS);
toc

%keyboard;

end