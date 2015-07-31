function gS = grids_so1(gridNo, gNo)
% Define settings for grids
%{
IN:
   gridNo
      cS.gridAlpha etc
OUT:
   gridStr
      e.g. alpha; used for prefixes etc
   setNoV
      sets in that group
   xValueV
      value that gets varied
   xLabelStr
      descriptive string of that variable (for figure titles)
%}
% ---------------------------------------

cS = const_so1(gNo, 1);
gS.gridNo = gridNo;

if all(gridNo ~= cS.gridNoV)
   error_so1('Invalid gridNo', cS);
end

if gridNo == cS.gridAlpha
   gS.gridStr = 'alpha';
   gS.setNoV  = cS.setAlphaV;
   gS.xLabelStr = '$\alpha$';
   gS.xValueV   = cS.alphaGridV;
   
% elseif gridNo == cS.grid2Alpha
%    gS.gridStr = 'alpha2';
%    gS.setNoV  = cS.set2AlphaV;
%    gS.xLabelStr = '$\alpha$';
%    gS.xValueV   = cS.alphaGridV;
   
% elseif gridNo == cS.grid1Alpha
%    gS.gridStr = 'alpha1';
%    gS.setNoV  = cS.set1AlphaV;
%    gS.xLabelStr = '$\alpha$';
%    gS.xValueV   = cS.alphaGridV;

elseif gridNo == cS.gridAlphaHSG
   gS.gridStr = 'alphahsg';
   gS.setNoV  = cS.setAlphaHSGV;
   gS.xLabelStr = '$\alpha_{HSG}$';
   gS.xValueV   = cS.alphaGridV;
   
elseif gridNo == cS.gridAlphaCG
   gS.gridStr = 'alphacg';
   gS.setNoV  = cS.setAlphaCGV;
   gS.xLabelStr = '$\alpha_{CG}$';
   gS.xValueV   = cS.alphaGridV;
   
elseif gridNo == cS.gridPrefScale
   gS.gridStr = 'prefscale';
   gS.setNoV  = cS.setPrefScaleV;
   gS.xLabelStr = '$\pi$';
   gS.xValueV   = cS.prefScaleGridV;
   
elseif gridNo == cS.gridGH1
   gS.gridStr = 'gh1';
   gS.setNoV  = cS.setGH1V;
   gS.xLabelStr = '$g_{h1}$';
   gS.xValueV   = cS.gH1GridV;
   
% elseif gridNo == cS.gridGCollPrem
%    gS.gridStr = 'gcwp';
%    gS.setNoV  = cS.setGCollPremV;
%    gS.xLabelStr = '$\Delta w_{CG} - \Delta w_{HSG}$';
%    gS.xValueV   = cS.gCollPremGridV;

elseif gridNo == cS.gridGW2
   gS.gridStr = 'gw2';
   gS.setNoV  = cS.setGW2V;
   gS.xLabelStr = '$\Delta w_{HSG}$';
   gS.xValueV   = cS.gW2GridV;
   
elseif gridNo == cS.gridGW4
   gS.gridStr = 'gw4';
   gS.setNoV  = cS.setGW4V;
   gS.xLabelStr = '$\Delta w_{CG}$';
   gS.xValueV   = cS.gW4GridV;

elseif gridNo == cS.gridDdhHSG
   gS.gridStr = 'ddh_hsg';
   gS.setNoV  = cS.setDdhHSGV;
   gS.xLabelStr = '$\delta_{HSG}$';
   gS.xValueV   = cS.ddhGridV;

elseif gridNo == cS.gridDdhCG
   gS.gridStr = 'ddh_cg';
   gS.setNoV  = cS.setDdhCGV;
   gS.xLabelStr = '$\delta_{CG}$';
   gS.xValueV   = cS.ddhGridV;
   
% elseif gridNo == cS.gridQPersistence
%    gS.gridStr = 'rho';
%    gS.setNoV  = cS.setQPersistenceV;
%    gS.xLabelStr = '$\rho$';
%    gS.xValueV   = cS.qPersGridV;   

% elseif gridNo == cS.gridTheta
%    gS.gridStr = 'theta';
%    gS.setNoV  = cS.setThetaV;
%    gS.xLabelStr = '$\theta$';
%    gS.xValueV   = cS.thetaGridV;   
   
elseif gridNo == cS.gridTest
   gS.gridStr  = 'test';
   gS.setNoV   = cS.setTestV;
   % Does not matter what is on x axis
   gS.xLabelStr = 'set';
   gS.xValueV   = (1 : length(gS.setNoV))';   

elseif gridNo == cS.gridGCwp
   gS.gridStr  = 'gCollprem';
   gS.setNoV   = cS.setGCwpV;
   % Does not matter what is on x axis
   gS.xLabelStr = 'g(cwp)';
   gS.xValueV   = cS.gCwpGridV;   

else
   error_so1('Invalid gridNo', cS);
end
   
% This is where mat files are saved
gS.saveNo = gS.setNoV(1);


%% Directories

fs = filesep;
gS.outDir = [cS.soDir, 'out', fs, sprintf('g%02i', gNo), fs, 'grid_', gS.gridStr, fs];


end