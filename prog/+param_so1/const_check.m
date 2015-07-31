function const_check(cS)
% Check struct with constants
% --------------------------------


%% Model params

% if any(cS.alphaMaxV > 0.99)
%    error_so1('Too high alphaMax', cS);
% end



%% Implied params

% if ~v_check(cS.spNodeZeroV, 'i', [], 1, length(cS.spNodeV), [])
%    error_so1('Invalid');
% end
% if cS.spNodeZeroV(2:end) <= cS.spNodeZeroV(1:(end-1))
%    error_so1('Invalid');
% end
   

end