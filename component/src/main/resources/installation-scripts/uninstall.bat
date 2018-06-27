@echo off
SETLOCAL
SET /P ballerina_home=Please enter Ballerina home:

SET ballerina_lib_location=%ballerina_home%\bre\lib\
SET ballerina_balo_location=%ballerina_home%\lib\repo\
SET version=0.5.6-SNAPSHOT
SET package_name=mongodb

IF NOT EXIST "%ballerina_lib_location%\wso2-%package_name%-package-%version%.jar" (
    IF NOT EXIST "%ballerina_balo_location%\wso2\%package_name%\0.0.0\%package_name%.zip" (
	   ECHO MongoDB package is not installed!
	   GOTO :END
	)
)

IF EXIST "%ballerina_lib_location%\wso2-%package_name%-package-%version%.jar" (
   DEL "%ballerina_lib_location%\wso2-%package_name%-package-%version%.jar"
   IF EXIST "%ballerina_lib_location%\wso2-%package_name%-package-%version%.jar" (
    ECHO An error occurred while deleting %ballerina_lib_location%wso2-%package_name%-package-%version%.jar
	ECHO Please delete %ballerina_lib_location%wso2-%package_name%-package-%version%.jar manually
	GOTO :END
   )
)

IF EXIST "%ballerina_balo_location%\wso2\%package_name%\0.0.0\%package_name%.zip" (
   DEL "%ballerina_balo_location%\wso2\%package_name%\0.0.0\%package_name%.zip"
   IF EXIST "%ballerina_balo_location%\wso2\%package_name%\0.0.0\%package_name%.zip" (
    ECHO An error occurred while deleting %ballerina_balo_location%wso2\%package_name%\0.0.0\%package_name%.zip
	ECHO Please delete %ballerina_balo_location%wso2\%package_name%\0.0.0\%package_name%.zip manually
	GOTO :END
   )
)

ECHO Successfully uninstalled MongoDB package!

:END
ENDLOCAL