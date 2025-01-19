@echo off
setlocal EnableDelayedExpansion

:: Define the path config file location
set CONFIGFILE=%~dp0pathconfig.txt

:: Check if the path config file exists and load it, otherwise use the script's directory
if exist "!CONFIGFILE!" (
    set /p BASEPATH=<"!CONFIGFILE!"
) else (
    :: Set BASEPATH to the directory where the batch file is located
    set BASEPATH=%~dp0
)

:menu
cls
echo 1. Select projects folder
echo 2. Zip
echo 3. Exit
echo Current projects base folder: !BASEPATH!
set /p OPTION="Select an option (1-3): "

if "!OPTION!"=="1" goto set_basepath
if "!OPTION!"=="2" goto zip_files
if "!OPTION!"=="3" goto end_script
echo Invalid option, try again
goto menu

:set_basepath
set /p BASEPATH="Enter new base path: "
echo !BASEPATH! > "!CONFIGFILE!"
echo Base path set to !BASEPATH!
pause
goto menu

:zip_files
:: Prompt the user to enter a project number with an optional command
echo Example: "1" to select folder of the 1st project
echo Options:
echo -parse     parse for .hdl is subdirectories 
set /p PROJECTCMD="Enter project number and optional command: "
for /f "tokens=1,* delims= " %%a in ("!PROJECTCMD!") do (
    set PROJECTNUM=%%a
    set COMMAND=%%b
)

:: Construct the folder and archive paths using the user input
set FOLDERPATH=!BASEPATH!\!PROJECTNUM!
set ARCHIVEPATH=!BASEPATH!\!PROJECTNUM!\project!PROJECTNUM!.zip

:: Check if the parse command was given
if /i "!COMMAND!"=="-parse" (
    :: Check if the specified directory exists
    if not exist "!FOLDERPATH!" (
        echo Directory not found: !FOLDERPATH!
        pause
        goto menu
    )
    :: Define the file list path
    set FILELIST=!FOLDERPATH!\hdl_files.txt

    :: Output to indicate the operation has started
    echo Collecting .hdl file paths...

    :: Use dir to find all .hdl files and write them directly to FILELIST
    dir "!FOLDERPATH!\*.hdl" /s /b > "!FILELIST!"

    :: Display the contents of the file list to confirm what was captured
    echo.
    echo List of .hdl file paths:
    type "!FILELIST!"

    :: Compress files listed in FILELIST using PowerShell
    PowerShell -Command "Compress-Archive -Path (Get-Content '!FILELIST!') -DestinationPath '!ARCHIVEPATH!' -Force"
    del "!FILELIST!"
) else (
    :: Use PowerShell to compress the .hdl files in the specified directory without parsing subdirectories
    PowerShell -Command "Compress-Archive -Path '!FOLDERPATH!\*.hdl' -DestinationPath '!ARCHIVEPATH!' -Force"
)
echo Compression complete.

pause
goto menu
:end_script
echo Exiting...
pause
