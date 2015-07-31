function probV = prob_hsg(abilV, prMult, aBar, cS)
% Probability of HS graduation

probV = logistic_lh(abilV, 0, 1,  1, prMult, aBar, cS.dbg);

end