function school_tech_test(gNo, setNo)

fprintf('Syntax test: school tech\n');

cS = const_so1(gNo, setNo);
paramS = param_load_so1(gNo, setNo);

iCohort = 2;
iSchool = 2;

n = 1e2;
h1V = 1 + rand([n,1]);
abilV = randn([n,1]);

hWorkStartV = hh_so1.school_tech(h1V, abilV, iSchool, iCohort, paramS, cS);


end