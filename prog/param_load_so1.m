function [paramS, success] = param_load_so1(gNo, setNo)
% Load saved model params and impose derived params
%{
If loading fails, just return default params
%}
% -------------------------------------------------

cS = const_so1(gNo, setNo);
varS = param_so1.var_numbers;
[paramS, success] = output_so1.var_load(varS.vParams, cS);

if success == 0
   paramS.gNo = gNo;
   paramS.setNo = setNo;
end

% Later: decide how to handle study time +++++
paramS = param_derived_so1(false, paramS, cS);


end