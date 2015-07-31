function error_save(descrStr, saveS, cS)
% Save something. Then throw error

notParallel = isempty(gcp('nocreate'));   % matlabpool('size');

if cS.runLocal == 1  &&  notParallel == 1
   useKeyboard = true;
else
   useKeyboard = false;
end

filePath = fullfile(cS.matDir, 'error_save.mat');

check_lh.error_save(descrStr, saveS, filePath, useKeyboard);

end