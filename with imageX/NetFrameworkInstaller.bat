@echo off
:: Author:Joshua Chang
:: Date:Nov 19 2015
:: Updated by : Joshua Chang 11/19/2015
cls
setlocal EnableDelayedExpansion
color E
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

cls
%disk%:
cd \Resources\OS
echo.
echo == Microsoft .NET Framework 3.5 ==
echo.
echo.
echo ==================================
dir *.* /b
echo ==================================
echo.
echo.
set /p Windows_image="Please Input OS Folder Name who equal online image to enable net3.5 feature: "
cd %Windows_image%
set SourcePath="%disk%\Resources\OS\%Windows_image%\upgrade\netfx"


rem enable net3.5 feature
dism /image:c: /enable-feature /featurename:netfx3 /source:%SourcePath% /ScratchDir:c:\
If %errorlevel% NEQ 0 (
	color 4C
	echo.
	echo Net3.5 Feature Enable Failure...
	echo.
	pause
	color E
	cd %currentpath%
	goto :EOF
	) else (
	echo.
	echo Enable Net3.5 Successful
	echo.
	)
cd %currentpath%
pause
exit

:fail
color 4C
echo USB disk letter error...
pause
goto :EOF