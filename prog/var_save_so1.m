function var_save_so1(outV, varNo, cS)
% Save a MAT variable
%{
% IN
%  either cS or gNo and setNo

Change: 
   conversion to single probably forces passing by value +++
%}
% ----------------------------------------------

% if nargin == 3
%    gNo = cS.gNo;
%    setNo = cS.setNo;
% elseif nargin ~= 5
%    error('Invalid nargin');
% end
% 
% % gNo and setNo must be consistent with cS
% if isempty(cS)
%    cS = const_so1(gNo, setNo);
% end
% if gNo ~= cS.gNo  ||  setNo ~= cS.setNo
%    error('Mismatch');
% end


[fn, ~, fDir] = output_so1.var_fn(varNo, cS);

% Create dir if it does not exist
if ~exist(fDir, 'dir')
   files_lh.mkdir_lh(fDir, 0);
end

% % *****  Convert to single
% %  questionable +++++
% if varNo >= 151  &&  varNo <= 199
%    if isa(outV, 'struct')
%       fieldV = fieldnames(outV);
%       for i1 = 1 : length(fieldV)
%          if isa(outV.(fieldV{i1}), 'double')
%             outV.(fieldV{i1}) = single(outV.(fieldV{i1}));
%          end
%       end
%    end
% end

% version1 = cS.version;
save(fn, 'outV');

fprintf('Saved set %i / %i  variable %i  \n',  cS.gNo, cS.setNo, varNo);

end