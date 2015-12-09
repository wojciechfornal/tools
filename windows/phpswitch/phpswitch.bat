@echo off

rem | Local PHP switching helper.
rem | 
rem | Author: Wojciech Fornal
rem |
rem | WARNING!
rem |
rem | This script may break your local PHP installation!
rem | Read the sourcer code before proceeding.
rem | 
rem | Here are requirements for the script to work:
rem |
rem | * PHP junction location is provided by PHP_HOME environmental variable (eg. C:\PHP)
rem | * each PHP version needs to be in a properly named directory (eg. C:\PHP_7_0)
rem | * script needs privileges to write to disk
rem | * just in case, current PHP directory needs to be a junction
rem | 
rem | The script has been tested with following Windows versions:
rem |
rem | * Windows 10

REM | @todo Experiment with iteration over tokens to present PHP versions
REM | @todo Experiment with simple server config changes and env variables changes (no PHP directory manipulation)
REM | @todo Error handling (environmental variable doesn't exist, etc.)
REM | @todo Add configuration flags to the top of the script (whether to restart Apache or not, etc...)

setlocal

set PHP_JUNCTION=%PHP_HOME%
set PHP_DRIVE=c:

echo.
echo WARNING!
echo --------------------------------------------------------------------------------
echo This script may break your local PHP installation!
echo Read the source code before proceeding.
echo --------------------------------------------------------------------------------
echo.

if not -%1-==-- goto :ARGUMENT_PROVIDED

:ARGUMENT_NOT_PROVIDED
goto :CHOICE

:ARGUMENT_PROVIDED
if %1==5.4 set USER_CHOICE=1 & goto :AFTER_CHOICE
if %1==5.5 set USER_CHOICE=2 & goto :AFTER_CHOICE
if %1==5.6 set USER_CHOICE=3 & goto :AFTER_CHOICE
if %1==7.0 set USER_CHOICE=4 & goto :AFTER_CHOICE
goto :CHOICE

:CHOICE
echo Choose PHP verrsion:
echo.
echo A: PHP 5.4 (5.4.45) VC9  x86 Thread Safe
echo B: PHP 5.5 (5.5.30) VC11 x86 Thread Safe
echo C: PHP 5.6 (5.6.16) VC11 x86 Thread Safe
echo D: PHP 7.0 (7.0.0)  VC14 x64 Thread Safe
echo X: Exit (default)

choice /c ABCDX /n /t 10 /d X /m "> "
set USER_CHOICE=%ERRORLEVEL%
echo.

:AFTER_CHOICE
if %USER_CHOICE% equ 5 goto :EXIT
if %USER_CHOICE% equ 1 set PHP_DIR=PHP_5_4& set PHP_VER=5.4
if %USER_CHOICE% equ 2 set PHP_DIR=PHP_5_5& set PHP_VER=5.5
if %USER_CHOICE% equ 3 set PHP_DIR=PHP_5_6& set PHP_VER=5.6
if %USER_CHOICE% equ 4 set PHP_DIR=PHP_7_0& set PHP_VER=7.0

set PHP_FULL_DIR=%PHP_DRIVE%\%PHP_DIR%

rem ==================================================
rem SWITCH PHP
rem ==================================================
:SWITCH_PHP
echo Switching to PHP %PHP_VER%...
echo.
call :STOP_APACHE
call :DEL_PHP_JUNCTION
if %ERRORLEVEL% neq 0 goto :EXIT
call :CREATE_PHP_JUNCTION
call :CHECK_PHP_VERSION
call :START_APACHE
goto :EXIT

rem ==================================================
rem DELETE CURRENT PHP JUNCTION
rem ==================================================
:DEL_PHP_JUNCTION
echo --------------------------------------------------------------------------------
echo PHP junction directory...
echo --------------------------------------------------------------------------------
rem We're afraid to delete normal PHP dir
fsutil reparsepoint query %PHP_JUNCTION% >nul
if %ERRORLEVEL% neq 0 echo Current PHP directory needs to be a junction... & exit /b 1
echo Deleting current PHP junction at %PHP_JUNCTION%...
if exist "%PHP_JUNCTION%" rd /s /q "%PHP_JUNCTION%"
exit /b 0

rem ==================================================
rem CREATE NEW PHP JUNCTION
rem ==================================================
:CREATE_PHP_JUNCTION
echo Creating new PHP junction at %PHP_JUNCTION%...
mklink /j "%PHP_HOME%" "%PHP_FULL_DIR%"
exit /b 0

rem ==================================================
rem CHECK PHP (CLI) VERSION
rem ==================================================
:CHECK_PHP_VERSION
echo --------------------------------------------------------------------------------
echo PHP check...
echo --------------------------------------------------------------------------------
php -v
exit /b 0

:STOP_APACHE
echo --------------------------------------------------------------------------------
echo Stopping Apache...
echo --------------------------------------------------------------------------------
c:\Apache24\bin\httpd.exe -k shutdown
exit /b 0

:START_APACHE
echo --------------------------------------------------------------------------------
echo Starting Apache...
echo --------------------------------------------------------------------------------
set APACHE_CONF=c:\Apache24\conf\httpd_%PHP_DIR%.conf
echo Starting Apache HTTP Server using %APACHE_CONF%...
c:\Apache24\bin\httpd.exe -k start -n "Apache2.4" -f "%APACHE_CONF%"
exit /b 0

rem ==================================================
rem Exit
rem ==================================================
:EXIT
endlocal
echo.
echo Bye... & exit /b 0