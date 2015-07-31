function param_from_guess_so1(gNo, setNo, noConfirm)

if ~strcmpi(noConfirm, 'noconfirm')
   ans1 = input('Copy parameters from guesses?  ',  's');
   if ~strcmpi(ans1, 'yes')
      return;
   end
end

cS = const_so1(gNo, setNo);
varS = param_so1.var_numbers;
[loadS, success] = var_load_so1(varS.vCalDevInputs, cS);

if success
   paramS = param_derived_so1(true, loadS.paramS, cS);
   var_save_so1(paramS, varS.vParams, cS);
else
   warning('Could not load guesses');
end


end