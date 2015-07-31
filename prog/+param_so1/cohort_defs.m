function [bYearV, bYearWindow, byShowV, byShow4V, cohStrV, nThetaNodes] = cohort_defs(cohDefStr)
% Cohort definitions
%{
IN
   cohDefStr
      default
      annual
      bowlus

OUT
   byShowV
      indices of cohorts to show
      best to omit first 1 or 2 which are mostly out of sample
%}
% ------------------------------------

if strcmp(cohDefStr, 'default')
   % Cohorts
   bYearV = (1935 : 3 : 1969)';
   % Window of +/- bYearWindow years
   bYearWindow = 1;
   % Show these 6 cohorts
   byShowV = 3 : 2 : length(bYearV);   % [1:3, 4 : 2 : length(bYearV)];
   % Show these 4 cohorts
   byShow4V = byShowV(2 : 5);
   % No of theta spline nodes
   nThetaNodes = 6;

elseif strcmp(cohDefStr, 'annual')
   % All Cohorts
   bYearV = (1935 : 1 : 1969)';
   % Window of +/- bYearWindow years
   bYearWindow = 0;
   % Show these cohorts
   byShowV = round(linspace(1, find(bYearV == 1965), 8))';
   byShow4V = byShowV(2 : 5);
   % No of theta spline nodes
   nThetaNodes = 6;

elseif strcmp(cohDefStr, 'bowlus')
   % Bowlus / Robinson
   bYearV = (1934 : 3 : 1964)';
   bYearWindow = 1;
   % Show these cohorts
   byShowV = [1:3, 4 : 2 : length(bYearV)];
   byShow4V = byShowV(2 : 5);
   % No of theta spline nodes
   nThetaNodes = 6;
   
elseif strcmpi(cohDefStr, 'long')
   % Cohorts
   bYearV = (1920 : 3 : 1971)';
   % Window of +/- bYearWindow years
   bYearWindow = 1;
   % Show these 6 cohorts
   byShowV = round(linspace(5, length(bYearV)-2, 6));
   % Show these 4 cohorts
   byShow4V = byShowV(2 : 5);
   % No of theta spline nodes
   nThetaNodes = 10;   
   
else
   error('Invalid');
end

bYearV = bYearV(:);
byShowV = byShowV(:);
byShow4V = byShow4V(:);

nBy = length(bYearV);

% Descriptive strings
cohStrV = cell([nBy, 1]);
for iBy = 1 : nBy
   cohStrV{iBy} = sprintf('%i', bYearV(iBy));
end


end