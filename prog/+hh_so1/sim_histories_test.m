function sim_histories_test(gNo, setNo)

fprintf('Testing sim_histories \n');
tic

cS = const_so1(gNo, setNo);
paramS = param_load_so1(gNo, setNo);

tgSFrac_scM = zeros([cS.nSchool, cS.nCohorts]);
for ic = 1 : cS.nCohorts
   sFracV = 1 + rand([cS.nSchool, 1]);
   tgSFrac_scM(:, ic) = sFracV ./ sum(sFracV);
end

skillPrice_stM = rand([cS.nSchool, cS.spS.spYearV(end) - cS.spS.spYearV(1) + 1]);
saveSim = false;

outS = hh_so1.sim_histories(tgSFrac_scM, skillPrice_stM, saveSim, paramS, cS);
toc

end