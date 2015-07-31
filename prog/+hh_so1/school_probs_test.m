function school_probs_test(gNo, setNo)

fprintf('Testing school_probs \n');

cS = const_so1(gNo, setNo);
cS.dbg = 111;

nTypes = 4;
valueWork_isM = rand([nTypes, cS.nSchool]);
prGradHsV = linspace(0.1, 0.9, nTypes);
prGradCollV = linspace(0.2, 0.8, nTypes);

prefHs = 0.1;

prefScaleEntry = 0.2;

prob_isM = hh_so1.school_probs(valueWork_isM, prGradHsV, prGradCollV, prefHs, prefScaleEntry, cS);




end