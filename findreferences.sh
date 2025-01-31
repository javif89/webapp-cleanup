WEBAPP_PATH=~/projects/bisnow.com

echo "UNUSED ROUTE REFERENCES"
cat unusedref.txt | \
# Find all the files that contain references to unused routes
xargs -I{} rg "{}" "$WEBAPP_PATH" --color never --no-heading --line-number -o | \
awk -F':' '{print $1 " " $2}' | \
while read -r path line; do
    echo "Marking line $line on $path"
    nvim -n +$line +"s/\(.*\)/\1 @UNUSEDREF" +wq "$path"
done
