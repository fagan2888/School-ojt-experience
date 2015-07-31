function kure_scripts_so1(gNo)

cS = const_so1(gNo, 1);

gPrefixStr = sprintf('run_g%02i_', gNo);

for gridNo = cS.gridNoV(:)'
   gS = grids_so1(gridNo, gNo);      
   kure_group_script_so1([gPrefixStr, gS.gridStr, '.sh'], gNo, gS.setNoV);
end

end