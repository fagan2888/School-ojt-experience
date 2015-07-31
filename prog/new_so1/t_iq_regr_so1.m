function t_iq_regr_so1(gNo, setNo)

cS = const_so1(gNo, setNo);

simS = var_load_so1(cS.vSimResults, cS);


coeffV = iq_regr_so1(simS.wageM, simS.pSchoolM, simS.iqM, cS)


end