function dirS = directories(gNo, setNo)
%  Directories
%{
Keep all mat files in 1 sub-dir for easier copying to kure
%}

global lhS

dirS.groupStr = sprintf('g%02i', gNo);
dirS.setStr   = sprintf('set%03i', setNo);


%% Kure directories, must always be set

baseDir = '/nas02/home/l/h/lhendri/school_ojt/experience/';
dirS.kureBaseDir = baseDir;

dirS.kureProgDir = fullfile(baseDir, 'prog');
dirS.kureSharedDir = fullfile(baseDir, 'LH');
dirS.kureMatBaseDir  = fullfile(baseDir, 'mat');
dirS.kureOutBaseDir  = fullfile(baseDir, 'out');

   dirS.kureOutDir = fullfile(dirS.kureOutBaseDir, dirS.groupStr, dirS.setStr);
   dirS.kureMatDir = fullfile(dirS.kureMatBaseDir, dirS.groupStr, dirS.setStr);



%% Directories that apply on this machine

% Running locally?
if exist('/Users/lutz/', 'dir')    
   dirS.runLocal = true;
   dirS.baseDir = '/Users/lutz/dropbox/hc/school_ojt/experience/';
   dirS.progDir = fullfile(dirS.baseDir, 'model1', 'prog');
   % May want to move that out of dropbox +++
   dirS.matBaseDir  = fullfile(dirS.baseDir, 'mat');
   dirS.outBaseDir  = fullfile(dirS.baseDir, 'model1', 'out');
   
      % Specific to group and set
      dirS.outDir = fullfile(dirS.outBaseDir, dirS.groupStr, dirS.setStr);
      dirS.matDir = fullfile(dirS.matBaseDir, dirS.groupStr, dirS.setStr);
      
   dirS.sharedDir = lhS.sharedDir;
      
else
   % Kure
   dirS.runLocal = false;
   dirS.baseDir = dirS.kureBaseDir;
   dirS.progDir = dirS.kureProgDir;
   dirS.matBaseDir  = dirS.kureMatBaseDir;
   dirS.outBaseDir  = dirS.kureOutBaseDir;
      
      % Specific to group and set
      dirS.outDir = dirS.kureOutDir;
      dirS.matDir = dirS.kureMatDir;
      
   dirS.sharedDir = dirS.kureSharedDir;
end


dirS.figDir = dirS.outDir;
dirS.tbDir  = dirS.outDir;
   dirS.fitDir = fullfile(dirS.outDir, 'fit');
   dirS.paramDir = fullfile(dirS.outDir, 'param');


% Preamble tex file
dirS.preambleTexFn = fullfile(dirS.tbDir, 'preamble.tex');

% Directory with figures for paper
dirS.paperDir = fullfile(dirS.baseDir, 'PaperFigures');


end