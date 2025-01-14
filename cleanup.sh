#!/bin/bash

# Config
WEBAPP_PATH=~/projects/bisnow.com
ROUTES_FILE="$WEBAPP_PATH/routes/admin/admin.php"

function getroutes() {
    php $WEBAPP_PATH/artisan route:list | \
    tail -n +4 | \
    awk '{
        gsub(/[A-Z]+\|/, "x"); 
        gsub(/\|/, ","); 
        gsub(/[ ]+/, ""); 
        print
    }' | \
    awk -F',' '{
        split($6, x, "@"); 
        print $4" "x[1]" "x[2]
    }' | sort | grep -E "admin/(cache|disclaimers|email|entity)"
}

# Combine the usage data with the admin routes
function getrouteusage() {
    awk '
        NR==FNR{usage[$2]= $1; next}
        { 
            if($1 in usage) {print usage[$1] " " $1 " " $2 " " $3}
            else {print "0" " " $1 " " $2 " " $3}
        }
    ' <(cat routeusage.txt) <(getroutes) | sort -n
}

function getunusedroutes() {
    getrouteusage | \
    awk '{if($1 == 0) {print $2, $3, $4}}' | \
    sort
}

function trimcontrollernamespace() {
    while IFS= read -r line; do
        echo "$line" | sed 's|App\\Http\\Controllers\\||g'
    done
}

# Get any named unused routes and search
# for usages.
getunusedroutes | \
trimcontrollernamespace | \
awk '{print $2"@"$3}' | \
grep -f - $ROUTES_FILE | \
grep -Eo name\('.+'\) | \
grep -Eo \'.+\' > unusedref.txt

# Saved unused routes to a file
# so we can clean them up after
# the rest is done.
getunusedroutes | \
awk '{print $1}' | \
sed 's/{.*}/(\\\\{\\\\.\\\\+\\\\})+/g' >> unusedref.txt

# Format the unused routes for grep so that
# we can use it to delete them from the
# admin/admin.php routes file by
# searching for Controller@method
# We'll save the result to admin.php.new
# and move it after the rest of the
# process is complete.
getunusedroutes | \
trimcontrollernamespace | \
awk '{print $2"@"$3}' | \
grep -f - $ROUTES_FILE | \
awk '{gsub(/^[ \t]+|[ \t]+$/, ""); print}' | \
grep -v -f - $ROUTES_FILE > admin.php.new

# Mark the controller methods for
# deletion
getunusedroutes | \
awk '{print $2, $3}' | \
sed 's/App/app/g' | \
sed 's|\\|/|g' | \
awk '{print "~/projects/bisnow.com/"$1".php" "|" $2}' | \
sed 's|~|/Users/javierfeliz|g' > delete_methods.txt

while IFS='|' read -r filepath funcName; do
    sed -i '' "s|public function $funcName\(.*\)|/* @UNUSED DELETE */|g" "$filepath"
done < delete_methods.txt

echo "Deleting unused routes from admin.php"
# Finish up
mv admin.php.new $ROUTES_FILE
# rm delete_methods.txt

echo "Deleting controllers with no remaining methods"
# Get the controllers for which we deleted methods
cat delete_methods.txt | \
awk -F'|' '{ print $1 }' | \
sort | \
uniq > controllers_with_deleted_methods.txt 

# Find the controllers with deleted methods
# that no longer have any public functions
# left. We can delete them.
cat controllers_with_deleted_methods.txt | \
xargs rg 'public function' --heading -l > controllers_with_remaining_methods.txt 

# Delete the controllers that have no public methods left
grep -v -F -f controllers_with_remaining_methods.txt controllers_with_deleted_methods.txt | \
xargs rm

echo "Deleting unused methods from the controllers"
./deleteunusedmethods.sh

echo "Deleting unused views"
./findunusedviews.sh

echo "Unused route grep expressions output to:"
echo "unusedref.txt"
echo "run ./findreferences.sh to check"
# ./findreferences.sh
