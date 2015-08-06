function skill_price_dev_test(gNo, setNo)

disp('Testing skill_price_dev');

cS = const_so1(gNo, setNo);
nsp = cS.spS.spYearV(end) - cS.spS.spYearV(1) + 1;

rng(99);
skillPrice_stM = 1 + rand(cS.nSchool, nsp);
skillWeightTop_tlM = 1 + rand(nsp, 2);
skillWeight_tlM = 1 + rand(nsp, cS.nSchool);

calibr_so1.skill_price_dev(skillPrice_stM, skillWeightTop_tlM, skillWeight_tlM,  cS.spSpecS, cS);

end