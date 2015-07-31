function calibrate_so1(solverStr, saveHistory, gNo, setNo)
% Calibrate model to match observed age wage profiles for various cohorts
%{
IN:
   solverStr
      solver to be used
      'none': do not calibrate; use loaded params
      'test': do not generate results
   saveHistory
      save history to file?

The model is currently not solved in parallel. It is too fast for that.
Deviation function cannot load / save any shared variables (e.g. cal targets)

Checked: 2014-04-07
%}
% -------------------------------------------------

cS = const_so1(gNo, setNo);
varS = param_so1.var_numbers;
perturbGuesses = false;

disp(' ');
disp('-------------------------------');
disp(' ');
fprintf('Starting calibration %i / %i \n', gNo, setNo);
disp(' ');
disp(['Solver: ', solverStr]);

calibr_so1.cal_features(cS);


%% Preparation

% Make output dirs if they don't already exist
output_so1.mkdir(gNo, setNo);


% Check random vars. Redraw if needed
% draw_random_vars_so1(0, cS);


% Try to load guess
paramS = param_load_so1(gNo, setNo);

% Calibration targets
cdS = const_data_so1(gNo);
tgS = var_load_so1(varS.vCalTargets, cdS);
clear cdS;



%%  Calibrated params

guessV = cS.pvector.guess_make(paramS, cS.calBase);
% Bounds of transformed guesses
gLbV = cS.pvector.guessMin .* ones(size(guessV));
gUbV = cS.pvector.guessMax .* ones(size(guessV));


% Perturb guesses if needed (to test convergence)
%  But not if solver skips optimization
if perturbGuesses  &&  ~strcmpi(solverStr, 'none')  &&  ~strcmpi(solverStr, 'devinputs')
   fprintf('Perturbing guesses \n');
   % Weight on original guess
   perturbWt = 0.7;
   % Weight on lb for each guess
   boundWtV  = 0.25 + 0.5 .* rand(size(gLbV));
   guessV = perturbWt .* guessV + (1-perturbWt) .* (boundWtV .* gLbV + (1-boundWtV) .* gUbV);
end


%%  Minimization: Preparation

% Initialize history file
if saveHistory
   error('Not updated');
%    histS.iter = 0;
%    % Max no of iterations to save
%    histS.maxIter = cS.histMaxIter;
%    histS.resultV = cell([histS.maxIter, 1]);
%    output_so1.var_save(histS, cS.vOptimHistory, cS);
%    clear histS;
end


% ****  Arg structure for deviation function

argS.guessLbV = gLbV;
argS.guessUbV = gUbV;
% Show results in every iter?
argS.showResults = false;
% Save inputs in each iteration
argS.saveInputs = false;
% Deviation function returns scalar deviation
argS.scalarDev = true;
% Do not save sim results until done
argS.saveSim = false;
% Save iteration history to file?
argS.saveHistory = saveHistory;

TolFun = 1e-2;
% Deviation function
fHandle = @cal_dev_nested_so1;


% Call deviation function so we can see where we start
if 1
   fprintf('\n\nResults with guesses:\n\n');
   argS.showResults = 1;
   dbgOld = cS.dbg;
   cS.dbg = 111;
   cal_dev_fminsearch_so1(guessV);
   cS.dbg = dbgOld;
   argS.showResults = 0;
end


% ******  Check that all params affect deviation
if 0
   fprintf('\nChecking that all params affect objective \n');
   % Make new guesses
   guessNewV = guessV + 0.2;
   idxV = find(guessNewV > argS.guessUbV);
   if ~isempty(idxV)
      guessNewV(idxV) = guessV(idxV) - 0.2;
   end
   
   dev0 = cal_dev_fminsearch_so1(guessV);
   
   for i1 = 1 : length(guessV)
      guess2V = guessV;
      guess2V(i1) = guessNewV(i1);
      devNew = cal_dev_fminsearch_so1(guess2V);
      if abs(devNew - dev0) < 1e-2
         fprintf('i1: %i   devNew: %.3f   dev0: %.3f \n',  i1, devNew, dev0);
         error('Guess does not affect objective');
      end
   end
end



% *****  Plot deviation against 1 param
if 0
   n = 5;
   alphaHSGV = paramS.alphaV(cS.schoolHSG) + linspace(-0.1, 0.1, n);
   devV = zeros([n,1]);
   for i1 = 1 : n
      paramS.alphaV(cS.schoolHSG) = alphaHSGV(i1);
      guessV = guess_make_so1(argS, paramS, cS);
      gLbV = cS.guessMin .* ones(size(guessV));
      gUbV = cS.guessMax .* ones(size(guessV));
      [devV(i1), iFail, iCount, outS] = cal_dev_fminsearch_so1(guessV);
   end
   
   plot(alphaHSGV, devV, 'o-');
   keyboard;
end


%% Optimization

% ******  Nelder Meade
if strcmpi(solverStr, 'fminsearch')
   clear optS;
   optS = optimset('fminsearch');
   optS.TolFun = 1e-2;
   optS.MaxFunEvals = 2e4;
   [solnV, saveS.fVal, saveS.exitFlag] = fminsearch(@cal_dev_fminsearch_so1, guessV, optS);
   
   
% *****  globalsearch_lh
elseif strcmpi(solverStr, 'globalsearch_lh')
   processNo = 1; % could run on multiple nodes, but not used right now.
   optS = optimset_gslh(length(guessV));
   optS.historyPath = var_fn_so1(cS.vOptimHistory, cS);
   optS.historyTempPath = var_fn_so1(cS.vOptimHistoryTemp, cS);
   optS.TolFun = TolFun;
   optS.MaxFunEvals = 1e4;
   optS.minPoints = 50;
   optS.maxPoints = 60;
   optS.maxTime   = 100;
   optS.maxStepsNoGain = 20;
   optS.processNo = processNo;
   optS.npRadiusFactor = 0.3;
   %optS.nPointsParallel = 4;
   % Save this output arg of deviation function to history
   optS.saveIterOutput = 4;
   if strcmpi(cS.localSolverStr, 'imfil')
      % For imfil
      optS.solverStr = 'imfil';
      optS.solverOptS = imfilOptS;
      optS.fHandle = fHandle;
      optS.saveIterOutput = 4;
   elseif strcmpi(cS.localSolverStr, 'fminsearch')
      optS.solverStr = 'fminsearch';
      clear opt2S;
      opt2S = optimset('fminsearch');
      opt2S.TolFun = 1e-2;
      opt2S.MaxFunEvals = 1e4;
      optS.solverOptS = opt2S;
      optS.fHandle = @cal_dev_fminsearch_so1;
      optS.saveIterOutput = 4;      
   else
      error('Invalid local solver');
   end
   
   % Run another solver on the best N points
   if ~strcmpi(optS.solverStr, 'fminsearch')  &&  0
      error('Not updated');
      optS.l2NoPoints = 5;
      optS.l2SolverStr = 'fminsearch';
      optS.l2SolverOptS = fmsOptS;
      optS.l2SolverOptS.MaxFunEvals = 400;
      optS.l2fHandle = @cal_dev_fminsearch_rs5;
   end
   
   if strcmpi(solverStr, 'globalsearch_lh')   
      [solnV, dev] = globalsearch_lh(guessV, gLbV, gUbV, optS);
   else
      % Just copy temp history to final history
      % Then get solution from that
      histS = hist_load_gslh(optS.historyTempPath);
      hist_save_gslh(histS, optS.historyPath);
   end
   
   % Post-processing: If more than one process, get best solution from
   % file.
   % Problem: the other processNo could still be running
   if optS.processNo == 1
      histS = hist_load_gslh(optS.historyPath);
      solnV = histS.solnV;
      saveS.fVal   = histS.fMin;
   else
      % Terminate without doing anything else. Only 1st process does
      % post-processing
      return;
   end
   

% ***** fmincon
elseif strcmpi(solverStr, 'fmincon')
   % Run solver
   optS = optimset('fmincon');
   optS.Algorithm = 'active-set';
   optS.DiffMinChange = 1e-3;
   optS.TolFun = 1e-2;
   optS.TolX = 1e-3;
   optS.LargeScale = 'off';
   % set max fun evals +++

   if 0     % cS.parallel == 1
         % currently cannot run parallel on kure +++
      optS.UseParallel = 'always';
      disp('Parallel solver');
   end
   
   [solnV, saveS.fVal, saveS.exitFlag] = fmincon(@cal_dev_nested_so1, guessV, [],[],[],[], gLbV, gUbV, [], optS);
   
   
elseif strcmpi(solverStr, 'imfil')
   % *******  IMFIL   
   argS.scalarDev = 1;
   
   % Algorithm parameters
   maxIter = 500;
   
   % Run
   solnV = imfil(guessV(:), @cal_dev_nested_so1, maxIter, [gLbV, gUbV], imfilOptS);
   saveS.fVal = 0;
   saveS.exitFlag = 1;

   
elseif strcmpi(solverStr, 'none')  ||  strcmpi(solverStr, 'test')
   % Also useful to ensure that results are current
   disp('For testing: skip optimization part');
   cS.dbg = 111;
   solnV = guessV;
   % Try to preserve fVal and exitFlag
   [tmpS, success] = var_load_so1(varS.vCalResults, cS);
   if success == 1
      saveS.fVal = tmpS.fVal;
      saveS.exitFlag = tmpS.exitFlag;
   else
      saveS.fVal = 0;
      saveS.exitFlag = 1;
   end
   clear tmpS;
   
   
elseif strcmpi(solverStr, 'devinputs')
   disp('Run from saved input to cal_dev');
   % Load most recent input to cal_dev
   loadS = var_load_so1(varS.vCalDevInputs, cS);
   solnV = loadS.guessV;
   if length(solnV) ~= length(guessV)
      error('Wrong size');
   end
   argS = loadS.argS;
   argS.saveInputs = 0;
   saveS.fVal = 0;
   saveS.exitFlag = 1;
   
else
   error('Invalid solver');
end

% Call deviation function to recover additional outputs
disp(' ');
disp('Calibration done. Saving results.');
argS.saveSim = 1;
cS.dbg = 111;
[devV, ~,~, outS] = cal_dev_nested_so1(solnV(:));

fprintf('  exitFlag: %4.1f    terminal fVal: %6.3f \n\n', ...
   saveS.exitFlag, saveS.fVal);



%%  Save

% Transformed parameter vector
saveS.solnV  = solnV(:);
saveS.paramS = outS.paramS;
% Cal targets
saveS.tgS = tgS;
% Output of deviation function at solution
%     Does not incl Policy functions
%     Contains large wageM matrix. Would be helpful to store that as single.
saveS.calDevS = outS;
% Final deviation
saveS.dev = norm(devV);
var_save_so1(saveS, varS.vCalResults, cS);

% Parameters
var_save_so1(saveS.paramS, varS.vParams, cS);

% Compute additional stats
calibr_so1.sim_stats(gNo, setNo);
if ~strcmp(solverStr, 'test')
   results_all_so1(gNo, setNo);
end


disp('-----  calibration done  ------');
%keyboard;

return;
% end of main function


%%  Nested functions
%{
Deviation function
 Accepts multiple guesses at the same time (for imfil)
 Each column is a guess
 outS is not returned when there are multiple guesses

IN:
 argS
    scalarDev
       output scalar deviation?
    saveSim
       save sim results?
OUT:
   iFail, iCount
      dummy arguments for imfil (which should not check those, but it does)
   outS
      only returned when a single guess is provided
%}   
function [devV, iFail, iCount, outS] = cal_dev_nested_so1(guessM)
   % No of guesses to be executed in parallel
   ng = size(guessM, 2);
   %fprintf('\n-----  cal_dev_nested with %i guesses \n', ng);
   iFail = zeros([ng, 1]);
   iCount = ones([ng, 1]);
   if ng == 1
      % One guess. Nothing parallel
      [devV, outS] = calibr_so1.cal_dev(guessM, argS, tgS, paramS, cS);

   else
      % Parallel. Multiple guesses
      % Must be a row vector
      if argS.scalarDev ~= 1
         error('Must have scalar dev for parallel');
      end
      devV = zeros([1, ng]);
      outS = 0;
      parfor ig = 1 : ng
         devV(ig) = calibr_so1.cal_dev(guessM(:, ig), argS, tgS, paramS, cS);
      end
   end
end


% *****  for fminsearch
function [devV, iFail, iCount, outS] = cal_dev_fminsearch_so1(guessV)
   % For fminsearch. Must return large dev for out of bounds
   % guessM must be vector (one guess)
   if any(guessV(:) < argS.guessLbV(:))  ||  any(guessV(:) > argS.guessUbV(:))
      devV = 1e8;
      outS = 'failed';
      iFail = 1;
      iCount = 1;
   else
      iFail = 0;
      iCount = 1;
      [devV, outS] = calibr_so1.cal_dev(guessV, argS, tgS, paramS, cS);
   end
end
   

end