function ojt_solve_test(gNo, setNo)

fprintf('Testing ojt_solve \n');

cS = const_so1(gNo, setNo);
paramS = param_load_so1(gNo, setNo);

n = 20;
h1V = 1 + rand([n,1]);
abilV = randn([n, 1]);

skillPrice_asM = linspace(1, 2, cS.demogS.ageRetire)'  *  linspace(1, 2, cS.nSchool);
iCohort = 2;

outS = hh_so1.ojt_solve(h1V, abilV, skillPrice_asM, iCohort, paramS, cS);


end