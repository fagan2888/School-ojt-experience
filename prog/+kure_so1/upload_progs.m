function upload_progs

scriptNameStr = 'osascript  /Users/lutz/Dropbox/data/software/scripts/kure_upload.scpt';

dirS = param_so1.directories(1,1);
scriptStr = [scriptNameStr, '  "',  dirS.progDir, '"  "',  dirS.kureProgDir, '"'];
system(scriptStr);


global lhS
scriptStr = [scriptNameStr, '  "',  lhS.sharedDir, '"  "',  dirS.kureSharedDir, '"'];
system(scriptStr);

   

end