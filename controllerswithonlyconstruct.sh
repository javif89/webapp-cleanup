WEBAPP_PATH=~/projects/bisnow.com
VIEW_PATH="$WEBAPP_PATH/resources/views/admin"
CONTROLLERS_PATH="$WEBAPP_PATH/app/Http/Controllers"

# Get the controllers with only one public function
rg -F "public function" "$CONTROLLERS_PATH" -l -c --no-heading  --color never | \
# Get the controllers with only one public function
awk -F':' '{print $2 " " $1}' | awk '$1 == 1 { print $2 }' | \
# Check if the public function is __construct. If it is we'll delete it
while read -r controllerPath; do
    COUNT=$(rg -F "public function __construct" "$controllerPath" -l -c --no-heading)
    if [[ $COUNT -eq 1 ]]; then
        echo "Deleting $controllerPath"
        rm "$controllerPath"
    fi
done
