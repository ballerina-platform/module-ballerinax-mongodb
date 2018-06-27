#bin/bash

read -p "Enter Ballerina home: "  ballerina_home

if [ ! -e "$ballerina_home/bin/ballerina" ]
then
    echo "Incorrect Ballerina Home provided!"
    exit 1
fi

ballerina_lib_location=$ballerina_home/bre/lib/
ballerina_balo_location=$ballerina_home/lib/repo/
version=0.5.6-SNAPSHOT
package_name=mongodb

if [ ! -e "$ballerina_lib_location/wso2-$package_name-package-$version.jar" ]
then
   if [ ! -e "$ballerina_balo_location/wso2/$package_name/0.0.0/$package_name.zip" ]
   then
   echo "MongoDB package is not installed!"
   exit 0
   fi
fi

rm $ballerina_lib_location/wso2-$package_name-package-$version.jar

if [ $? -ne 0 ]; then
    echo "Error occurred while deleting dependencies from $ballerina_lib_location"
    echo "Please manually delete $ballerina_lib_location/wso2-$package_name-package-$version.jar"
fi    

rm -r $ballerina_balo_location/wso2/$package_name/0.0.0

if [ $? -ne 0 ]; then
    echo "Error occurred while deleting $package_name balo from $ballerina_balo_location"
    echo "Please manually delete $ballerina_balo_location/wso2/$package_name/0.0.0 directory"
else
    echo "Successfully uninstalled MongoDB package!"    
fi    
