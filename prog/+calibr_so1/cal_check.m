function cal_check(gNo, setNo)
% Check that a completed calibration is correct

cS = const_so1(gNo, setNo);
%figS = const_fig_so1;
%dirS = param_so1.directories(gNo, setNo);
varS = param_so1.var_numbers;

cdS = const_data_so1(gNo);
tgS = var_load_so1(varS.vCalTargets, cdS);


simS = var_load_so1(varS.vSimResults, cS);


% Endowments
calibr_so1.endow_check(gNo, setNo);
% Ben-Porath part
calibr_so1.ojt_check(gNo, setNo);


% Are target school fractions attained?
sDiff = max(abs(tgS.sFrac_scM(:) - simS.sFrac_scM(:)));
if sDiff > 1e-2
   error_so1('Target school fractions not attained', cS);
end


end