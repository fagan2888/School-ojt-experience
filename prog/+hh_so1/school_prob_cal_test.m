function school_prob_cal_test(gNo, setNo)

fprintf('Testing school_prob_cal \n');

rng(101);
cS = const_so1(gNo, setNo);
paramS = param_load_so1(gNo, setNo);

tgSFracV = linspace(1, 1.5, cS.nSchool);
tgSFracV = tgSFracV(:) ./ sum(tgSFracV);

nTypes = 50;
abilV = randn([nTypes, 1]);
valueWork_isM = 1 + rand([nTypes, cS.nSchool]);
iCohort = 2;

hh_so1.school_prob_cal(tgSFracV, abilV, valueWork_isM, iCohort, paramS, cS);



end