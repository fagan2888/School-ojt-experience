function t_cohort_to_year_so1(gNo, setNo)

cS = const_so1(gNo, setNo);

bYearV = cS.demogS.bYearV;
yearV  = 1960 : 1990;

in_ascM = 1 + rand([cS.demogS.ageRetire, cS.nSchool, length(bYearV)]);

[outM, out2M] = cohort_to_year_so1(in_ascM, bYearV, yearV, cS);


for ic = 1 : length(bYearV)
   for iSchool = 1 : cS.nSchool
      for age1 = cS.demogS.workStartAgeV(iSchool) : cS.demogS.ageRetire
         year1 = year_from_age_so(age1, bYearV(ic));
         yrIdx = find(year1 == yearV);
         if ~isempty(yrIdx)
            if abs(in_ascM(age1, iSchool, ic) - out2M(age1, iSchool, yrIdx)) > 1e-5
               error_so1('Discrepancy');
            end
         end
      end
   end
end

end