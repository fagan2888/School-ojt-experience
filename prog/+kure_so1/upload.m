function upload(gNo, setNoV)
% Upload mat files for several sets
% -----------------------------------------

cS = const_so1(gNo, setNoV(1));

ans1 = input('Upload these sets?', 's');
if ~strcmpi(ans1, 'yes')
   return
end

kure_so1.updownload(gNo, setNoV, 'up')


% *****  Also upload data
% No extra confirmation
kure_so1.updownload(gNo, cS.dataSetNo, 'up');

end