function ojt_check(gNo, setNo)
% Not testing how skill prices are converted from [a,s,t] to [a,s,c] (b/c obvious)

cS = const_so1(gNo, setNo);
paramS = param_load_so1(gNo, setNo);
varS = param_so1.var_numbers;
simS = var_load_so1(varS.vSimResults, cS);

% This really for the most part repeats ojt_solve code
for ic = 1 : cS.nCohorts
   for iSchool = 1 : cS.nSchool
      workAgeV = cS.demogS.workStartAgeV(iSchool) : cS.demogS.ageRetire;
      
      % Make a Ben-Porath structure
      %  The productivity parameter does not matter
      bpS = BenPorathLH(simS.skillPrice_ascM(workAgeV, iSchool,ic), paramS.tEndow_ascM(workAgeV, iSchool, ic), ...
         paramS.alphaV(iSchool), paramS.ddhV(iSchool), 1, paramS.R, paramS.trainTimeMax, cS.hMax);

      % Productivity parameters
      pProductV = hh_so1.ojt_productivity(simS.abil_icM(:,ic), iSchool, ic, paramS, cS);

      % Solve OJT problem, using generic Ben-Porath routine
      h_itM = bpS.solve(simS.h_itscM(:, workAgeV(1), iSchool,ic), pProductV, cS.dbg);
      check_lh.approx_equal(h_itM,  simS.h_itscM(:, workAgeV, iSchool,ic), [], 1e-6);
   end
end

end
