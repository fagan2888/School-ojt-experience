function run_batch_so1(solverStr, saveHistory, gNo, setNo)
% Runs one calibration on kure
%{
Kure bug: job crashes as soon as some processors are idle. Cannot run sets
in parallel

IN
   solverStr
      'none'      just compute results, no calibration
      'guess'     compute results from intermediate guess, after a job crashed
%}

% Add dirs and set defaults
iniglob_so1;


%% Input check

if nargin ~= 4
   error('Invalid nargin');
end
if ~any(saveHistory == [0 1])
   error('Invalid saveHistory');
end


%% Main

if strcmpi(solverStr, 'guess')
   % Run from saved intermediate guess
   %  in case a job crashed before
   param_from_guess_so1(gNo, setNo, 'noConfirm');
   % Continue with default solver
   solverStr = 'fminsearch';
end

   
% Calibrate
calibrate_so1(solverStr, saveHistory, gNo, setNo);


disp('Runbatch is done.');


end