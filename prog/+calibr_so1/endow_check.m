function endow_check(gNo, setNo)
% Check endowments
%{
Should check normality
%}

disp('Checking endowments');

cS = const_so1(gNo, setNo);
paramS = param_load_so1(gNo, setNo);
varS = param_so1.var_numbers;
simS = var_load_so1(varS.vSimResults, cS);


%% Distribution of h1, ability

for ic = 1 : cS.nCohorts
   logH1V = log(simS.h1_icM(:, ic));
   hMean = mean(logH1V);
   hStd  = std(logH1V);
   if abs(hMean - paramS.meanLogH1V(ic)) > 1e-2
      error('Invalid h Mean');
   end
   if abs(hStd - paramS.h1Std) > 1e-2
      error('Invalid h std');
   end
   
   abilV  = simS.abil_icM(:,ic);
   if abs(mean(abilV) - 0) > 1e-2
      error('Invalid mean ability');
   end
   if abs(std(abilV) - 1) > 1e-2
      error('Invalid std ability');
   end
end


%% h at work start

for ic = 1 : cS.nCohorts
   for iSchool = 1 : cS.nSchool
      hWorkStartV = hh_so1.school_tech(simS.h1_icM(:, ic), simS.abil_icM(:, ic), iSchool, ic, paramS, cS);
      simV = simS.h_itscM(:, cS.demogS.workStartAgeV(iSchool), iSchool, ic);
      check_lh.approx_equal(hWorkStartV(:), simV(:), [], 1e-5);
   end
end


end