function t_ojt_tech_so1(gNo, setNo)
% Test OJT technology
% --------------------------------------

close;
cS = const_so1(gNo, setNo);

pAlpha = 0.4;
pBeta  = pAlpha;
ddh = 0.04;
pProduct = 0.5;



% *********  Test that l(h') is convex
if 01
   n = 50;
   hPrimeV = linspace(1, 2, n);
   hV = 1;
   l2V = ojt_tech_inv_so1(hPrimeV, hV, pProduct, pAlpha, pBeta, ddh);
   
   plot(hPrimeV, l2V, 'ro-');
   xlabel('hPrime');
   title('Study time');
   pause;
   close; 
end


% *********  Test derivative w r to study time
if 01
   n = 5;
   hV = linspace(1, 2, n);
   lV = linspace(0.1, 0.9, n);
   dl = 1e-4;
   
   [hPrimeV, GlV] = ojt_tech_so1(hV, lV, pProduct, pAlpha, pBeta, ddh);
   hPrime2V = ojt_tech_so1(hV, lV + dl,  pProduct, pAlpha, pBeta, ddh);
   
   GlApproxV = (hPrime2V - hPrimeV) ./ dl;
   devV = GlApproxV ./ GlV - 1;
   
   fprintf('max deviation from Gl: %6.2f \n',  max(abs(devV)));
end


% **********  Test inverse
if 01
   n = 5;
   hV = linspace(1, 2, n)';
   lV = linspace(0.1, 0.9, n)';


   hPrimeV = ojt_tech_so1(hV, lV, pProduct, pAlpha, pBeta, ddh);

   l2V = ojt_tech_inv_so1(hPrimeV, hV, pProduct, pAlpha, pBeta, ddh);

   if max(abs(lV - l2V)) > 1e-5
      disp('*****  OJT tech does not invert');
      keyboard;
   else
      disp('OJT tech inverts');
   end
end

end