function draw_random_vars_so1(mustRedraw, cS)
% Draw random variables to reuse for simulating hh histories
%{
Rescale so that mean and std are exactly right

Cannot be shared across sets! access errors

IN:
   mustRedraw
      redraw even if valid random vars already exist
%}
% ----------------------------------------------------------

nSim = cS.gS.nSim;

if mustRedraw ~= 0  &&  mustRedraw ~= 1
   error('Invalid');
end


%% Do we need to redraw rv's?

if mustRedraw == 1
   reDraw = 1;

else
   isValid = rv_check_so1(cS);
   reDraw  = ~isValid;
   if ~isValid
      fprintf('Need to redraw random variables \n');
   end
end



%%  Endowments
% Using quasi random numbers produces odd endowment patterns. Avoid.
if reDraw == 1
   % Set the seed to control what is drawn
   rng(42);
   rvM = randn([nSim, cS.nCohorts * 3 + 5]);
   % Draw quasi random variables for endowments
   % Must draw all at once
      % randn_quasi_lh(nSim, cS.nCohorts * 3 + 5, cS.dbg);
      
   % Avoid extreme draws
   rvM = max(-3, min(3, rvM));
   
   % Make sure mean and std are exactly right
   for ic = 1 : size(rvM, 2)
      rvM(:,ic) = (rvM(:,ic) - mean(rvM(:,ic))) ./ std(rvM(:,ic));
   end
   
   % Indicates last used column
   cLast = 0;
   
   % Abilities
   cIdxV = cLast + (1 : cS.nCohorts);
   saveS.rvAbilM = rvM(:, cIdxV);
   cLast = cIdxV(end);

   % H1
   cIdxV = cLast + (1 : cS.nCohorts);
   saveS.rvH1M = rvM(:, cIdxV);
   cLast = cIdxV(end);

   % Psychic cost - std normal
   % saveS.rvPrefV = single(randn([nSim, 1]));

   % IQ
   cIdxV = cLast + (1 : cS.nCohorts);
   saveS.rvIqM = rvM(:, cIdxV); 
   for ic = 1 : cS.nCohorts
      saveS.rvIqM(:,ic) = (saveS.rvIqM(:,ic) - mean(saveS.rvIqM(:,ic))) ./ std(saveS.rvIqM(:,ic));
   end
   cLast = cIdxV(end);

   var_save_so1(saveS, cS.vRandomVars, cS);
end


end