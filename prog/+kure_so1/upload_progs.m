function upload_progs

% scriptNameStr = 'osascript  /Users/lutz/Dropbox/data/software/scripts/kure_upload.scpt';

dirS = param_so1.directories(1,1);
kure_lh.updownload(dirS.progDir, dirS.kureProgDir, 'up');
% scriptStr = [scriptNameStr, '  "',  dirS.progDir, '"  "',  dirS.kureProgDir, '"'];
% system(scriptStr);


global lhS
kure_lh.updownload(lhS.sharedDir, dirS.kureSharedDir, 'up');
% scriptStr = [scriptNameStr, '  "',  lhS.sharedDir, '"  "',  dirS.kureSharedDir, '"'];
% system(scriptStr);

   

end