function updownload(gNo, setNoV, upDownStr)
% Upload or download sets to kure
%{
Processes all experiments for all sets
%}
% ------------------------------------------------


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

const_so1(gNo, setNoV(1));

scriptNameStr = 'osascript  /Users/lutz/Dropbox/data/software/scripts/kure_upload.scpt';

for ix = 1 : length(setNoV)
   dirS = param_so1.directories(gNo, setNoV(ix));
   
   % Matrix files (up or download)
   if up
      localStr = dirS.matDir;
      remoteStr = dirS.kureMatDir;
   else
      localStr = dirS.kureMatDir;
      remoteStr = dirS.matDir;
   end
   cmdStr = [scriptNameStr, '  "',  localStr,  '"  "',  remoteStr, '" '];
   system(cmdStr);
   
   % Out files (download only)
   if ~up
      localStr = dirS.kureOutDir;
      remoteStr = dirS.outDir;
      cmdStr = [scriptNameStr, '  "',  localStr,  '"  "',  remoteStr, '" '];
      system(cmdStr);
   end
end


end