@echo off
:: Author:Joshua Chang
:: Date:Sep 26 2014
:: Updated by : Joshua Chang 12/24/2015
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

echo Installation Drive = %Disk%
echo Image Drive = %CHK_DISK%

rem ================================
rem Check if UEFI or Legacy in WinPE
rem ================================
%SYSTEMDRIVE%
for /f "tokens=3" %%i in ('reg query "HKLM\System\CurrentControlSet\Control" /v PEFirmwareType') do (
	if /I %%i EQU 0x1 (
		goto MBR
		) else if /I %%i EQU 0x2 (
		goto GPT
		) else (
		echo "Can't identify either UEFI or Legacy BIOS"
		pause
		goto Menu
		)
	)

:GPT
cd %SYSTEMDRIVE%\Windows\system32\Script
Diskpart /s Diskpart_GPT.txt
echo Diskpart end %time% >> x:\time.log
goto Standard

:MBR
cd %SYSTEMDRIVE%\Windows\system32\Script
Diskpart /s Diskpart_MBR.txt
echo Diskpart end %time% >> x:\time.log
goto Standard

:Standard
cls
%CHK_DISK%:
echo Please select the image file you want to restore:
echo ==================================
dir *.wim /b
echo ==================================
echo.
echo.

if /I %arch%==AMD64 (
	echo =================================
	echo == Restore Windows 64bit image ==
    echo =================================
    goto StandardApply
    ) else if /I %arch%==x86 (
	echo =================================
	echo == Restore Windows 86bit image ==
	echo =================================
	goto StandardApply
	) else (
	echo System can't compatibility!!
	pause
	goto Menu
	)

:StandardApply
set /p Windows_image="Please Input Windows Image Name: "

dism /get-imageinfo /imagefile:%CHK_DISK%:\%Windows_image%.wim

set /p index_number="Please Input Index Number: "

for /F "tokens=1* delims=" %%i in ('dism /get-imageinfo /imagefile:%CHK_DISK%:\%Windows_image%.wim /index:%index_number% ^|find "WIM Bootable"') do (
	for /F "delims=" %%j in ("WIM Bootable : Yes") do (
		if /I %%i==%%j (
			cls
			echo "This is WIMBootable image...please select standard partition layout image..."
			pause
			goto StandardApply
		) else (
			set /p compact_OS="Compact image (Yes:1; No:2) [Windows 10 support only]: "
			if "%compact_OS%"=="1" goto ApplyCompactImage
			if "%compact_OS%"=="2" goto ApplyImage
			if "%compact_OS%"=="0" goto Standard
			if "%compact_OS%" GEQ 3 goto Standard
			)
		)
	)

:ApplyCompactImage
dism /Apply-Image /ImageFile:%CHK_DISK%:\%Windows_image%.wim /Index:%index_number% /ApplyDir:w:\ /Compact:ON
If %errorlevel% NEQ 0 (
	color 4C
	echo.
	echo Restore Image Fail...
	echo.
	%SYSTEMDRIVE%\Windows\logs\DISM\dism.log
	pause
	goto Menu
)
goto SetupOSboot

:ApplyImage
dism /Apply-Image /ImageFile:%CHK_DISK%:\%Windows_image%.wim /Index:%index_number% /ApplyDir:w:\
If %errorlevel% NEQ 0 (
	color 4C
	echo.
	echo Restore Image Fail...
	echo.
	%SYSTEMDRIVE%\Windows\logs\DISM\dism.log
	pause
	goto Menu
)

:SetupOSboot
rem == Copy boot files from the Windows partition to the System partition ==
w:\windows\system32\bcdboot w:\windows /s S: /f all
if %errorlevel% NEQ 0 (
		color 4C
		echo.
		echo ESP BCD Boot Manager Error...
		echo.
		pause
		goto Menu
		)

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