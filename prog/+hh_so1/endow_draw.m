function [abil_icM, h1_icM, iq_icM, iqPct_icM] = endow_draw(paramS, cS)
% Draw endowments: ability and h1
%{
h1:
   Adjust mean of each cohort. Multiply by exp(paramS.meanLogH1V(iCohort))

%}

% Random seed -- must be set for all cohorts jointly
rng(32);

nSim = cS.gS.nSim;
nc = cS.nCohorts;

% Log Ability. Normal(0,1)
%  Exactly match mean and std
abil_icM = random_lh.randn_exact(zeros(nc, 1), ones(nc, 1), nSim, 3, cS.dbg);

if cS.dbg > 10
   validateattributes(abil_icM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', [nSim, nc]})
end

% h1 - log normal
%  Adjust mean of each cohort. Multiply by exp(paramS.meanLogH1V(iCohort))
%  Weights induce correlation with ability and preferences
%  Scale hHatV to be std Normal
% hhStd = (paramS.wtHA .^ 2 + 1) .^ 0.5;
% hHatM = (paramS.wtHA .* randn_exact(zeros(nc, 1), ones(nc, 1), nSim, 3, cS.dbg) +  ...
%    randn_exact(zeros(nc, 1), ones(nc, 1), nSim, 3, cS.dbg)) ./ hhStd;
hHatM = matrix_lh.scale(paramS.wtHA .* randn(nSim, nc)  +  randn(nSim, nc),  0, 1, cS.dbg);
h1_icM = double(exp(paramS.h1Std .* hHatM));  

if cS.dbg > 10
   validateattributes(h1_icM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
      'size', [nSim, nc]})
end



%%  IQ

iq_icM = [];
iqPct_icM = [];

if cS.gS.hasIQ == 1
   %  Scale such that stdIq is noise to signal ratio
   stdIq = (paramS.wtIQa .^ 2 + (1 - paramS.wtIQa) .^ 2) .^ 0.5;
   iq_icM = double( (paramS.wtIQa .* randn(nSim,nc)  +  (1 - paramS.wtIQa) .* randn(nSim,nc)) ./ stdIq  ...
      +  paramS.stdIq .* randn(nSim, nc) );
   % Make standard normal (it is already normal)
   stdV = std(iq_icM);
   iq_icM = iq_icM ./ (ones([nSim,1]) * stdV(:)');

   % Make IQ percentiles
   iqPct_icM = zeros([nSim, cS.nCohorts]);
   if cS.gS.tgIq > 0
      error('not updated'); 
      for ic = 1 : cS.nCohorts
         iqPct_icM(:,ic) = pct_assign_lh(iq_icM(:,ic), [], cS.dbg);
      end

      if cS.dbg > 10
         if ~v_check(iqPct_icM, 'f', [nSim, cS.nCohorts], 0, 1, [])
            error_so1('Invalid');
         end
      end
   end
end



end