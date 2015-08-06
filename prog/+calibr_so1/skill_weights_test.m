function skill_weights_test(gNo, setNo)

fprintf('Testing skill_weights \n');
cS = const_so1(gNo, setNo);
paramS = param_load_so1(gNo, setNo);

T = 11;
lSupply_stM = rand(cS.nSchool, T);
skillPrice_stM = rand(cS.nSchool, T);

[skillWeightTop_tlM, skillWeight_tlM, AV] = ...
   calibr_so1.skill_weights(lSupply_stM, skillPrice_stM, paramS.aggrProdFct, cS);

% Check that marginal products come out right
mp_tsM = paramS.aggrProdFct.mproducts(AV, skillWeightTop_tlM, skillWeight_tlM, lSupply_stM');

if ~check_lh.approx_equal(skillPrice_stM, mp_tsM', 1e-2, 1e-3)
   error('Do not recover skill prices');
end

end