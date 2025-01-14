WEBAPP_PATH=~/projects/bisnow.com
VIEW_PATH="$WEBAPP_PATH/resources/views/admin"
CONTROLLERS_PATH="$WEBAPP_PATH/app/Http/Controllers"

find "$VIEW_PATH" -type f | \
sed "s|$WEBAPP_PATH/resources/views/||g" | \
sed 's|.blade.php||g' | grep -v "partials" - > views_slash.txt 

find "$VIEW_PATH" -type f | \
sed "s|$WEBAPP_PATH/resources/views/||g" | \
sed 's|.blade.php||g' | \
sed 's|/|.|g' | grep -v "partials" - > views_dot.txt 

find "$VIEW_PATH" -type f | \
sed "s|$WEBAPP_PATH/resources/views/||g" | \
sed 's|.blade.php||g' | grep -v "partials" - > views_slash.txt 

# Find views that are actually used
cat views_slash.txt views_dot.txt | while read -r path; do
    rg "$path" "$CONTROLLERS_PATH" "$VIEW_PATH" --heading -l | \
    echo "$(wc -l | tr -d '    ' | tr -d '\t') $path"
done | awk '$1 > 0' | awk '{print $2}' | sed 's|/|.|g' | sort | uniq > usedviews.txt

# Get the views that are unused
grep -v -F -f usedviews.txt views_dot.txt | \
sed 's|\.|/|g' | \
sed 's|admin/||' | \
awk -v pth="$VIEW_PATH" '{print pth"/"$0".blade.php"}' | \
xargs rm
