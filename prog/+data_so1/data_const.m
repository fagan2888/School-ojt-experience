function dataS = data_const
% Data constants. Can be changed by gNo, setNo

% The universe dimension of the files copied from cpsearn
%  hard coded +++
dataS.iuCpsEarn = 2;    % only wage earners
dataS.iuCpsAll =  1;    % 'all'

% Must count this. Otherwise cannot use universe of 'all'
dataS.fracBusInc = 2/3;

% Give all cohorts the same hours profiles?
dataS.sameHoursAllCohorts = true;

end