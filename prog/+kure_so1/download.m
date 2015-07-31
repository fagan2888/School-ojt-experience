function download(gNo, setNoV)
% Down mat files for several sets
% -----------------------------------------

ans1 = input('Download these sets?', 's');
if ~strcmpi(ans1, 'yes')
   return
end

kure_so1.updownload(gNo, setNoV, 'down')


end