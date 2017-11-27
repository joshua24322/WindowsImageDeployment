@echo off
:: Author:Joshua Chang
:: Date:Sep 26 2014
:: Updated by : Joshua Chang 03/24/2015
cls
setlocal EnableDelayedExpansion
color E
set arch=%processor_architecture%
set currentpath=%cd%
cd %~dp0
cd ..
echo %cd%

rem ================================
rem identify disk partition codename
rem ================================
set disk=
for %%i in (d e f g h i j k l m n o p q r s t u v w x y z ) do if exist "%%i:\ChangeDriveLetter.txt" set disk=%%i
if not exist "%disk%:\ChangeDriveLetter.txt" (
	echo encounter a issue with detected installation drive.
	echo Please manual select the installation drive:
	echo.
	echo list volume > %~dp0list.txt
	diskpart /s %~dp0list.txt
	echo.
	echo Warning. You cannot choose your C: Drive.
	echo.
	set /p disk="Installation Drive: "
	)

rem Install cabinet (.cab) or Windows Update Stand-alone Installer (.msu) files
rem Packages are used by MicrosoftR to distribute software updates, service packs, and language packs. Packages can also contain Windows features
set Packages=%Disk%:\Resources\Packages
If not Exist %Packages% (
	color 4C
	echo.
	echo There aren't Packages be found...
	echo.
	md %Packages%
	pause
	color E
	cd %currentpath%
	goto :EOF
)

if /I %arch% EQU AMD64 (
	set PackagePath="%Packages%\Windows x64"
	goto MSFT_Distribute_Package
	) else if /I %arch% EQU x86 (
	set PackagePath="%Packages%\Windows x86"
	goto MSFT_Distribute_Package
	) else (
	echo "System can't compatibility!!"
    cd %currentpath%
	)

:MSFT_Distribute_Package
cls
echo ===========================================================================
echo == Install cabinet (.cab) or Windows Update Stand-alone Installer (.msu) ==
echo ===========================================================================
Dism /Image:c: /Add-Package /PackagePath:%PackagePath% /IgnoreCheck /ScratchDir:c:\ /LogPath:"c:\DISM Deploy cab and msu.txt"
if %errorlevel% NEQ 0 (
	color 4C
	echo.
	echo Packages Install Failure....
	echo.
	pause
	color E
	cd %currentpath%
	goto :EOF
) else (
	echo.
	echo Packages Install Complete
	echo.
)
cd %currentpath%
pause
exit

:fail
color 4C
echo USB disk letter error...
pause