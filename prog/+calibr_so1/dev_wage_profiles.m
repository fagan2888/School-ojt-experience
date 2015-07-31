function [dev, ssd_scM] = dev_wage_profiles(model_ascM, data_ascM, wt_ascM, cS)
% Deviation from mean log or log median wage profiles
%{
IN:
   model_ascM
      model log wages
   data_ascM
      usually tgS.logWage_ascM
   wt_ascM
      usually tgS.wageWt_ascM

OUT:
   dev
      scalar deviation
   ssd_scM
      sum of squared residuals (weighted)
%}


%% Input check

[~, ~, nc] = size(model_ascM);

if cS.dbg > 10
   if ~v_check(model_ascM, 'f', size(data_ascM), -10, 10, cS.missVal)
      error_so1('Invalid');
   end
   if ~v_check(wt_ascM, 'f', size(data_ascM), 0, [], [])
      error_so1('Invalid');
   end
end


%% Main

ssd_scM = zeros([cS.nSchool, nc]);

for ic = 1 : nc
   for iSchool = 1 : cS.nSchool
      % Ages for which wages are compared
      ageRangeV = max(cS.workStartAgeV(iSchool), cS.ageRangeV(1)) : cS.ageRangeV(2);

      modelWageV  = model_ascM(ageRangeV, iSchool, ic);
      dataWageV   = data_ascM(ageRangeV, iSchool, ic);
      wtV         = wt_ascM(ageRangeV, iSchool, ic);
      
      idxV = find(wtV > 0  &  dataWageV ~= cS.missVal  &  modelWageV ~= cS.missVal);
      ssd_scM(iSchool, ic) = sum(wtV(idxV) .* (dataWageV(idxV) - modelWageV(idxV)) .^ 2);
   end
end      

dev = sum(ssd_scM(:));


end