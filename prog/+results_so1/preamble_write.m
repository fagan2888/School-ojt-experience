function preamble_write(cS)
% Write preamble file
%{
make sure preamble is written to correct dir
in case it is started on server
%}
% ---------------------------------------------

% Make sure the file name for the tex is local
dirS = param_so1.directories(cS.gNo, cS.setNo);
varS = param_so1.var_numbers;
fn = output_so1.var_fn(varS.vPreambleData, cS);

m = load(fn);
pS = m.pS;
pS.texFn = dirS.preambleTexFn;
save(fn, 'pS');

preamble_lh.write_tex(fn);

end