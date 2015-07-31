function fig_format(fh, figType)

if nargin < 2
   figType = 'line';
end

figS = const_fig_so1;

figures_lh.format(fh, figType, figS);


end