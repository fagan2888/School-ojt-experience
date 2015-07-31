function symS = symbols
% Define symbols for preamble and figure formatting


%% General notation

symS.pYear = 't';



%% Demographics

symS.age = 'a';
symS.birthYear = 'c';
symS.lifeSpan = 'T';
symS.tEndow = '\ell';


%% Endowments

symS.stdIq = '\sigma_{IQ}';



%% Schooling

% Durations
symS.sDuration = 'T_{s}';
% Preference shocks at college entry
symS.prefScale = '\gamma';
symS.prefShockEntry = '\eta';
% Mean pref for work as HSG (to get college entry rate right)
symS.prefShockEntryMean = '\bar{\eta}';

% Function that governs high school graduation (as function of ability)
symS.probHSG = '\pi';
% Function that governs college graduation
symS.probCG = '\phi';


%% OJT

symS.ability = 'x';
% Std dev of effective abilities
symS.abilScale = '\theta';
symS.pProduct = 'A';
symS.h1Std = '\sigma_{h1}';


%% Work

symS.sPrice = 'w';
symS.earn = 'y';
% Individual efficiency units supplied
symS.effUnits = 'e';


%% Aggregates

% Labor supply in efficiency units (aggregate)
symS.lSupply = 'H';
% Aggregate hours in a cell (data)
symS.aggrHours = 'L';
% Neutral productivity
symS.neutralProd = 'A';



end