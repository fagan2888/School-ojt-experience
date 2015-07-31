function error_so1(errorStr, cS)
% Replaces error so that keyboard is used when not run unattended
% --------------------------------------------------------

if nargin == 1
   cS = const_so1(1,1);
end

notParallel = isempty(gcp('nocreate'));   % matlabpool('size');

fprintf('\n\nError in set %i\n\n', cS.setNo);
if cS.runLocal == 1  &&  notParallel == 1
   disp(errorStr);
   keyboard;
else
   error(errorStr);
end


end