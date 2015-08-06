function t_ge_cal_weights_so1(gNo, setNo)

cS = const_so1(gNo, setNo);
cS.dbg = 111;

rhoCG = 0.4;
rhoHS = 0.3;
yearV = (1970 : 2000)';
nYr   = length(yearV);
skillPriceM = 10 + rand([cS.nSchool, nYr]);
aggrHoursM  = 10 + rand([cS.demogS.ageRetire, cS.nSchool, nYr]);
meanEffM    = 5  + rand([cS.demogS.ageRetire, cS.nSchool, nYr]);


[muM, LS2M, meanEffSY2M] = ge_cal_weights_so1(yearV, skillPriceM, aggrHoursM, meanEffM, rhoHS, rhoCG, cS);

end