@echo off
rem ----------------------------------------------------------------------
rem Copyright (c) 2018, WSO2 Inc. (http:www.wso2.org) All Rights Reserved.
rem
rem WSO2 Inc. licenses this file to you under the Apache License,
rem Version 2.0 (the "License"); you may not use this file except
rem in compliance with the License.
rem You may obtain a copy of the License at
rem
rem     http:www.apache.orglicensesLICENSE-2.0
rem
rem Unless required by applicable law or agreed to in writing,
rem software distributed under the License is distributed on an
rem "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
rem KIND, either express or implied.  See the License for the
rem specific language governing permissions and limitations
rem under the License.
rem

rem SETLOCAL
IF NOT EXIST "%BALLERINA_HOME%/bin/ballerina.bat" (
    SET /P ballerina_home=Couldn't find Ballerina home in your system!.Please enter Ballerina home:
)

IF NOT EXIST "%BALLERINA_HOME%/bin/ballerina.bat" (
    ECHO "Incorrect Ballerina Home provided!"
    GOTO :END
) ELSE (
    SET ballerina_home=%BALLERINA_HOME%
)

SET ballerina_lib_location=%ballerina_home%\bre\lib\
SET ballerina_balo_location=%ballerina_home%\lib\repo\
SET version=${project.version}
SET module_name=mongodb

IF NOT EXIST "%ballerina_lib_location%\wso2-%module_name%-module-%version%.jar" (
    IF NOT EXIST "%ballerina_balo_location%\wso2\%module_name%\0.0.0\%module_name%.zip" (
	   ECHO MongoDB module is not installed!
	   GOTO :END
	)
)

IF EXIST "%ballerina_lib_location%\wso2-%module_name%-module-%version%.jar" (
   DEL "%ballerina_lib_location%\wso2-%module_name%-module-%version%.jar"
   IF EXIST "%ballerina_lib_location%\wso2-%module_name%-module-%version%.jar" (
    ECHO An error occurred while deleting %ballerina_lib_location%wso2-%module_name%-module-%version%.jar
	GOTO :FAILED_JAR_DELETION
   )
)

IF EXIST "%ballerina_balo_location%\wso2\%module_name%\0.0.0\%module_name%.zip" (
   DEL "%ballerina_balo_location%\wso2\%module_name%\0.0.0\%module_name%.zip"
   IF EXIST "%ballerina_balo_location%\wso2\%module_name%\0.0.0\%module_name%.zip" (
    ECHO An error occurred while deleting %ballerina_balo_location%wso2\%module_name%\0.0.0\%module_name%.zip
	GOTO :FAILED_BALO_DELETION
   )
)

:SUCCESS
ECHO Successfully uninstalled MongoDB module!
GOTO :END

:FAILED_JAR_DELETION
ECHO Un-installation is incomplete due to an error. Please manually delete %ballerina_lib_location%wso2-%module_name%-module-%version%.jar and %ballerina_balo_location%wso2\%module_name%\0.0.0\%module_name%.zip
GOTO :END

:FAILED_BALO_DELETION
ECHO Un-installation is incomplete due to an error. Please manually delete %ballerina_balo_location%wso2\%module_name%\0.0.0\%module_name%.zip

:END
ENDLOCAL
