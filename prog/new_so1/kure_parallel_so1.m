function cmdStr = kure_parallel_so1(nRuns, saveHistory, gNo, setNo)
% Create a string that can be submitted to run a PARALLEL calibration

% Log file name
logStr = sprintf('g%i_set%03i', gNo, setNo);


cmdStr = sprintf('bsub matlab -nodisplay -nosplash -singleCompThread -r "run_parallel_so1(%i,%i,%i,%i)" -logfile %s.out', ...
   nRuns, saveHistory, gNo, setNo, logStr);

   
end