function paper_figures(gNo)
% Copy figures and tables into a convenient location for the paper

setNo = 1;
% cS = const_so1(gNo, setNo);
dirS = param_so1.directories(gNo, setNo);

paperDir = dirS.paperDir;


% Preamble tex file
copyone(dirS.preambleTexFn, fullfile(paperDir, 'preamble.tex'));



end


% Try to copy a file
function copyone(srcPath, destPath)
   % Returning success each time copyfile is called prevents errors when files don't exist
   success = copyfile(srcPath, destPath);
   if success <= 0
      warning('File copy failed');
      fprintf('   %s  ->  %s \n',  srcPath, destPath);
   end
end