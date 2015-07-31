function outS = ojt_solve(h1CohortV, abilV, skillPrice_asM, iCohort, paramS, cS)
% Solve OJT part of household problem
%{
One cohort, all school groups

IN:
   abilV
      NOT scaled by theta
   h1CohortV
      at start of life
   skillPrice_asM
      skill prices by [phys age, school]

OUT:
   hM(ind, physical age, school)
      individual age profiles
   pvLtyAge1M(ind, school)
      present value of lifetime earnings, discounted to age 1
%}

%% Input check

nSim = length(abilV);
ageRetire = cS.ageRetire;

if cS.dbg > 10
   validateattributes(h1CohortV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
      'size', [nSim,1]})
   validateattributes(abilV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      '>', -5,  '<', 5,  'size', [nSim,1]})
   validateattributes(skillPrice_asM(cS.age1:end, :), {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
      'size', [cS.ageRetire - cS.age1 + 1, cS.nSchool]})
end


%% Main

outS.pvLtyAge1_isM = zeros([nSim, cS.nSchool]);
outS.hWorkStart_isM = zeros([nSim, cS.nSchool]);
outS.h_itsM = zeros([nSim, ageRetire, cS.nSchool]);
outS.sTime_itsM = zeros([nSim, ageRetire, cS.nSchool]);
outS.wage_itsM = zeros([nSim, ageRetire, cS.nSchool]);

for iSchool = 1 : cS.nSchool
   workAgeV = cS.workStartAgeV(iSchool) : cS.ageRetire;
   
   % Compute h at start of work
   outS.hWorkStart_isM(:,iSchool) = hh_so1.school_tech(h1CohortV, abilV, iSchool, iCohort, paramS, cS);
   
   % Make a Ben-Porath structure
   %  The productivity parameter does not matter
   bpS = BenPorathLH(skillPrice_asM(workAgeV, iSchool), paramS.tEndow_ascM(workAgeV, iSchool, iCohort), ...
      paramS.alphaV(iSchool), paramS.ddhV(iSchool), 1, paramS.R, paramS.trainTimeMax, cS.hMax);

   % Productivity parameters
   pProductV = hh_so1.ojt_productivity(abilV, iSchool, iCohort, paramS, cS);

   % Solve OJT problem, using generic Ben-Porath routine
   [outS.h_itsM(:,workAgeV,iSchool), outS.sTime_itsM(:,workAgeV,iSchool), outS.wage_itsM(:,workAgeV,iSchool), ...
      earn_itM] = bpS.solve(outS.hWorkStart_isM(:, iSchool), pProductV, cS.dbg);
   outS.earnM(:,workAgeV,iSchool) = earn_itM;

   % Present value of lifetime earnings, discounted to first work age
   T = length(workAgeV);
   pvLtyV = sum(earn_itM .* (ones([nSim,1]) * ((1/paramS.R) .^ (0 : T-1))), 2);
   % Discount to age 1
   outS.pvLtyAge1_isM(:, iSchool) = pvLtyV .* ((1 / paramS.R) ^ (workAgeV(1) - cS.age1 + 1));
end


%%  Self-test

validateattributes(outS.pvLtyAge1_isM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive'})

if cS.dbg > 10
   validateattributes(outS.sTime_itsM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>=', 0})
   validateattributes(outS.wage_itsM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>=', 0})
end


end