function iniglob_so1
% This must run on the server, so I cannot call go routines
% --------------------------------------------

disp('Ben-Porath experience profiles');

% Directory for program files etc.
progDir = fileparts(mfilename('fullpath'));
addpath(progDir);

% For now: directly use shared progs from matlab/LH
dirS = param_so1.directories(1,1);
addpath(dirS.sharedDir);
addpath(fullfile(dirS.sharedDir, 'export_fig'));


% Default figure properties
output_so1.fig_defaults

cd(progDir);


end
