function param_copy_so1(gNo, setNo, gNo2, setNo2, overWrite)
% Copy parameters, with confirmation

varS = param_so1.var_numbers;

% Ask for confirmation
if ~input_lh.ask_confirm(sprintf('Overwrite parameters for %i / %i?  ',  gNo2, setNo2), 'x')
   return;
end

if ~overWrite
   % Check whether file exists
   cS = const_so1(gNo, setNo);
   if exist(output_so1.var_fn(varS.vParams, cS), 'file')
      disp('File already exists');
      return;
   end
   clear cS;
end

paramS = param_load_so1(gNo, setNo);

c2S = const_so1(gNo2, setNo2);
var_save_so1(paramS, varS.vParams, c2S);


end