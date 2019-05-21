#!/bin/bash
# ---------------------------------------------------------------------------
#  Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

ballerina_home=$BALLERINA_HOME

if [ ! -e "$ballerina_home/bin/ballerina" ]
then
    echo "[WARNING] Unable to find Ballerina home in your System!"
    read -p "Please enter Ballerina Home: "  ballerina_home
    if [ ! -e "$ballerina_home/bin/ballerina" ]
    then
        echo "[ERROR] Incorrect Ballerina Home provided!"
        exit 1
    fi
fi

ballerina_lib_location=$ballerina_home/bre/lib
ballerina_balo_location=$ballerina_home/lib/repo
version=${project.version}
module_name=mongodb
fileNamePattern="wso2-mongodb-*-*.*.*.jar"

for filename in $ballerina_home/bre/lib/*; do
    existingFile=${filename##*/}
    [[ $existingFile == $fileNamePattern ]] && file=$existingFile || file=""
    if [ "$file" != "" ]; then
        echo "[WARNING] Another version of MongoDB module is already installed."
        read -r -p "Do you want to uninstall the previous version and continue installation? (Y/N): " response
        if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then

            rm $ballerina_lib_location/$existingFile

            if [ -e "$ballerina_lib_location/$existingFile" ]; then
                echo "[ERROR] Error occurred while deleting dependencies from $ballerina_lib_location"
                echo "Please manually delete $ballerina_lib_location/$existingFile and $ballerina_balo_location/wso2/$module_name/0.0.0/$module_name.zip"
                exit 1
            fi

            rm -r $ballerina_balo_location/wso2/$module_name/0.0.0

            if [ -e "$ballerina_balo_location/wso2/$module_name/0.0.0/$module_name.zip" ]; then
                echo "[ERROR] Error occurred while deleting $module_name balo from $ballerina_balo_location"
                echo "Please manually delete $ballerina_balo_location/wso2/$module_name/0.0.0 directory"
                exit 2
            else
                echo "Successfully uninstalled existing MongoDB package: $existingFile"
            fi
        elif [[ $response =~ ^([nN][oO]|[nN])$ ]]; then
            echo "[INFO] Installing module without uninstall the existing version of mongoDB module: [$existingFile]."
            exit 1
        else
            echo "[ERROR] Invalid option provided."
            exit 1
        fi
    fi
done

if [ -e "$ballerina_lib_location/wso2-$module_name-module-$version.jar" ]
then
    if [ ! -e temp ]
    then mkdir temp
    cp $ballerina_lib_location/wso2-$module_name-module-$version.jar temp/
    fi
fi

cp dependencies/wso2-$module_name-module-$version.jar $ballerina_lib_location

if [ $? -ne 0 ]
then
    echo "[ERROR] Error occurred while copying dependencies to $ballerina_lib_location"
    if [ -e temp ]
    then rm -r temp
    fi
    echo "[INFO] You can install the module by manually copying"
    echo 1. "dependencies/wso2-$module_name-module-$version.jar to $ballerina_lib_location"
    echo 2. "Contents of balo directory to $ballerina_balo_location".
    exit 2
fi

cp -r balo/* $ballerina_balo_location/

if [ $? -ne 0 ]; then
    echo "[ERROR] Error occurred while copying $module_name balo to $ballerina_balo_location. Reverting the changes"
    if [ -e temp/wso2-$module_name-module-$version.jar ]; then
        cp temp/wso2-$module_name-module-$version.jar $ballerina_lib_location/
        rm -r temp
    else
        rm $ballerina_lib_location/wso2-$module_name-module-$version.jar
    fi
    echo "[INFO] You can install the module by manually copying"
    echo 1. "dependencies/wso2-$module_name-module-$version.jar to $ballerina_lib_location"
    echo 2. "Contents of balo directory to $ballerina_balo_location"
    exit 3
else
    if [ -e "temp/wso2-$module_name-module-$version.jar" ]; then
        rm -r temp
    fi
    echo "[INFO] Successfully installed MongoDB module: wso2-$module_name-module-$version"
fi
