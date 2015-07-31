function fig_save(figFn, saveFigures, cS)
%{
IN
   figFn
      with or without directory
%}

dirS = param_so1.directories(cS.gNo, cS.setNo);

% Add directory, if none present
figFn = files_lh.fn_complete(figFn, dirS.outDir, [], cS.dbg);

figS = const_fig_so1;
figOptS = figS.figOptS;

figOptS.figDir = fullfile(dirS.figDir, 'figdata');
if ~exist(figOptS.figDir, 'dir')
   files_lh.mkdir_lh(figOptS.figDir);
end

figures_lh.fig_save_lh(figFn, saveFigures, figS.slideOutput, figOptS);

end