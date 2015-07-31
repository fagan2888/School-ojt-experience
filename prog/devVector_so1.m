classdef devVector_so1
% Vector of deviations between model and data

properties
   nUsed
   nameV
   devV
end

methods
   % *******  Constructor
   function dvS = devVector_so1(n)
      dvS.nUsed = 0;
      dvS.nameV = cell([n,1]);
      dvS.devV = zeros([n,1]);
   end
   
   
   % *******  Add a deviation
   function dvS = add(dvS, nameStr, dev)
      n = dvS.nUsed + 1;
      dvS.nUsed = n;
      dvS.nameV{n} = nameStr;
      dvS.devV(n) = dev;
   end
   
   
   % ********  Scalar dev
   function scalarDev = scalar_dev(dvS)
      scalarDev = sum(dvS.devV(1 : dvS.nUsed));
   end
   
   
   % ********  Show all non-zero devs
   function devStrV = collect_nonzero(dvS)
      idxV = find(dvS.devV ~= 0);
      n = length(idxV);
      if n == 0
         devStrV = [];
      else
         devStrV = cell([n,1]);
         for i1 = 1 : n
            devStrV{i1} = [dvS.nameV{idxV(i1)}, ': ', sprintf('%.3f',  dvS.devV(idxV(i1)))];
         end
      end
   end
end


end