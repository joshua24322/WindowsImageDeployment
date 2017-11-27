@echo off
:: Author:Joshua Chang
:: Date:Nov 19 2015
:: Updated by : Joshua Chang 11/19/2015
color E
chdir /D %~dp0

:Wizard
cls
echo.
echo Applies To: Windows 7, Windows Server 2008 R2
echo ===========================
echo == Windows Deploy Wizard ==
echo ===========================
echo 1. Capture Image
echo 2. Restore Image
echo 3. Install pure OS
echo 4. Install Driver Packages (.inf)
echo 5. Install Cabinet (.cab) or Windows Update Stand-alone Installer (.msu)
echo 6. Enable Net3.5 feature
echo 7. Exit
echo.
echo.
set/p mychoice="Please select option with number key: "
if "%mychoice%"=="1" goto Capture
if "%mychoice%"=="2" goto Restore
if "%mychoice%"=="3" goto OS
if "%mychoice%"=="4" goto Driver
if "%mychoice%"=="5" goto cab&msu
if "%mychoice%"=="6" goto Net3.5
if "%mychoice%"=="7" goto EXIT
if "%mychoice%"=="0" goto Wizard
if "%mychoice%" GEQ 8 goto Wizard

:Capture
call %SYSTEMDRIVE%\Windows\system32\Script\CaptureImage.bat
goto Wizard

:Restore
call %SYSTEMDRIVE%\Windows\system32\Script\StandardApplyImage.bat
goto Wizard

:::WIMBootOperation
::cls
::set pVersion=WinPE not found
::for /F "usebackq tokens=3" %%i IN (`reg query "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\WinPE" /v "Version" 2^>nul ^| find "Version"`) do set pVersion=%%i
::echo WinPE Version: %pVersion%
::if /i "%pVersion%" lss "5.1" (
::	echo.
::	echo This WIMBoot Operation can only be used in WinPE 5.1 or newer version
::	echo.
::	pause
::	goto Wizard
::	)

::echo =================================
::echo == Windows8.1 WIMBoot Operation==
::echo =================================
::echo 1.Capture Windows 8.1 WIMBoot Image
::echo 2.Inital setup Windows 8.1 with WIMBoot
::echo 3.Save factory floor customizations into custom.wim
::echo 4.Restore Windows 8.1 WIMBoot Image
::echo 5.EXIT
::echo.
::echo.
::set/p mychoice="Please select option with number key: "
::if "%mychoice%"=="1" call %SYSTEMDRIVE%\Windows\system32\Script\CaptureWIMBootImage.bat
::if "%mychoice%"=="2" call %SYSTEMDRIVE%\Windows\system32\Script\WIMBootInitalSetup.bat
::if "%mychoice%"=="3" call %SYSTEMDRIVE%\Windows\system32\Script\Capture-CustomImage.bat
::if "%mychoice%"=="4" call %SYSTEMDRIVE%\Windows\system32\Script\WIMBootApplyImage.bat
::if "%mychoice%"=="5" goto EXIT
::if "%mychoice%"=="0" goto WIMBootOperation
::if "%mychoice%" GEQ 6 goto WIMBootOperation
::goto Wizard

:OS
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
echo List all folders of \Resources\OS:
echo ==================================
dir *.* /b
echo ==================================
echo.
echo.
set /p Windows_image="Please Input Folder Name to install OS: "
cd %Windows_image%
if exist *.txt (
	more /e /s /c *.txt
	start /w setup.exe
	) else (
	start setup.exe
	)
goto Wizard

:Driver
call %SYSTEMDRIVE%\Windows\system32\Script\DriverInstallation.bat
goto Wizard

:cab&msu
call "%SYSTEMDRIVE%\Windows\system32\Script\Windows Update Stand-alone Installer.bat"
goto Wizard

:Net3.5
call %SYSTEMDRIVE%\Windows\system32\Script\NetFrameworkInstaller.bat
goto Wizard

:EXIT
exit

:done
cd %currentpath%