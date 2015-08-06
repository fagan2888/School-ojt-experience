function updownload(gNo, setNoV, upDownStr)
% Upload or download sets to kure
%{
Processes all experiments for all sets
%}


%% Input check

validateattributes(gNo, {'numeric'}, {'finite', 'nonnan', 'nonempty', 'integer', '>=', 1})
validateattributes(setNoV, {'numeric'}, {'finite', 'nonnan', 'nonempty', 'integer', '>=', 1})

if strcmpi(upDownStr, 'up')
   up = true;
elseif strcmpi(upDownStr, 'down')
   up = false;
else
   error('Invalid doUpload');
end


%% Main


% scriptNameStr = 'osascript  /Users/lutz/Dropbox/data/software/scripts/kure_upload.scpt';

for ix = 1 : length(setNoV)
   dirS = param_so1.directories(gNo, setNoV(ix));
   
   % Matrix files (up or download)
   kure_lh.updownload(dirS.matDir, dirS.kureMatDir, upDownStr);
%    if up
%       localStr = dirS.matDir;
%       remoteStr = dirS.kureMatDir;
%    else
%       localStr = dirS.kureMatDir;
%       remoteStr = dirS.matDir;
%    end
%    cmdStr = [scriptNameStr, '  "',  localStr,  '"  "',  remoteStr, '" '];
%    disp(cmdStr)
%    system(cmdStr);
   
   % Out files (download only)
   if ~up
      kure_lh.updownload(dirS.outDir, dirS.kureOutDir, upDownStr);
%       localStr = dirS.kureOutDir;
%       remoteStr = dirS.outDir;
%       cmdStr = [scriptNameStr, '  "',  localStr,  '"  "',  remoteStr, '" '];
%       disp(cmdStr)
%       system(cmdStr);
   end
end


end