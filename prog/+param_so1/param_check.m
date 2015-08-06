function param_check(paramS, cS)
% Check parameters
% -------------------------------------------

% update later +++++
% if ~isequal(size(paramS.tEndow_ascM),  [cS.demogS.ageRetire, cS.nSchool, cS.nCohorts])
%    error_so1('Invalid size of time endowments', cS);
% end



% ********  Growth rates

if abs(paramS.gA) > 0.05
   error('Implausible gA');
end
if abs(paramS.gH1) > 0.05
   error('Implausible gH1');
end
if abs(paramS.gPrefScale) > 0.2
   error('Implausible gPrefScale');
end


% ********  Abilities

% if any(paramS.abilGridV < 1e-4)
%    error('Abilities too small');
% end



%% Skill prices

% update later +++++
% if ~v_check(paramS.logWNodeM, 'f', [cS.nSchool, length(cS.spNodeV) - length(cS.spNodeZeroV)], -5, 5, [])
%    error_so1('Invalid')
% end



end