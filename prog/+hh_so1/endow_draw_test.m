function endow_draw_test(gNo, setNo)

fprintf('Testing endow_draw \n');
cS = const_so1(gNo, setNo);
paramS = param_load_so1(gNo, setNo);

hh_so1.endow_draw(paramS, cS);

end