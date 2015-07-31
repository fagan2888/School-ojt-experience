function cNewS = dir_modify_so1(cS, instNo)
% Modify directories for an instance of parallel comp
% ----------------------------------------

cNewS = cS;

   
if ~isempty(instNo)
   if ~v_check(instNo, 'i', [1,1], 1, 100, [])
      error_so1('Invalid');
   end
   instStr = sprintf('i%03i', instNo);
   
   cNewS.matDir  = [cS.matDir, instStr, filesep];
   cNewS.outDir  = [cS.outDir, instStr, filesep];
   cNewS.figDir  = [cS.figDir, instStr, filesep];
   cNewS.tbDir   = [cS.tbDir,  instStr, filesep];
end

end