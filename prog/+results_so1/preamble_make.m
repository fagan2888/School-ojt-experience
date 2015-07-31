function preamble_make(gNo, setNo)
% Write data for preamble
%{
Various functions can add to preamble.
It must be initialized with preamble_init first
%}

cS = const_so1(gNo, setNo);


%% Notation for model parameters
% Each potentially calibrated parameter gets a newcommand

for i1 = 1 : cS.pvector.np
   nameStr = cS.pvector.nameV{i1};
   if length(nameStr) > 1
      ps = cS.pvector.retrieve(nameStr);
      results_so1.preamble_add(nameStr,  ps.symbolStr,  ps.descrStr,  cS);
   end
end


%% Other model notation

outS = param_so1.symbols;
fnV = fieldnames(outS);
for i1 = 1 : length(fnV)
   results_so1.preamble_add(fnV{i1},  outS.(fnV{i1}),  'Symbol', cS);
end


%% Data constants

% results_so1.preamble_add('cpiBaseYear',  sprintf('%i', cS.cpiBaseYear),  'CPI base year',  cS);


results_so1.preamble_write(cS);

end