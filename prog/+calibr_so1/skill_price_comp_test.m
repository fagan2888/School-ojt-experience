function skill_price_comp_test(gNo, setNo)

cS = const_so1(gNo, setNo);
paramS = param_load_so1(gNo, setNo);
cS.dbg = 111;

skillPrice_stM = calibr_so1.skill_price_comp(paramS, cS);

end