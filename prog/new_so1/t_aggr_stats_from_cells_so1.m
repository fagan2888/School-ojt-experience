function t_aggr_stats_from_cells_so1(gNo, setNo)

cS = const_so1(gNo, setNo);
cS.dbg = 111;

in_ascM = rand([cS.demogS.ageRetire, cS.nSchool, length(cS.demogS.bYearV)]);
wt_asM  = rand([cS.demogS.ageRetire, cS.nSchool]);

saveS = aggr_stats_from_cells_so1(in_ascM, wt_asM, cS)


end