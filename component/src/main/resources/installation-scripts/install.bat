@ECHO off
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

setlocal enabledelayedexpansion

IF NOT EXIST "%BALLERINA_HOME%/bin/ballerina.bat" (
    ECHO "[WARNING] Unable to find Ballerina home in your system!."
    SET /P ballerina_home=Please enter Ballerina home:
)

IF NOT EXIST "%BALLERINA_HOME%/bin/ballerina.bat" (
    ECHO "[ERROR] Incorrect Ballerina home provided!"
    GOTO :END
) ELSE (
    SET ballerina_home=%BALLERINA_HOME%
)

SET ballerina_lib_location=%ballerina_home%bre\lib
SET ballerina_balo_location=%ballerina_home%lib\repo
SET version=${project.version}
SET module_name=mongodb
SET fileNamePattern=wso2-mongodb-*-*.*.*.jar
SET /a id=1
SET /a index=1

IF EXIST "%ballerina_lib_location%\%fileNamePattern%" (
    SET file="%ballerina_lib_location%\%fileNamePattern%";
    ECHO [WARNING] Another version of MongoDB module is already installed.
    SET /P response="Do you want to uninstall the previous version and continue installation? (Y/N): "
)

IF EXIST "%ballerina_lib_location%\%fileNamePattern%" (
    IF "%response%"=="Y" (
        for /f "delims=" %%G in ('dir %file% /b') do (
            SET filename[%id%]=%%~nG
            SET /a id+=1
        )
        SET /a id-=1
        for /l %%n in (1,1,%id%) do (
            DEL "%ballerina_lib_location%\!filename[%index%]!.jar"

            IF EXIST "%ballerina_lib_location%\!filename[%index%]!.jar" (
                ECHO [ERROR] An error occurred while deleting %ballerina_lib_location%\!filename[%index%]!.jar
                GOTO :FAILED_JAR_DELETION
            )

            DEL "%ballerina_balo_location%\wso2\%module_name%\0.0.0\%module_name%.zip"

            IF EXIST "%ballerina_balo_location%\wso2\%module_name%\0.0.0\%module_name%.zip" (
                ECHO [ERROR] An error occurred while deleting %ballerina_balo_location%wso2\%module_name%\0.0.0\%module_name%.zip
                GOTO :FAILED_BALO_DELETION
            ) ELSE (
                ECHO [INFO] Successfully uninstalled existing mongoDB package: !filename[%index%]!.jar
            )
            SET /a index+=1
        )
    ) ELSE (
        IF "%response%"=="N" (
            ECHO [WARNING] Couldn't maintain the different versions of Kafka module.
            GOTO :END
        ) ELSE (
            ECHO [ERROR] Invalid option provided.
            GOTO :END
        )
    )
)

IF EXIST "%ballerina_lib_location%\wso2-%module_name%-module-%version%.jar" (
    rem Backup if a jar already exists with the same name
    MKDIR temp
	XCOPY "%ballerina_lib_location%\wso2-%module_name%-module-%version%.jar" "temp" /y
)

XCOPY ".\dependencies\wso2-%module_name%-module-%version%.jar" "%ballerina_lib_location%" /y

IF %ERRORLEVEL% GTR 0 (
    ECHO [ERROR] An error occurred while copying .\dependencies\wso2-%module_name%-module-%version%.jar to %ballerina_lib_location%
	ECHO [ERROR] Installation unsuccessful.
	GOTO :FAILED
)

rem Create directory hierarchy for the balo if it doesn't already exist
IF NOT EXIST "%ballerina_balo_location%\wso2\%module_name%\0.0.0" (
    MKDIR "%ballerina_balo_location%\wso2\%module_name%\0.0.0"

	IF ERRORLEVEL 1 (
		ECHO [ERROR] An error occurred while copying .\balo\wso2\%module_name%\0.0.0\%module_name%.zip to %ballerina_balo_location%\wso2\%module_name%\0.0.0
		ECHO [ERROR] Installation unsuccessful. Reverting changes.
		IF EXIST "temp\wso2-%module_name%-module-%version%.jar" (
			ECHO [INFO] Copying backed-up wso2-%module_name%-module-%version%.jar to %ballerina_lib_location%
			XCOPY "temp\wso2-%module_name%-module-%version%.jar" "%ballerina_lib_location%" /y
		) ELSE (
			DEL "%ballerina_lib_location%\wso2-%module_name%-module-%version%.jar"
		)
		GOTO :FAILED
    )
)

rem Copy balo
XCOPY ".\balo\wso2\%module_name%\0.0.0\%module_name%.zip" "%ballerina_balo_location%\wso2\%module_name%\0.0.0" /e /y

IF %ERRORLEVEL% GTR 0 (
    ECHO [ERROR] An error occurred while copying .\balo\wso2\%module_name%\0.0.0\%module_name%.zip to %ballerina_balo_location%\wso2\%module_name%\0.0.0
    ECHO [ERROR] Installation unsuccessful. Reverting changes.
    IF EXIST "temp\wso2-%module_name%-module-%version%.jar" (
	    ECHO [INFO] Copying backed-up wso2-%module_name%-module-%version%.jar to %ballerina_lib_location%
	    XCOPY "temp\wso2-%module_name%-module-%version%.jar" "%ballerina_lib_location%" /y
	) ELSE (
	    DEL "%ballerina_lib_location%\wso2-%module_name%-module-%version%.jar"
	)
	GOTO :FAILED
)

:SUCCESS
ECHO [INFO] Successfully installed MongoDB module: wso2-%module_name%-module-%version%
GOTO :END

:FAILED
ECHO [INFO] You can manually install the module by copying
ECHO 1. dependencies\wso2-%module_name%-module-%version%.jar to %ballerina_lib_location%
ECHO 2. balo\wso2\%module_name%\0.0.0\%module_name%.zip to %ballerina_balo_location%\wso2\%module_name%\0.0.0

:FAILED_JAR_DELETION
ECHO [ERROR] Un-installation is incomplete due to an error. Please manually delete %ballerina_lib_location%wso2-%module_name%-package-%version%.jar and %ballerina_balo_location%wso2\%module_name%\0.0.0\%module_name%.zip
GOTO :END

:FAILED_BALO_DELETION
ECHO [ERROR] Un-installation is incomplete due to an error. Please manually delete %ballerina_balo_location%wso2\%module_name%\0.0.0\%module_name%.zip

:END
IF EXIST .\temp (
RD temp /s /q
)
ENDLOCAL
