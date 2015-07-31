function [outV, success] = var_load_so1(varNo, cS)

fn = output_so1.var_fn(varNo, cS);

if ~exist(fn, 'file')
   outV = [];
   success = 0;
%    version1 = 0;
else
   loadS = load(fn);
   outV = loadS.outV;
%    if isfield(loadS, 'version1')
%       version1 = loadS.version1;
%    else
%       version1 = 0;
%    end
   success = 1;
   

%    % ****  Convert numeric fields to double
%    %  questionable +++++
%    if isa(outV, 'struct')
%       fieldV = fieldnames(outV);
%       for i1 = 1 : length(fieldV)
%          if isa(outV.(fieldV{i1}), 'single')
%             outV.(fieldV{i1}) = double(outV.(fieldV{i1}));
%          end
%       end
%    end
end


end