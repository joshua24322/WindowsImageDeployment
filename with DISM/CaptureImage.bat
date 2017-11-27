@echo off
:: Author:Joshua Chang
:: Date:Sep 26 2014
:: Updated by : Joshua Chang 12/03/2015
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
set CHK_DISK=
for %%i in (d e f g h i j k l m n o p q r s t u v w x y z ) do if exist "%%i:\ChangeDriveLetter.txt" set disk=%%i
for %%j in (d e f g h i j k l m n o p q r s t u v w x y z ) do if exist "%%j:\image_flag.txt" set CHK_DISK=%%j
cls
::echo==================================
::wmic logicaldisk get caption,providername,volumename
::echo==================================
echo list volume > %~dp0list.txt
diskpart /s %~dp0list.txt
if not exist "%disk%:\ChangeDriveLetter.txt" (
	echo.
	echo encounter a issue with detected installation drive.
	echo Please manual select the installation drive:
	echo Warning. You cannot choose your C: Drive.
	echo.
	set /p disk="Installation Drive: "
	)
if not exist "%CHK_DISK%:\image_flag.txt" (
	echo.
	echo encounter a issue with detected image drive.
	echo Please manual select the image drive:
	echo Warning. You cannot choose your C: Drive.
	echo.
	set /p CHK_DISK="Image Drive: "
	)

path x:\windows\system32;x:\;%Disk%:\;
wpeinit

cls
rem ==================
rem Capture .wim image
rem ==================
echo Installation Drive = %Disk%
echo Image Drive = %CHK_DISK%
echo.
echo.
set /p Windows_image="Please Input Windows Image Name: "
set /p ImageName="Please Input Image description: "

echo.
echo.
echo ===========================
echo == Capture Windows image ==
echo ===========================
Dism /Capture-Image /ImageFile:%CHK_DISK%:\%Windows_image%.wim /CaptureDir:c:\ /Name:%ImageName% /Compress:max
If %errorlevel% NEQ 0 (
	color 4C
	echo.
	echo Capture Image Fail...
	echo.
	%SYSTEMDRIVE%\Windows\logs\DISM\dism.log
	pause
	goto Menu
)

%CHK_DISK%:
echo.
echo.
echo == Verify image files ==
echo.
echo ==============================
dir *.wim /b
echo ==============================
echo.
echo Process is completed, exiting script...
echo.
pause
exit

:fail
color 4C
echo USB disk letter error...
pause
:Menu
cd /
call DeployWizard.bat