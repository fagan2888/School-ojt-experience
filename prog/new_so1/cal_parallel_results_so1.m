function cal_parallel_results_so1(nRuns, gNo, setNo)
% Collect results of a parallel run
%{
%}
% ---------------------------------------------

cS = const_so1(gNo, setNo);


%%  Loop over instances

% Deviations
devV = repmat(cS.missVal, [nRuns, 1]);

for iInst = 1 : nRuns
   % Directories
   cNewS = dir_modify_so1(cS, iInst);
   
   % Does it exist?
   if exist(cNewS.matDir, 'dir')
      % Need to rerun from guess?
      if exist(var_fn_so1(cS.vCalResults, cNewS), 'file') <= 0
         if exist(var_fn_so1(cS.vCalDevInputs, cNewS), 'file')
            calibrate_so1('devinputs', 0, gNo, setNo, iInst);
         else
            fprintf('Cannot rerun from guess: %i \n', iInst);
         end
      end
      
      % Store deviation
      if exist(var_fn_so1(cS.vCalResults, cNewS), 'file')
         calS = var_load_so1(cS.vCalResults, cNewS);
         devV(iInst) = calS.dev;
         fprintf('Deviation instance %i: %6.4f \n',  calS.dev);
         
         % Show some parameters
         paramS = calS.paramS;
         fprintf('    alpha(s):  ');
         fprintf('%8.2f', paramS.alphaV);         
         fprintf('\n');
         fprintf('    g(skill price):  ');
         fprintf('%8.2f', paramS.spGrowthV .* 100);         
         fprintf('\n');
      end
   else
      fprintf('Instance %i does not exist \n', iInst);
   end
end


%%  Copy best instance results to main dir
if any(devV ~= cS.missVal)
   [minDev, iInst] = min(devV);
   % Directories
   cNewS = dir_modify_so1(cS, iInst);
   success = copyfile([cNewS.matDir, '*.mat'], cS.matDir);
   fprintf('Files copied \n');
   
else
   fprintf('No valid instances \n');
end

fprintf('\nCollecting parallel results done\n');

end