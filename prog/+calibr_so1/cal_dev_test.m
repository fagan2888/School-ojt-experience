function cal_dev_test(gNo, setNo)

cS = const_so1(gNo, setNo);
cS.dbg = 111;
paramS = param_load_so1(gNo, setNo);

cdS = const_data_so1(gNo);
varS = param_so1.var_numbers;
tgS = var_load_so1(varS.vCalTargets, cdS);

guessV = cS.pvector.guess_make(paramS, cS.calBase);

argS.scalarDev = true;
argS.saveInputs = false;
argS.showResults = true;
argS.saveSim = false;
argS.saveHistory = false;

calibr_so1.cal_dev(guessV, argS, tgS, paramS, cS);

end