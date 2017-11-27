@echo off
:: Author:Joshua Chang
:: Date:Sep 26 2014
:: Updated by : Joshua Chang 07/24/2015
cls
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
echo Installation Drive = %Disk%
echo Image Drive = %CHK_DISK%

rem ======================================================
rem Check if UEFI or Legacy in WinPE for Windows 8 and 8.1
rem ======================================================
x:

for /f "tokens=3" %%i in ('reg query "HKLM\System\CurrentControlSet\Control" /v PEFirmwareType') do (
	if /I %%i EQU 0x1 (
		cls
		echo.
		echo "WIMBoot is available only for UEFI-based PCs running in UEFI mode (legacy BIOS-compatibility mode isn't supported)"
		pause
		goto Menu
		) else if /I %%i EQU 0x2 (
		goto GPT_WIMBoot
		) else (
		cls
		echo.
		echo "Can't identify whether UEFI or Legacy BIOS"
		pause
		goto Menu
		)
	)

:GPT_WIMBoot
cd %SYSTEMDRIVE%\Windows\system32\Script
Diskpart /s Diskpart_GPT_InitalWIMBoot.txt
echo Diskpart end %time% >> x:\time.log

%CHK_DISK%:
cls
echo Please select the image file you want to restore:
echo.
echo ==================================
dir *.wim /b
echo ==================================
echo.

:WIMBootable_identify
echo.
rem =================================================
rem == identify select image whether is WIM Bootable.
rem =================================================
set /p Windows_image="Please Input Windows Image Name: "
for /F "tokens=1* delims=" %%i in ('dism /get-imageinfo /imagefile:%CHK_DISK%:\%Windows_image%.wim /index:1 ^|find "WIM Bootable"') do (
	for /F "delims=" %%j in ("WIM Bootable : Yes") do (
		if /I %%i EQU %%j (
			set /p WinRE_image="Please Input WinRE Image Name: "
			echo.
			goto Identify_processor
			) else (
			echo This image is not WIMBootable...please select WIMBoot image...
			pause
			goto WIMBootable_identify
			)
		)
	)

:Identify_processor
if /I %arch% EQU AMD64 (
	echo ================================================
	echo == Inital setup Windows 8.1 x64 WIMBoot image ==
    echo ================================================
    goto WIMBootable
    ) else if /I %arch% EQU x86 (
	echo ================================================
	echo == Inital setup Windows 8.1 x86 WIMBoot image ==
	echo ================================================
	goto WIMBootable
	) else (
	echo.
	echo System processor can't compatibility!!
	pause
	goto Menu
	)

:WIMBootable
rem == Create a temporary folder in the Windows partition. This folder name is required. ==
md "C:\Recycler\WIMs\"

rem == Copy the Windows image from the USB or network drive (N) to temporary folder in the Windows partition.
rem == Rename the image file install.wim (if necessary). This filename is required.
echo copy image to partition, please wait...
copy %CHK_DISK%:\%Windows_image%.wim "C:\Recycler\WIMs\install.wim"

rem == Create a scratch folder for DISM operations ==
md "C:\Recycler\Scratch"

rem == Apply the Windows image to the Windows partition ==
DISM /Apply-Image /ImageFile:"C:\Recycler\WIMs\install.wim" /ApplyDir:C: /Index:1 /WIMBoot /ScratchDir:C:\Recycler\Scratch
If %errorlevel% NEQ 0 (
	color 4C
	echo.
	echo Apply WIMBoot Image Fail...
	echo.
	pause
	goto Menu
)
echo.

rem == Create boot files and set them to boot to the Windows partition ==
c:\windows\system32\bcdboot c:\windows
If %errorlevel% NEQ 0 (
	color 4C
	echo.
	echo ESP BCD Boot Manager Error...
	echo.
	pause
	goto Menu
)
echo.

rem == Add the Windows RE image to the Images partition ==
md "M:\Recovery\WindowsRE"
echo f| xcopy %CHK_DISK%:\%WinRE_image%.wim C:\Recycler\WIMs\winre.wim /h
If %errorlevel% NEQ 0 (
	color 4C
	echo.
	echo Deploy Windows RE image fail...
	echo.
	pause
	goto Menu
)
echo.

::rem == Don’t register the location of the recovery tools ==

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