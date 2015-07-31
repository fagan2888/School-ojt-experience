function cmdStr = command(solverStr, gNo, setNo)
% Create a string that can be submitted to run a calibration
% -------------------------------------------------

cS = const_so1(gNo, setNo);
saveHistory = 0;

% Log file name
logStr = sprintf('g%02i_set%03i.out', gNo, setNo);

bsubStr = 'bsub matlab -nodisplay -nosplash -singleCompThread -r ';

argStr = sprintf('(''%s'',%i,%i,%i)',  solverStr, saveHistory, gNo, setNo);

cmdStr = [bsubStr,  '"run_batch_so1',  argStr, '"  ',  logStr];

if cS.runLocal
   clipboard('copy', cmdStr);
end

   
end