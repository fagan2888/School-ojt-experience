function t_ss_solve_givensp_so1(gNo, setNo)

cS = const_so1(gNo, setNo);
cS.dbg = 111;
paramS = param_set_so1(gNo, setNo);
paramS = param_derived_so1(1, paramS, cS);

spV = linspace(1, 2, cS.nSchool)';
gSp = 0.02;
tgSFracV = linspace(1, 2, cS.nSchool)';
tgSFracV = tgSFracV ./ sum(tgSFracV);

nInd = 1e2;
abilV = linspace(-1, 1, nInd)';
h1V   = linspace(1, 2, nInd)';

hours_asM = linspace(1, 2, cS.demogS.ageRetire)' * linspace(2, 3, cS.nSchool);


ss_solve_givensp_so1(spV, gSp, tgSFracV, hours_asM, abilV, h1V, paramS, cS)

end