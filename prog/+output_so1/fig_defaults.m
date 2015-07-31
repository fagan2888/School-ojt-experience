function fig_defaults
% Set figure defaults
% ------------------------------

figS = const_fig_so1;

% Set default line width
set(0, 'DefaultLineLineWidth', 2);

set(0, 'DefaultAxesColorOrder', figS.colorM);


set(0, 'defaultAxesFontName', figS.figFontName);
set(0, 'defaultTextFontName', figS.figFontName);


end % eof
