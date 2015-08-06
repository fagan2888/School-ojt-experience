function isValid = rv_check_so1(cS)
% Check whether file with random vars is valid
% --------------------------------------------

isValid = 1;

[loadS, success] = var_load_so1(cS.vRandomVars, cS);
if success == 1
   if isfield(loadS, 'rvAbilM')
      if ~isequal(size(loadS.rvAbilM), [cS.nSim, cS.nCohorts])
         isValid = 0;
      end
   else
      isValid = 0;
   end
   
   if isfield(loadS, 'rvIqM')
      if ~isequal(size(loadS.rvIqM), [cS.nSim, cS.nCohorts])
         isValid = 0;
      end
   else
      isValid = 0;
   end
   
else
   isValid = 0;
end

   
end