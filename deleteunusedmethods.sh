WEBAPP_PATH=~/projects/bisnow.com
VIEW_PATH="$WEBAPP_PATH/resources/views/admin"
CONTROLLERS_PATH="$WEBAPP_PATH/app/Http/Controllers"

rg -F "@UNUSED DELETE" "$CONTROLLERS_PATH" -l -c --no-heading  --color never | \
awk -F':' '{print $1 " " $2}' | \
while read -r path matches; do
    echo "$matches matches on $path"
    for ((i=1; i<=matches; i++)); do
        LINE_NUMBER=$(rg -F "@UNUSED DELETE" "$path" -n --no-heading  --color never -o | head -n 1 | awk -F':' '{print $1}')
        echo "Deleting line $line on $path"
        nvim +$LINE_NUMBER -c "normal! Vj%d" -c "wq" "$path"
    done
done
