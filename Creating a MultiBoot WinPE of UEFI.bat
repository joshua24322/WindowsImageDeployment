@echo off

:: Author:Joshua Chang
:: Date:Sep 07 2014
:: Updated by : Joshua Chang 08/31/2015

setlocal EnableDelayedExpansion

set bcd_path=C:\BCD_multiboot
if exist %bcd_path% del /q %bcd_path%

rem Create/Initial a new bcd file
bcdedit /createstore %bcd_path%
cls
echo.
rem Build WinPE 6.0 x86 setting
echo Build WinPE 6.0 x86 setting
echo.
for /f "tokens=2 delims={}" %%i in ('bcdedit /store %bcd_path% /create /d "WinPE 6.0 x86" /application osloader') do set guid60x86=%%i
bcdedit /store %bcd_path% /set {bootmgr} default {%guid60x86%} ::set WinPE 6.0 x86 is default item
bcdedit /store %bcd_path% /set {%guid60x86%} device ramdisk=[boot]\sources\winpe_6.0_x86.wim,{ramdiskoptions}
bcdedit /store %bcd_path% /set {%guid60x86%} osdevice ramdisk=[boot]\sources\winpe_6.0_x86.wim,{ramdiskoptions}
bcdedit /store %bcd_path% /set {%guid60x86%} locale en-US
bcdedit /store %bcd_path% /set {%guid60x86%} inherit {bootloadersettings}
bcdedit /store %bcd_path% /set {%guid60x86%} path "\windows\system32\boot\winload.efi"
bcdedit /store %bcd_path% /set {%guid60x86%} systemroot \windows
bcdedit /store %bcd_path% /set {%guid60x86%} detecthal Yes
bcdedit /store %bcd_path% /set {%guid60x86%} winpe Yes
bcdedit /store %bcd_path% /set {%guid60x86%} ems No
echo.
echo.
rem Build WinPE 6.0 x64 setting
echo Build WinPE 6.0 x64 setting
echo.
for /f "tokens=2 delims={}" %%i in ('bcdedit /store %bcd_path% /create /d "WinPE 6.0 x64" /application osloader') do set guid60x64=%%i
bcdedit /store %bcd_path% /set {%guid60x64%} device ramdisk=[boot]\sources\winpe_6.0_amd64.wim,{ramdiskoptions}
bcdedit /store %bcd_path% /set {%guid60x64%} osdevice ramdisk=[boot]\sources\winpe_6.0_amd64.wim,{ramdiskoptions}
bcdedit /store %bcd_path% /set {%guid60x64%} locale en-US
bcdedit /store %bcd_path% /set {%guid60x64%} inherit {bootloadersettings}
bcdedit /store %bcd_path% /set {%guid60x64%} path "\windows\system32\boot\winload.efi"
bcdedit /store %bcd_path% /set {%guid60x64%} systemroot \windows
bcdedit /store %bcd_path% /set {%guid60x64%} detecthal Yes
bcdedit /store %bcd_path% /set {%guid60x64%} winpe Yes
bcdedit /store %bcd_path% /set {%guid60x64%} ems No
echo.
echo.
rem Build WinPE 5.1 x86 setting
echo Build WinPE 5.1 x86 setting
echo.
for /f "tokens=2 delims={}" %%i in ('bcdedit /store %bcd_path% /create /d "WinPE 5.1 x86" /application osloader') do set guid51x86=%%i
bcdedit /store %bcd_path% /set {%guid51x86%} device ramdisk=[boot]\sources\winpe_5.1_x86.wim,{ramdiskoptions}
bcdedit /store %bcd_path% /set {%guid51x86%} osdevice ramdisk=[boot]\sources\winpe_5.1_x86.wim,{ramdiskoptions}
bcdedit /store %bcd_path% /set {%guid51x86%} locale en-US
bcdedit /store %bcd_path% /set {%guid51x86%} inherit {bootloadersettings}
bcdedit /store %bcd_path% /set {%guid51x86%} path "\windows\system32\boot\winload.efi"
bcdedit /store %bcd_path% /set {%guid51x86%} systemroot \windows
bcdedit /store %bcd_path% /set {%guid51x86%} detecthal Yes
bcdedit /store %bcd_path% /set {%guid51x86%} winpe Yes
bcdedit /store %bcd_path% /set {%guid51x86%} ems No
echo.
echo.
rem Build WinPE 5.1 x64 setting
echo Build WinPE 5.1 x64 setting
echo.
for /f "tokens=2 delims={}" %%i in ('bcdedit /store %bcd_path% /create /d "WinPE 5.1 x64" /application osloader') do set guid51x64=%%i
bcdedit /store %bcd_path% /set {%guid51x64%} device ramdisk=[boot]\sources\winpe_5.1_amd64.wim,{ramdiskoptions}
bcdedit /store %bcd_path% /set {%guid51x64%} osdevice ramdisk=[boot]\sources\winpe_5.1_amd64.wim,{ramdiskoptions}
bcdedit /store %bcd_path% /set {%guid51x64%} locale en-US
bcdedit /store %bcd_path% /set {%guid51x64%} inherit {bootloadersettings}
bcdedit /store %bcd_path% /set {%guid51x64%} path "\windows\system32\boot\winload.efi"
bcdedit /store %bcd_path% /set {%guid51x64%} systemroot \windows
bcdedit /store %bcd_path% /set {%guid51x64%} detecthal Yes
bcdedit /store %bcd_path% /set {%guid51x64%} winpe Yes
bcdedit /store %bcd_path% /set {%guid51x64%} ems No
echo.
echo.
rem Build BOOTMGR setting
echo Build BOOTMGR setting
echo.
bcdedit /store %bcd_path% /create {bootmgr}
bcdedit /store %bcd_path% /set {bootmgr} description "Windows Boot Manager"
bcdedit /store %bcd_path% /set {bootmgr} locale en-US
bcdedit /store %bcd_path% /set {bootmgr} inherit {globalsettings}
bcdedit /store %bcd_path% /set {bootmgr} toolsdisplayorder {memdiag}
bcdedit /store %bcd_path% /set {bootmgr} timeout 20
echo.
echo.
rem adjust boot sequence
echo adjust boot sequence
echo.
bcdedit /store %bcd_path% /set {bootmgr} displayorder {%guid60x86%} {%guid60x64%} {%guid51x86%} {%guid51x64%}
echo.
echo.
rem Windows Memory Diagnostic
echo Windows Memory Diagnostic
echo.
bcdedit /store %bcd_path% /create {memdiag}
bcdedit /store %bcd_path% /set {memdiag} device boot
bcdedit /store %bcd_path% /set {memdiag} path \boot\memtest.exe
bcdedit /store %bcd_path% /set {bootmgr} description "Windows Memory Diagnostic"
bcdedit /store %bcd_path% /set {memdiag} locale en-US
bcdedit /store %bcd_path% /set {memdiag} inherit {globalsettings}
echo.
echo.
rem EMS setting
echo EMS setting
echo.
bcdedit /store %bcd_path% /create {emssettings}
bcdedit /store %bcd_path% /set {emssettings} bootems No ::if this setting is "Yes", then the ems who all of "Windows Boot Manager" also set to "Yes".
echo.
echo.
rem Windows debug setting
echo Windows debug setting
echo.
bcdedit /store %bcd_path% /create {dbgsettings}
bcdedit /store %bcd_path% /set {dbgsettings} debugtype Serial
bcdedit /store %bcd_path% /set {dbgsettings} debugport 1
bcdedit /store %bcd_path% /set {dbgsettings} baudrate 116000
echo.
echo.
rem common setting
echo common setting
echo.
bcdedit /store %bcd_path% /create {globalsettings}
bcdedit /store %bcd_path% /set {globalsettings} inherit {dbgsettings} {emssettings}
echo.
echo.
rem bootloadersettings
echo boot loader setting
echo.
bcdedit /store %bcd_path% /create {bootloadersettings}
bcdedit /store %bcd_path% set {bootloadersettings} inherit {globalsettings} {hypervisorsettings}
echo.
echo.
rem Hypervisor setting
echo Hypervisor setting
echo.
bcdedit /store %bcd_path% /create {hypervisorsettings}
bcdedit /store %bcd_path% /set {hypervisorsettings} description "Hypervisor Setting"
bcdedit /store %bcd_path% /set {hypervisorsettings} hypervisordebugtype Serial
bcdedit /store %bcd_path% /set {hypervisorsettings} hypervisordebugport 1
bcdedit /store %bcd_path% /set {hypervisorsettings} hypervisorbaudrate 116000
echo.
echo.
rem Build ramdisk setting
echo Build ramdisk setting
echo.
bcdedit /store %bcd_path% /create {ramdiskoptions}
bcdedit /store %bcd_path% /set {ramdiskoptions} ramdisksdidevice boot
bcdedit /store %bcd_path% /set {ramdiskoptions} ramdisksdipath \boot\boot.sdi
::bcdedit /store %bcd_path% /create {ramdiskoptions} /d "Ramdisk options" ::don't add this line if wanna execute multi-boot.
echo.
echo.
rem show bcdedit current status
echo show bcdedit current status
echo.
bcdedit /store %bcd_path% /enum all
echo.
pause