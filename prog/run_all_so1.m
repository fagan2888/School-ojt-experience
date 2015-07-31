function run_all_so1(gNo, setNo)
% Run everything in sequence
%{
Making a new setNo
   Give it a name
   Override its options
   Use run_all to create cal targets etc
   Perhaps also copy paramS from another setNo
   If a grid: create a shell script to run it
   chmod +x script.sh
%}
% ------------------------------------

cS = const_so1(gNo, setNo);
saveFigures = 1;

% Make all directories for this set
if 0
   output_so1.mkdir(gNo, setNo);
end


%% Run data routines (cpsojt must be on path)
%  Run only once
if cS.isDataSetNo
   % Run CpsEarn to generate the data files
   %  Anything that depends on cpsearn is contained here
   data_so1.run_cpsearn(gNo);
   run_data_so1(gNo);

   error('not updated');   % +++++
   % Make a script to run a group of sets
   kure_scripts_so1(gNo); 
   return;
end


%% Calibration
if 0
   % Data files for group must exist before running this

   % Make directory for setNo (automatic when vars are saved)
   % mkdir_so1(cS);

   % Optional: copy params from another set as starting guess
   overWrite = 1;
   param_copy_so1(1, 1, gNo, setNo,  overWrite);

   saveHistory = 0;
   %calibrate_so1('none', saveHistory, gNo, setNo, []);
   
   % Parallel calibration
   % cal_parallel_so1(nRuns, saveHistory, gNo, setNo)
   
   % Run calibration on server
   % run_batch_so1('none', saveHistory, fromGuess,  gNo, setNo, []);
   
   % Make a command string to run a job
   % cmdStr = kure_command_so1(saveHistory, gNo, setNo, [])
   
   % Make a script that runs several gNo, setNo in sequence
   % kure_script_make_so1;
   return;
end

% Run something for all sets
% run_all_sets_so1(gNoV)



%%  Results


% Run results for all cases in batch
%        batch_results_so1

% Collects result routines that should be run every time
results_all_so1(gNo, setNo);

% Copy figures to paper dir
results_so1.paper_figures(gNo);

% Show effect of perturbing R
% +++ perturb_analytical_so1(0.1 : 0.01 : 0.95, [0, 0.05], cS.dR, saveFigures, cS);



%%  Testing
if 0
   test_all_so1(gNo, setNo);   
end

end