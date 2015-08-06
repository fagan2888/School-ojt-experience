function skill_price_comp_test(gNo, setNo)

disp('Testing skill_price_comp');

cS = const_so1(gNo, setNo);
paramS = param_load_so1(gNo, setNo);
cS.dbg = 111;

cdS = const_data_so1(gNo);
varS = param_so1.var_numbers;
tgS = var_load_so1(varS.vCalTargets, cdS);

calibr_so1.skill_price_comp(tgS, paramS, cS);

end