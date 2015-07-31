function cal_parallel_so1(nRuns, saveHistory, gNo, setNo)
% Run several calibrations of the same gNo / setNo parallel
%{
Afterwards: run code to copy best solution to main dir
Submitted on kure by run_parallel_so1
%}
% ------------------------------

iniglob_so1;
cS = const_so1(gNo, setNo);

fprintf('Starting parallel computation for %i / %i.  %i instances \n', ...
   gNo, setNo, nRuns);


%% Remove existing instances
for i1 = 1 : 50
   % Get directories
   cNewS = dir_modify_so1(cS, i1);

   % Remove exising contents
   dirV = {cNewS.matDir, cNewS.outDir, cNewS.figDir, cNewS.tbDir};
   for iDir = 1 : length(dirV)
      if exist(dirV{iDir}, 'dir')
         [result, msg] = rmdir(dirV{iDir});
      end
   end
end


%% Create dirs and copy info for instances
% Then run calibration
for instNo = 1 : nRuns
   fprintf('Running calibration %i / %i  instance %i \n', gNo, setNo, instNo);

   % Get directories for instance
   cNewS = dir_modify_so1(cS, instNo);

   % Mk dirs
   mkdir_so1(cNewS);
   
   % Copy files
   varNoV = [cS.vParams, cS.vRandomVars];
   for varNo = varNoV(:)'
      oldFile = var_fn_so1(varNo, cS);
      newFile = var_fn_so1(varNo, cNewS);
      copyfile(oldFile, newFile);
   end
   
   % Run calibration (shell scripts)
   cmdStr = kure_command_so1(saveHistory, gNo, setNo, instNo);
   if cS.runLocal == 1
      disp('This is the command we would be running on server');
      disp(cmdStr);
   else
      system(cmdStr);
   end
end


end