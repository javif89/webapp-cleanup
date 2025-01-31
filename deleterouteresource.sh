WEBAPP_PATH=~/projects/bisnow.com
CONTROLLERS_PATH="$WEBAPP_PATH/app/Http/Controllers"
ROUTES_FILE="$WEBAPP_PATH/routes/admin/admin.php"

# Delete any Route::resource for which
# the controller no longer exists

grep "Route::resource" "$ROUTES_FILE" | \
grep -v "//" > routeresource.txt

cat routeresource.txt | \
rg "\w+Controller" -o --color never | \
awk '{print $0 ".php"}' > routeresourcecontrollers.txt

cat routeresourcecontrollers.txt | while read -r controllerName; do
    if find "$CONTROLLERS_PATH" -name "$controllerName" -type f | grep -q .; then
        echo "1 $controllerName"
    else
        echo "0 $controllerName"
    fi
done | awk '$1 == 0 {print $2}' | \
sed 's|.php||' | \
grep -f - routeresource.txt | \
grep -v -f - "$ROUTES_FILE" > admin.php.new

mv admin.php.new "$ROUTES_FILE"
