function param_copy(gNo1, setNo1, gNo2, setNo2,  askConfirm)
% Copy params from one set to another. For starting guesses
% ---------------------------------------------------------


% Ask for confirmation
if strcmpi(askConfirm, 'noconfirm')
   overWrite = true;
else
   ans1 = input('Overwrite parameters?  ', 's');
   if strcmpi(ans1, 'yes')
      overWrite = true;
   else
      overWrite = false;
   end
end

% Copy
if overWrite
   paramS = param_load_so1(gNo1, setNo1);
   c2S = const_so1(gNo2, setNo2);
   var_save_so1(paramS, c2S.vParams, c2S);
end


end