function kure_script_make_so1
% Make a script to run several jobs at once
%{
Edit file to override which gNo and setNo are run
%}
% --------------------------------------------

%% Sets to run

% Run each set for each group
gNoV = [2,3,4,6,8,9,10];
setNoV = [91, 94];

% additional individual sets to run
gNoExtraV = [];
setNoExtraV = [];



% **** Make into a vector

ng = length(gNoV);
ns = length(setNoV);
gNoM = gNoV(:) * ones([1, ns]);
setNoM = ones([ng, 1]) * setNoV(:)';

gNoV = gNoM(:);
setNoV = setNoM(:);

% Add extra sets
if ~isempty(gNoExtraV)
   gNoV = [gNoV; gNoExtraV(:)];
   setNoV = [setNoV; setNoExtraV(:)];
end

fprintf('\nRunning these sets: \n');
disp([gNoV, setNoV]);
keyboard;


%% Main

% ***  Copy params from last input to cal_dev3
if 0
   runResults = 0;
   askConfirm = 0;
   param_from_guess_so1(runResults, gNoV, setNoV, askConfirm);
end


% Make script to run
fnStr = 'run_adhoc.sh';
group_script_so1(fnStr, gNoV, setNoV);



end