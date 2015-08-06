function cS = skill_price_const(cInS)
% Constants relating to skill prices
%{
OUT
   spYearV :: 2x1
      skill price years
   spNodeIdxV :: nsp x 1
      index values of spline nodes to be calibrated
%}

cS = cInS;


%% Skill price year range

spNodeGap = 8;

% Years for which skill prices must be computed
%  length 2!
%  easiest to keep this the same for all s
spYear1 = min(cS.demogS.workYear1_scM(:));
spYear2 = max(cS.demogS.workYear2_scM(:));
spS.spYearV = [spYear1; spYear2];
nsp = spS.spYearV(end) - spS.spYearV(1) + 1;
spS.nsp = nsp;


% ******  Nodes for skill price splines

% No of skill price nodes
nNodes = max(7, round(nsp ./ spNodeGap));

spS.spNodeIdxV = round(linspace(1, nsp, nNodes));


% % No of nodes before wage year 1
% n1 = round((cS.wageYearV(1) - spS.spYearV(1)) ./ nsp .* nNodes);
% % No of nodes after last wage year
% n3 = round((spS.spYearV(end) - cS.wageYearV(end)) ./ nsp .* nNodes);
% % No of nodes in between
% n2 = nNodes - n1 - n3;
% node1V = round(linspace(spS.spYearV(1), cS.wageYearV(1), n1));
% node2V = round(linspace(cS.wageYearV(1), cS.wageYearV(end), n2));
% node3V = round(linspace(cS.wageYearV(end), spS.spYearV(end), n3));
% spS.spNodeV = [node1V(1 : (end-1)), node2V, node3V(2:end)]';
% 
%    
% % These nodes are forced to 0
% spS.spNodeZeroV = [find(spS.spNodeV == cS.wageYearV(1)),  find(spS.spNodeV == cS.wageYearV(end))];
% if spS.spOutOfSample == spS.spOutOfSampleOnTrend
%    % 1st / last years must be on trend. spline = 0
%    spS.spNodeZeroV = [1, spS.spNodeZeroV, length(spS.spNodeV)];
% end
% 
% % Year for which level is set
% spS.spLevelYrIdx = 5;
% spS.spLevelYear = round(spS.spNodeV(spS.spLevelYrIdx));


%%  Parameters to be calibrated

if strcmpi(cS.spSpecS.inSampleType, 'sbtc')
   nNodes = length(spS.spNodeIdxV);
   for iSchool = 1 : cS.nSchool
      nameStr = sprintf('logWNode_s%iV', iSchool);
      symbolStr = ['logWNode', cS.schoolLabelV{iSchool}];
      cS.pvector = cS.pvector.change(nameStr,  symbolStr, 'Skill price nodes', ...
         zeros(nNodes, 1), -3 * ones(nNodes, 1),  4 * ones(nNodes, 1),  cS.calBase);
   end
   
elseif strcmpi(cS.spSpecS.inSampleType, 'dataWages')
   % Calibrate a single level parameter for each s
   cS.pvector = cS.pvector.change('spLevel_sV',  'spLevel', 'Skill price levels', ...
      zeros(cS.nSchool, 1), -3 * ones(cS.nSchool, 1),  3 * ones(cS.nSchool, 1),  cS.calBase);
else
   error_so1('Invalid', cS);
end




cS.spS = spS;

end