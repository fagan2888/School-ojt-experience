function [fPath, fn, fDir] = var_fn(varNo, cS)
% File name for a variable file

% can input a setNo or cS (more efficient)
% Checked 
% --------------------------------------------------------

% if nargin == 2
%    gNo = cS.gNo;
%    setNo = cS.setNo;
% elseif nargin ~= 4
%    error('Invalid nargin');
% end
% 
% if isempty(cS)
%    cS = const_so1(gNo, setNo);
% else
%    % gNo and setNo must be consistent with cS
%    if gNo ~= cS.gNo  ||  setNo ~= cS.setNo
%       error('Mismatch');
%    end
% end

varS = param_so1.var_numbers;

isDataVarNo = (varNo >= varS.dataVarRangeV(1))  &&  (varNo <= varS.dataVarRangeV(2));

if cS.isDataSetNo ~= isDataVarNo
   error('data set does not match variable no');
end


dirS = param_so1.directories(cS.gNo, cS.setNo);
fDir = dirS.matDir;
fn = sprintf('v%03i.mat', varNo);

fPath = fullfile(fDir, fn);


end
