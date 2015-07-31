function probV = prob_cg(abilV, prMult, aBar, cS)
% Probability of college graduation

if cS.dbg > 10
   validateattributes(aBar,   {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'scalar', '>', -4, ...
      '<', 4})
   validateattributes(prMult, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'scalar',  ...
      'positive'})
end

probV = logistic_lh(abilV, 0, 1,  1, prMult, aBar, cS.dbg);

end