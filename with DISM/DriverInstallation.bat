@echo off
:: Author:Joshua Chang
:: Date:Sep 26 2014
:: Updated by : Joshua Chang 08/14/2015
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

rem ======================
rem Enabling test signing.
rem ======================
echo select disk 0 > %~dp0list.txt
echo select vol 2 > %~dp0list.txt
echo assign letter=s > %~dp0list.txt
echo exit > %~dp0list.txt
diskpart /s %~dp0list.txt
del %~dp0list.txt

rem ================================
rem Check if UEFI or Legacy in WinPE
rem ================================
%SYSTEMDRIVE%
for /f "tokens=3" %%i in ('reg query "HKLM\System\CurrentControlSet\Control" /v PEFirmwareType') do (
	if /I %%i EQU 0x1 (
		echo ======================
		echo Enabling test signing.
		echo ======================
		rem MBR
		bcdedit -store s:\boot\bcd -set {default} testsigning on
		if %errorlevel% NEQ 0 (
			color 4C
			echo.
			echo "Test signing Failure, Please disable secure bood if has driver no signed...."
			pause
			color E
			)
		) else if /I %%i EQU 0x2 (
		echo ======================
		echo Enabling test signing.
		echo ======================
		rem GPT
		bcdedit -store s:\efi\microsoft\boot\bcd -set {default} testsigning on
		if %errorlevel% NEQ 0 (
			color 4C
			echo.
			echo "Test signing Failure, Please disable secure bood if has driver no signed...."
			pause
			color E
			)
		) else (
		echo "Can't identify either UEFI or Legacy with open test signing"
		pause
		goto Menu
		)
	)

rem =================================================
rem Adds third-party driver packages to Windows image
rem =================================================
set DriverPath=%Disk%:\Resources\Driver
If not Exist %DriverPath% (
	color 4C
	echo.
	echo There aren't any driver be found...
	md %DriverPath%
	pause
	color E
	cd %currentpath%
	goto :EOF
)

if /I %arch% EQU AMD64 (
	cls
	echo ===================================================
	echo == Inject x64 Driver Package to system partition ==
	echo ===================================================
	goto Driver
) else if /I %arch% EQU x86 (
	cls
	echo ===================================================
	echo == Inject x86 Driver Package to system partition ==
	echo ===================================================
	goto Driver
) else (
    echo "System can't compatibility!!"
    pause
    goto Menu
)

:Driver
dism /image:c: /Add-Driver /Driver:%DriverPath% /Recurse /ForceUnsigned
if %errorlevel% NEQ 0 (
	color 4C
	echo.
	echo Drivers inject Failure.... 
	echo.
	pause
	color E
	cd %currentpath%
	goto :EOF
) else (
	echo.
	echo Drivers inject Complete 
	echo.
)
cd %currentpath%
pause
exit

:fail
color 4C
echo USB disk letter error...
pause
:Menu
cd /
call DeployWizard.bat