# Translate from old to new so1 code

# perl -pi -w -e 's/var\_load\_so1/output\_so1.var\_load/g' $1
# perl -pi -w -e 's/var\_save\_so1/output\_so1.var\_save/g' $1

perl -pi -w -e 's/save\_fig\_so1/output\_so1.fig\_save/g' $1
perl -pi -w -e 's/fig\_format\_so1/output\_so1.fig\_format/g' $1
perl -pi -w -e 's/fig\_new\_so1/output\_so1.fig\_new/g' $1

perl -pi -w -e 's/save\_fig\_so/output\_so1.fig\_save/g' $1
perl -pi -w -e 's/figure\_format\_so/output\_so1.fig\_format/g' $1
perl -pi -w -e 's/fig\_new\_so/output\_so1.fig\_new/g' $1

perl -pi -w -e 's/cS.lineStyle/figS.lineStyle/g' $1
perl -pi -w -e 's/cS.colorM/figS.colorM/g' $1

perl -pi -w -e 's/cS.v/varS.v/g' $1