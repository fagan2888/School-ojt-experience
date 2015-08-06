function cohort_school(gNo)
% Make: fraction in each school group by cohort
%{
Checked: 2014-mar-21
%}
% ---------------------------------------------

fprintf('Computing cohort school fractions \n');
cS = const_data_so1(gNo);
varS = param_so1.var_numbers;
nBy = length(cS.demogS.bYearV);

loadS = output_so1.var_load(varS.vBYearSchoolAgeStats, cS);

sFracM = zeros([cS.nSchool, nBy]);
for iBy = 1 : nBy
   % Mass by [school, age]
   %  Using all persons (even without wages)
   mass_stM = loadS.mass_csauM(iBy, :, cS.schoolAgeRangeV(1) : cS.schoolAgeRangeV(2), cS.dataS.iuCpsAll);
   mass_stM = max(0, squeeze(mass_stM));
   sMassV = sum(mass_stM, 2);
   if length(sMassV) ~= cS.nSchool
      error('Invalid');
   end
   sFracM(:, iBy) = sMassV ./ sum(sMassV);
end

validateattributes(sFracM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>', 0.02, '<', 0.98, ...
   'size', [cS.nSchool, nBy]});

output_so1.var_save(sFracM, varS.vCohortSchool, cS);

end