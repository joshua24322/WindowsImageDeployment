@echo off
:: Author:Joshua Chang
:: Date:Sep 26 2014
:: Updated by : Joshua Chang 03/24/2015
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

path x:\windows\system32;x:\;%Disk%:\;
wpeinit
cls
echo Installation Drive = %Disk%
echo =======================================================
echo == Separate custom.wim file for final customizations ==
echo =======================================================
echo.
DISM /Capture-CustomImage /CaptureDir:C: /ScratchDir:C:\Recycler\Scratch
If %errorlevel% NEQ 0 (
	color 4C
	echo.
	echo Capture-CustomImage Image Fail...
	echo.
	pause
	goto Menu
)

rem == Calculate And set up the Images Partition
cd %SYSTEMDRIVE%\Windows\system32\Script
CalculateAndCreateWIMBootPartition C: C:\Recycler\WIMs\ C:\Recycler\WIMs 300

echo Process is completed, exiting script...
pause
exit

:fail
color 4C
echo USB disk letter error...
pause
:Menu
cd /
call DeployWizard.bat