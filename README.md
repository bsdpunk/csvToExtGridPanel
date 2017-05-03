# csvToExtGridPanel
converts csv to Ext Grid Panel stuff

You may need to remove commas, and quotation marks from your CSV which can be done using, this bash function.
```
function rqc () { awk -F'"' -v OFS='' '{ for (i=2; i<=NF; i+=2) gsub(",", "", $i) } 1' $@ | gsed 's/"//g' ;}
rqc old.csv > new.csv
```
