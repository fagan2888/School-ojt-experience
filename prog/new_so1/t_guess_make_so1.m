function t_guess_make_so1(gNo, setNo)

cS = const_so1(gNo, setNo);
paramS = param_set_so1(gNo, setNo);
paramS = param_derived_so1(1, paramS, cS);

argInS.blank = 1;
[guessV, argS] = guess_make_so1(argInS, paramS, cS);

param2S = guess_extract_so1(guessV, argS, paramS, cS);
param2S = param_derived_so1(0, param2S, cS);

fprintf('alpha values:  ');
fprintf('%10.3f', param2S.alphaV);
fprintf('    mean: %5.2f',  mean(param2S.alphaV));
fprintf('\n');

guess2V = guess_make_so1(argS, param2S, cS);

if max(abs(guessV - guess2V) > 1e-4)
   disp('Guesses do not match');
   keyboard;
   
else
   disp('Guesses match');
end



end