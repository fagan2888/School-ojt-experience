function ageV = age_from_year(bYearV, yearV, ageInBirthYear)
% Having this as a function ensures that age is always consistently defined
% ----------------------------------------------------

ageV = yearV - bYearV + ageInBirthYear;

end