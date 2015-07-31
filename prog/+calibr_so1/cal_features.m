function cal_features(cS)
% Show calibration features
% ---------------------------------------------


disp('----  Calibration features:');
disp(['  Description:  ', cS.setStr]);

%    if cS.prefScale < 0.1  &&  cS.gPrefScale == 0
%       disp('  Small psy cost');
%    end
%    if cS.calWtPA == 1
%       disp('  Psy cost correlated with ability');
%    elseif cS.wtPA == 0
%       disp('  Psy cost is independent of ability');
%    end

% if cS.gS.tgBetaIqExper > 0
%    disp('  Target IQ by experience');
% end
% if cS.tgSkewness > 0
%    disp('  Skewness targets');
% end


% for iSchool = 1 : cS.nSchool
%    if cS.calAlphaV(iSchool) == 0
%       fprintf('  alpha %i fixed at %4.2f \n',  iSchool, cS.alphaV(iSchool));
%    end
% end
% 
% % if cS.BetaEqualsAlpha == 1
% %    disp('  beta = alpha');
% % end
% 
% if cS.calWtPA == 0
%    fprintf('  wtPA fixed at %4.2f \n',  cS.wtPA);
% end
% if cS.calWtHA == 0
%    fprintf('  wtHA fixed at %4.2f \n',  cS.wtHA);
% end
% if cS.calGA == 0
%    fprintf('  g(A) fixed at %4.2f \n',  cS.gA);
% end


end