function preamble_init(cS)

varS = param_so1.var_numbers;
dirS = param_so1.directories(cS.gNo, cS.setNo);

% texFn = fullfile(dirS.tbDir, 'preamble.tex');

preamble_lh.initialize(output_so1.var_fn(varS.vPreambleData, cS), dirS.preambleTexFn);

end