function skill_price_node_set(gNo1, setNo1,  gNo2, setNo2)
% Using skill prices from gNo2/setNo2, set logWNode_sV in params of gNo1/setNo1

if ~input_lh.ask_confirm('Copy skill prices?', 'x')
   return
end

varS = param_so1.var_numbers;

% Load skill prices from gNo2
c2S = const_so1(gNo2, setNo2);
calS = var_load_so1(varS.vCalResults, c2S);
skillPrice_stM = calS.calDevS.skillPrice_stM;
clear c2S;


cS = const_so1(gNo1, setNo1);
if ~strcmpi(cS.spSpecS.inSampleType, 'sbtc')
   error('Only works when skill prices are spline');
end
paramS = param_load_so1(gNo1, setNo1);

for iSchool = 1 : cS.nSchool
   fieldStr = sprintf('logWNode_s%iV', iSchool);
   % Spline nodes = log skill prices at node points
   paramS.(fieldStr) = log(skillPrice_stM(iSchool, cS.spS.spNodeIdxV))';
end

var_save_so1(paramS, varS.vParams, cS);

end