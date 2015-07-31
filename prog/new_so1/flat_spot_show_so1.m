function flat_spot_show_so1(saveFigures, gNo, setNo)
% Show flat spot wages. Model and data
%{
Also show skill prices
%}
% --------------------------------------------------

cS = const_so1(gNo, setNo);

dataS = var_load_so1(cS.vFlatSpotWages, [], gNo, cS.dataSetNo);
modelS = var_load_so1(cS.vFlatSpotModel, cS);
modelYearV = cS.wageYearV(1) : cS.wageYearV(end);

simStatS = var_load_so1(cS.vSimStats, cS);


%% Model
if 1
   fig_new_so(saveFigures);
   hold on;
   
   for iSchool = 1 : cS.nSchool
      idxV = find(modelS.flatWageM(iSchool,:) ~= cS.missVal);
      plot(modelYearV(idxV), modelS.flatWageM(iSchool, idxV), cS.lineStyleDenseV{iSchool}, 'color', cS.colorM(iSchool,:));
   end
   
   hold off;
   xlabel('Year');
   ylabel('Log wage');
   legend(cS.schoolLabelV, 'location', 'south', 'orientation', 'horizontal');
   figure_format_so(gca);
   save_fig_so('flat_spot_model', saveFigures, [], cS);
end


%% Model vs data
if 1
   for iSchool = 1 : cS.nSchool
      fig_new_so(saveFigures);
      hold on;
      legendV = cell([3,1]);
      iLine = 0;
      
      iLine = iLine + 1;
      legendV{iLine} = 'Model';
      idxV = find(modelS.flatWageM(iSchool,:) ~= cS.missVal);
      modelV = modelS.flatWageM(iSchool, idxV);
      plot(modelYearV(idxV), modelV - modelV(1), cS.lineStyleDenseV{iLine}, 'color', cS.colorM(iLine,:));
      
      iLine = iLine + 1;
      legendV{iLine} = 'Data';
      idxV = find(dataS.logWageM(iSchool,:) ~= cS.missVal);
      dataV = dataS.logWageM(iSchool, idxV);
      plot(dataS.yearV(idxV), dataV - dataV(1), cS.lineStyleDenseV{iLine}, 'color', cS.colorM(iLine,:));
      
      iLine = iLine + 1;
      legendV{iLine} = 'Skill prices';
      idxV = (modelYearV(1) - cS.spS.spYearV(1)) + (1 : length(modelYearV));
      spV = simStatS.skillPrice_stM(iSchool, idxV);
      plot(modelYearV, spV - spV(1), cS.lineStyleDenseV{iLine}, 'color', cS.colorM(iLine,:));
      
      hold off;
      xlabel('Year');
      ylabel('Log wage');
      legend(legendV(1 : iLine), 'location', 'south', 'orientation', 'horizontal');
      figure_format_so(gca);
      save_fig_so(['flat_spot_', cS.schoolSuffixV{iSchool}], saveFigures, [], cS);
   end
   
end


end