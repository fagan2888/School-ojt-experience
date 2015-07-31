function t_cs_data_so1(gNo, setNo)

cS = const_so1(gNo, setNo);
cS.dbg = 111;
nSim = cS.gS.nSim;

indLogWage_iascM = rand([nSim, cS.ageRetire, cS.nSchool, cS.nCohorts]);
pSchool_iscM = rand([nSim, cS.nSchool, cS.nCohorts]);
indLogWageSS_iascM = rand([nSim, cS.ageRetire, cS.nSchool, 2]);
pSchoolSS_iscM = rand([nSim, cS.nSchool, 2]);

dataWt_asM = rand([cS.ageRetire, cS.nSchool]);
yearV = cS.wageYearV(1) : cS.wageYearV(end);
ageMin = 30;
ageMax = 50;


[logWageM, wtM] = cs_data_so1(indLogWage_iascM, pSchool_iscM, indLogWageSS_iascM, pSchoolSS_iscM, ...
   dataWt_asM, yearV, ageMin, ageMax, cS);



%% Check that cohort obs are in right place

for ic = 1 : cS.nCohorts
   for iSchool = 1 : cS.nSchool
      for age = ageMin : ageMax
         year1 = year_from_age_so(age, cS.bYearV(ic));
         yrIdx = find(year1 == yearV);
         if ~isempty(yrIdx)
            wInV = indLogWage_iascM(:,age,iSchool,ic);
            %pInV = pSchool_iscM(:,iSchool,ic);
            wOutV = logWageM(:,age,iSchool,yrIdx);
            %pOutV = wt
            if any(abs(wInV - wOutV) > 1e-6)
               error_so1('Discrepancy');
            end
         end         
      end
   end
end


for iSS = 1 : 2
   if iSS == 1
      bYear = cS.bYearLbV(1) - 1;
   else
      bYear = cS.bYearUbV(cS.nCohorts) + 1;
   end
   
   for iSchool = 1 : cS.nSchool
      for age = ageMin : ageMax
         year1 = year_from_age_so(age, bYear);
         yrIdx = find(year1 == yearV);
         if ~isempty(yrIdx)
            wInV = indLogWageSS_iascM(:,age,iSchool,iSS);
            %pInV = pSchool_iscM(:,iSchool,ic);
            wOutV = logWageM(:,age,iSchool,yrIdx);
            %pOutV = wt
            if any(abs(wInV - wOutV) > 1e-6)
               error_so1('Discrepancy');
            end
         end         
      end
   end
end


end