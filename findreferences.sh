WEBAPP_PATH=~/projects/bisnow.com

echo "UNUSED ROUTE REFERENCES"
cat unusedref.txt | \
xargs -I{} rg '{}' $WEBAPP_PATH --heading -o 

echo "DELETED METHODS"
rg '@UNUSED DELETE' $WEBAPP_PATH -l
