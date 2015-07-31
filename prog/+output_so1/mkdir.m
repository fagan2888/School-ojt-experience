function mkdir(gNo, setNo)
% Make all dirs for this set

dbg = 111;
dirS = param_so1.directories(gNo, setNo);

dirV = {dirS.matDir, dirS.outDir};

for i1 = 1 : length(dirV)
   files_lh.mkdir_lh(dirV{i1}, dbg);
end


end