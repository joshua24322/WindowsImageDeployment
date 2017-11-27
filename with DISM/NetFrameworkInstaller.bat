@echo off
:: Author:Joshua Chang
:: Date:Sep 26 2014
:: Updated by : Joshua Chang 12/03/2015
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
echo Microsoft .NET Framework 3.5
echo Applies To: Windows 7, Windows 8, Windows 8.1, Windows 10, Windows Server 2012, Windows Server 2012 R2
echo.
echo.
echo ==================================
dir *.* /b
echo ==================================
echo.
echo.
set /p Windows_image="Select an OS source who match online image to enable net3.5 feature: "
cd %Windows_image%
pause
@echo on
if not exist "%disk%\Resources\OS\%Windows_image%\upgrade\netfx\netfx1.cab" (
	set SourcePath="%disk%\Resources\OS\%Windows_image%\sources\sxs"
	goto net_enable
	) else if (
	set SourcePath="%disk%\Resources\OS\%Windows_image%\upgrade\netfx"
	goto net_enable
	) else (
	cls
	echo Can't find .Net source file.
	goto :EOF
	)
pause
@echo off

:net_enable
rem enable net3.5 feature
dism /image:c: /enable-feature /featurename:netfx3 /source:%SourcePath% /ScratchDir:c:\
If %errorlevel% NEQ 0 (
	color 4C
	echo.
	echo Net3.5 Feature Enable Failure...
	echo.
	%SYSTEMDRIVE%\Windows\logs\DISM\dism.log
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