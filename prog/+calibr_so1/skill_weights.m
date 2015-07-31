function [skillWeightTop_tlM, skillWeight_tlM] = skill_weights(lSupply_stM, skillPrice_stM, aggrProdFct, cS)
%{
IN
   aggrProdFct :: ces_nested_lh
      usually from paramS

OUT
   AV :: T x 1
      neutral productivities
   skillWeightTop_tlM :: T x 2
      top level skill weights (non CG aggregate vs CG)
   skillWeight_tlM :: T x nSchool
      within the non CG aggregate
      the last one (for CG) is 1
%}


T = size(lSupply_stM, 2);


%% Input check
if cS.dbg > 10
   if ~isa(aggrProdFct, 'ces_nested_lh')
      error('Unexpected production function');
   end
   validateattributes(lSupply_stM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
      'size', [cS.nSchool, T]})
   validateattributes(skillPrice_stM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
      'size', [cS.nSchool, T]})
end


%% Main

% Neutral productivities do not matter
[skillWeightTop_tlM, skillWeight_tlM] = aggrProdFct.factor_weights(ones(T,1), ...
   (lSupply_stM .* skillPrice_stM)',  lSupply_stM');


% Drop the skill weight on CG at the lower nest (it is 1 anyway)
% skillWeight_tlM(:, end) = [];

% % Neutral productivities
% AV = alphaTop_tsM(:, 1);


%% Output check

if cS.dbg > 10
   validateattributes(skillWeightTop_tlM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'positive', 'size', [T, 2]})
   validateattributes(skillWeight_tlM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'positive', 'size', [T, cS.nSchool]})
end

end