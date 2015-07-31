function t_ge_technology_so1(gNo, setNo)

cS = const_so1(gNo, setNo);
cS.dbg = 111;

LV = linspace(0.3, 0.5, cS.nSchool)';
wtV = linspace(0.4, 0.3, cS.nSchool)';
rhoCG = 0.5;
rhoHS = 0.4;


[mpV, Y] = ge_technology_so1(LV, wtV, rhoHS, rhoCG, cS);


% Test that doubling all weights multiplies all marginal products by same factor
if 1
   [mp2V, Y2] = ge_technology_so1(LV, 2 * wtV, rhoHS, rhoCG, cS);
   if max(abs(mp2V ./ mpV - 2)) > 1e-4
      disp('Scaling unexpected');
      keyboard;
   end
end


%% Test derivatives
dL = 1e-4;
for iSchool = 1 : cS.nSchool
   L2V = LV;
   L2V(iSchool) = L2V(iSchool) + dL;
   [mp2V, Y2] = ge_technology_so1(L2V, wtV, rhoHS, rhoCG, cS);

   mpTrue = (Y2 - Y) ./ dL;
   fprintf('iSchool: %i    mp: %6.4f    true: %6.4f    diff: %6.4f \n', ...
      iSchool,  mpV(iSchool), mpTrue, mpTrue - mpV(iSchool));
end




%% Test recovery of weights

wt2V = ge_weights_so1(LV, mpV, rhoHS, rhoCG, cS);

fprintf('Deviation from weights: \n');
fprintf('%10.3f',  wt2V - wtV);
fprintf('\n');


end