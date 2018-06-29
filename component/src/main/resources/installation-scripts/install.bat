@echo off
SETLOCAL
SET /P ballerina_home=Please enter Ballerina home:

IF NOT EXIST "%ballerina_home%/bin/ballerina.bat" (
    ECHO "Incorrect Ballerina Home provided!"
    GOTO :END
)

SET ballerina_lib_location=%ballerina_home%\bre\lib
SET ballerina_balo_location=%ballerina_home%\lib\repo
SET version=0.5.6-SNAPSHOT
SET package_name=mongodb

IF EXIST "%ballerina_lib_location%\wso2-%package_name%-package-%version%.jar" (
    rem Backup if a jar already exists with the same name
    MKDIR temp
	XCOPY "%ballerina_lib_location%\wso2-%package_name%-package-%version%.jar" "temp" /y
)

XCOPY ".\dependencies\wso2-%package_name%-package-%version%.jar" "%ballerina_lib_location%" /y

IF %ERRORLEVEL% GTR 0 (
    ECHO An error occurred while copying .\dependencies\wso2-%package_name%-package-%version%.jar to %ballerina_lib_location%
	ECHO Installation unsuccessful.
	GOTO :FAILED
)

rem Create directory hierarchy for the balo if it doesn't already exist
IF NOT EXIST "%ballerina_balo_location%\wso2\%package_name%\0.0.0" (
    MKDIR "%ballerina_balo_location%\wso2\%package_name%\0.0.0"

	IF ERRORLEVEL 1 (
		ECHO An error occurred while copying .\balo\wso2\%package_name%\0.0.0\%package_name%.zip to %ballerina_balo_location%\wso2\%package_name%\0.0.0
		ECHO Installation unsuccessful. Reverting changes.
		IF EXIST "temp\wso2-%package_name%-package-%version%.jar" (
			ECHO Copying backed-up wso2-%package_name%-package-%version%.jar to %ballerina_lib_location%
			XCOPY "temp\wso2-%package_name%-package-%version%.jar" "%ballerina_lib_location%" /y
		) ELSE (
			DEL "%ballerina_lib_location%\wso2-%package_name%-package-%version%.jar"
		)
		GOTO :FAILED
    )
)

rem Copy balo
XCOPY ".\balo\wso2\%package_name%\0.0.0\%package_name%.zip" "%ballerina_balo_location%\wso2\%package_name%\0.0.0" /e /y

IF %ERRORLEVEL% GTR 0 (
    ECHO An error occurred while copying .\balo\wso2\%package_name%\0.0.0\%package_name%.zip to %ballerina_balo_location%\wso2\%package_name%\0.0.0
    ECHO Installation unsuccessful. Reverting changes.
    IF EXIST "temp\wso2-%package_name%-package-%version%.jar" (
	    ECHO Copying backed-up wso2-%package_name%-package-%version%.jar to %ballerina_lib_location%
	    XCOPY "temp\wso2-%package_name%-package-%version%.jar" "%ballerina_lib_location%" /y
	) ELSE (
	    DEL "%ballerina_lib_location%\wso2-%package_name%-package-%version%.jar"
	)
	GOTO :FAILED
)

:SUCCESS
ECHO Successfully installed MongoDB package!
GOTO :END

:FAILED
ECHO You can manually install the package by copying
ECHO 1. dependencies\wso2-%package_name%-package-%version%.jar to %ballerina_lib_location%
ECHO 2. balo\wso2\%package_name%\0.0.0\%package_name%.zip to %ballerina_balo_location%\wso2\%package_name%\0.0.0

:END
IF EXIST .\temp (
RD temp /s /q
)
ENDLOCAL
