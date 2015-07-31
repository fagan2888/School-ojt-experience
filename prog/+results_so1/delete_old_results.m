function delete_old_results(gNo, setNo, minAge, askConfirm)
% Delete result files older than minAge days in a set
%{
IN
   setNo
      if []: delete for all experiments (everything that hangs off set)
%}

validateattributes(minAge, {'double'}, {'finite', 'nonnan', 'nonempty', 'integer', '>', 1})



%% Confirmation

if isempty(askConfirm)
   askConfirm = 'x';
end
if ~ischar(askConfirm)
   askConfirm = 'x';
end

if ~strcmpi(askConfirm, 'noConfirm')
   ans1 = input('Delete files?  ', 's');
   if ~strcmpi(ans1, 'yes')
      return;
   end
end


%% Delete

dirS = param_so1.directories(gNo, setNo);
baseDir = dirS.outDir;

inclSubDir = true;
extV = {'pdf', 'tex', 'txt', 'fig'};
for i1 = 1 : length(extV)
   fileMask = ['*.', extV{i1}];
   files_lh.delete_files(baseDir, fileMask, inclSubDir, minAge, 'noConfirm');
end



end