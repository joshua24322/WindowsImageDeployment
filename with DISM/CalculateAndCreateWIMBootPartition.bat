rem refer and copy from microsoft website: https://technet.microsoft.com/en-us/library/dn594395.aspx
goto __start
/*************************************************************
          Sample Script: CalculateAndCreateWIMBootPartition.cmd

Use this script to calculate the size needed for the WIMBoot
Images partition after applying your final factory settings.

Prerequisites:
- Boot the PC into Windows PE 5.1
 - The primary hard drive (disk 0) has three partitions:
     1. System partition (ESP)
     2. MSR
     3. Windows partition - the rest of disk 0
        - install.wim is in this partition
        - install.wim has been applied to this same partition
 - Complete the final factory floor customization
 - Capture custom.wim, and store it in the Windows partition, in the same folder as install.wim
 - Customize winre.wim, and store it in the Windows partition

After this script is run:
- The primary hard drive (disk 0) has four partitions:
     1. System partition (ESP)
     2. MSR
     3. Windows partition (calculated)
     4. Images partition (calculated)
The Images partition will include:
 - install.wim, custom.wim, winre.wim
 - Any other OEM tools/scripts
 - 50 MB of additional free space
**************************************************************/

REM The script starts here
:__start
@echo off
echo %date%-%time%:: Start of script %0 ,,,

if "%1" equ "" (
 echo This script calculates the size needed for the Images partition and sets it up.
 echo Usage:
 echo CalculateAndCreateWIMBootPartition.cmd ^<letter of Windows volume^> ^<path to install.wim and custom.wim^> ^<path to winre.wim^> ^<additional free space to be added to Images partition in megabytes. If no additional space is needed, use 0.^>
 echo Example:
 echo CalculateAndCreateWIMBootPartition C: C:\Recycler\WIMs\ C:\Recycler\WIMs 300
 exit /b 0
)



REM --- Constants used to calculate free space ---
REM Overhead Ratio: assume 6 MB overhead per 1000 MB size
set /a NTFS_OVERHEAD_RATIO=500/497
REM Per-Partition Overhead: 5 MB per partition
set /a NTFS_OVERHEAD_BASE=5

REM Megabytes-to-Millions Ratio:
REM This ratio converts values from megabytes to millions of bytes, approximately. 
set /a mega_million_ratio=205/215
REM --------- Constants -------------


REM Drive letter of the Windows partition. Example: C:
set user_volume=%1

REM Path that contains install.wim and custom.wim. Example: C:\Recycler\WIMs\
set wimfile_path=%2

REM Path that contains winre.wim. Example: C:\Recycler\WIMs
set winre_wim_path=%3

REM Additional size to be added to Images partition in megabytes. Example: 300
set more_size=%4


echo Check input Windows volume {%user_volume%} is accessible:
echo dir %user_volume%\ /a
     dir %user_volume%\ /a
if not exist %user_volume%\ (
 echo %user_volume%\ not found. Exiting script.
pause
 exit /b 3
)


echo Check if the install.wim and custom.wim files {%wimfile_path%} are accessible:
echo dir %wimfile_path%\ /a
     dir %wimfile_path%\ /a

if not exist %wimfile_path%\install.wim (
 echo %wimfile_path%\install.wim not found. Exiting script.
pause
 exit /b 3
)
if not exist %wimfile_path%\custom.wim (
 echo %wimfile_path%\Custom.wim not found. Exiting script.
pause
 exit /b 3
)

echo Check if the winre.wim file {%winre_wim_path%}  is accessible:
echo dir %winre_wim_path%\ /a
     dir %winre_wim_path%\ /a
if not exist %winre_wim_path%\winre.wim  (
echo %winre_wim_path%\winre.wim not found. Exiting script.
 exit /b 3
)


echo --------- Calculate install.wim size ,,,
for %%A in (%wimfile_path%\install.wim) do ( 
set install_wim_file_bytes=%%~zA
echo install.wim is [%install_wim_file_bytes%] bytes.
)
set /a install_wim_file_MB=%install_wim_file_bytes:~0,-6%+0
echo After cutting off last 6 digits = [%install_wim_file_MB%]
set /a install_wim_file_MB=%install_wim_file_MB%*205/215
echo Final approximate size: [%install_wim_file_MB%] MB

echo --------- Calculate custom.wim size ,,,
for %%A in (%wimfile_path%\custom.wim) do ( 
set custom_wim_file_bytes=%%~zA
echo custom.wim is [%custom_wim_file_bytes%] bytes.
)
set /a custom_wim_file_MB=%custom_wim_file_bytes:~0,-6%
echo After cutting off last 6 digits = [%custom_wim_file_MB%]
set /a custom_wim_file_MB=%custom_wim_file_MB%*205/215
echo Final approximate size: [%custom_wim_file_MB%] MB

echo --------- Calculate {%winre_wim_path%\winre.wim} size ,,,
for %%A in (%winre_wim_path%\winre.wim) do ( 
set winre_wim_file_bytes=%%~zA
echo winre.wim is [%winre_wim_file_bytes%] bytes.
)
set /a winre_wim_file_MB=%winre_wim_file_bytes:~0,-6%
echo After cutting off last 6 digits = [%winre_wim_file_MB%]
set /a winre_wim_file_MB=%winre_wim_file_MB%*205/215
echo Final approximate size: [%winre_wim_file_MB%] MB


echo Calculate Images partition size ,,,
echo Adding 50MB free space to input size {%more_size%}. This ensures Images partition have 50MB free space.
set /a more_size=%more_size%+50
set /a wim_partition_size_MB=%install_wim_file_MB%+%custom_wim_file_MB%
echo Size sum of install.wim and custom.wim = {%wim_partition_size_MB%} MB
set /a wim_partition_size_MB=%wim_partition_size_MB%+%winre_wim_file_MB%
echo Total size of the 3 .WIM files = {%wim_partition_size_MB%} MB

set /a wim_partition_size_MB=%wim_partition_size_MB%+%more_size%
echo Size after adding specified space and 50MB = {%wim_partition_size_MB%} MB
set /a wim_partition_size_MB=%wim_partition_size_MB%+%NTFS_OVERHEAD_BASE%
set /a wim_partition_size_MB=%wim_partition_size_MB%*500/497
echo Final Images partition size = {%wim_partition_size_MB%} MB

echo Remove the hibernation file, if it exists.
icacls C:\hiberfil.sys /grant everyone:f
del C:\hiberfil.sys /ah

echo Find out if we are in BIOS mode, or UEFI mode,,,
echo reg query HKLM\System\CurrentControlSet\Control /v PEFirmwareType
     reg query HKLM\System\CurrentControlSet\Control /v PEFirmwareType
for /f "tokens=2*" %%X in ('reg query HKLM\System\CurrentControlSet\Control /v PEFirmwareType') DO (SET _Firmware=%%Y)

if %_Firmware%==0x1 (
  echo The PC is booted in BIOS mode. Note: BIOS is not supported for WIMBoot.  Exiting script.
pause
 exit /b 3
)

if %_Firmware%==0x2 echo The PC is booted in UEFI mode.

echo Create a diskpart script to shrink Windows partition {%user_volume%} by desired size of {%wim_partition_size_MB%} ,,
set wim_partition_letter=M:
echo. > %~dp0dps.txt
echo list disk >> %~dp0dps.txt
echo list volume >> %~dp0dps.txt
echo select disk 0 >> %~dp0dps.txt
echo list partition >> %~dp0dps.txt
echo select volume %user_volume% >> %~dp0dps.txt
echo list partition >> %~dp0dps.txt
echo list volume >> %~dp0dps.txt
echo shrink minimum=%wim_partition_size_MB% >> %~dp0dps.txt
echo list partition >> %~dp0dps.txt
echo list volume >> %~dp0dps.txt
echo create partition primary size=%wim_partition_size_MB% >> %~dp0dps.txt
rem  BIOS ONLY (Does not apply to WIMBoot): echo set id=27 OVERRIDE NOERR >> %~dp0dps.txt
echo set id=de94bba4-06d1-4d40-a16a-bfd50179d6ac OVERRIDE NOERR >> %~dp0dps.txt
if %_Firmware%==0x2 (
echo gpt attributes=0x8000000000000001 >> %~dp0dps.txt
)
echo list volume >> %~dp0dps.txt
echo list partition >> %~dp0dps.txt
echo format quick fs=ntfs label=images >> %~dp0dps.txt
echo assign letter=%wim_partition_letter% >> %~dp0dps.txt
echo list volume >> %~dp0dps.txt
echo list partition >> %~dp0dps.txt
echo exit >> %~dp0dps.txt

echo =================== the script has:
type  %~dp0dps.txt
echo ==================================

echo %date%-%time%:: Running diskpart /s %~dp0dps.txt ,,,
diskpart /s %~dp0dps.txt 

echo dir %wim_partition_letter%\
dir %wim_partition_letter%\

md "%wim_partition_letter%\Windows Images"
md "%wim_partition_letter%\Recovery\WindowsRE"

robocopy %wimfile_path%\ "%wim_partition_letter%\Windows Images"\ install.wim
robocopy %wimfile_path%\ "%wim_partition_letter%\Windows Images"\ custom.wim
echo dir %wim_partition_letter%\
dir %wim_partition_letter%\
echo dir "%wim_partition_letter%\Windows Images"
dir "%wim_partition_letter%\Windows Images"

echo dir %winre_wim_path%\winre.wim
     dir %winre_wim_path%\winre.wim
echo robocopy %winre_wim_path%\ %wim_partition_letter%\Recovery\WindowsRE\ winre.wim 
     robocopy %winre_wim_path%\ %wim_partition_letter%\Recovery\WindowsRE\ winre.wim 
)

rem Register Windows RE
echo %date%-%time%:: %user_volume%\Windows\System32\reagentc.exe /setreimage /path %wim_partition_letter%\Recovery\WindowsRE /target %user_volume%\Windows
      %user_volume%\Windows\System32\reagentc.exe /setreimage /path %wim_partition_letter%\Recovery\WindowsRE /target %user_volume%\Windows

echo %date%-%time%:: Running Dism /english /logpath=%wimfile_path%\dism.log /scratchdir=%wimfile_path%\ /get-wimbootentry /path=%user_volume%\  piping into %~dp0temp.txt ,,,
      dism /english /logpath=%wimfile_path%\dism.log /scratchdir=%wimfile_path%\ /get-wimbootentry /path=%user_volume%\ 1> %~dp0temp.txt 2>&1
type %~dp0temp.txt

set output_text=%~dp0temp.txt

find /i "install.wim" %output_text%
if %errorlevel% neq 0 (
 echo The file: install.wim not found. Script failed, exiting.
pause
 exit /b %errorlevel%
)

echo Found install.wim, good.

for /f "skip=4 tokens=1,2,3,4,5" %%a in (%output_text%) do (
 if /i "%%a %%b %%c %%d" equ "Data Source ID :" ( set ds_id_install_wim=%%e )
 if /i "%%~nxd" equ "install.wim" ( set wimfile_install_wim=%%~nxd & goto _end_for1 )
)
:_end_for1

echo dsid=%ds_id_install_wim%
echo wim=%wimfile_install_wim%


find /i "custom.wim" %output_text%
if %errorlevel% neq 0 (
 echo The file: custom.wim is not found. Script failed, exiting.
pause
 exit /b 2
)


echo Found custom.wim,
for /f "skip=4 tokens=1,2,3,4,5" %%a in (%output_text%) do (
 if /i "%%a %%b %%c %%d" equ "Data Source ID :" ( set ds_id_custom_wim=%%e )
 if /i "%%~nxd" equ "custom.wim" ( set wimfile_custom_wim=%%~nxd & goto _end_for2 )
)
:_end_for2

echo dsid=%ds_id_custom_wim%
echo wim=%wimfile_custom_wim%


echo %date%-%time%:: Running Dism /logpath=%wimfile_path%\dism.log /scratchdir=%wimfile_path%\ /update-wimbootentry /path=%user_volume%\ /imagefile="%wim_partition_letter%\Windows Images\install.wim" /datasourceID=%ds_id_install_wim% ,,,
dism /logpath=%wimfile_path%\dism.log /scratchdir=%wimfile_path%\ /update-wimbootentry /path=%user_volume%\ /imagefile="%wim_partition_letter%\Windows Images\install.wim" /datasourceID=%ds_id_install_wim%

echo %date%-%time%:: Running Dism /logpath=%wimfile_path%\dism.log /scratchdir=%wimfile_path%\ /update-wimbootentry /path=%user_volume%\ /imagefile="%wim_partition_letter%\windows images\custom.wim" /datasourceID=%ds_id_custom_wim% ,,,
dism /logpath=%wimfile_path%\dism.log /scratchdir=%wimfile_path%\ /update-wimbootentry /path=%user_volume%\ /imagefile="%wim_partition_letter%\Windows Images\custom.wim" /datasourceID=%ds_id_custom_wim%


if %errorlevel% neq 0 (
 echo ERROR: Dism failed. Exiting script.
pause
 exit /b %errorlevel%
)

rd /q/s c:\Recycler\

echo Setting permissions (ACLS) on "%wim_partition_letter%\Windows Images" ,,, 
icacls "%wim_partition_letter%\Windows Images" /grant:r SYSTEM:(F) /T 
icacls "%wim_partition_letter%\Windows Images" /inheritance:r /T 
icacls "%wim_partition_letter%\Windows Images" /grant:r *S-1-5-32-544:(R) /T
icacls "%wim_partition_letter%\Windows Images" /grant:r SYSTEM:(R) /T 


echo %date%-%time%:: All done.  Errorlevel={%errorlevel%}
dir %wim_partition_letter%\ /s /a

echo *************** PLEASE MAKE SURE TO BOOT THE OS 
echo  IN ORDER TO LET NEW WIMBOOT ENTRIES TAKE EFFECT *****************
echo ------- After booted to the OS, you can delete the .wim files under 
echo  {%wimfile_path%} to regain space on Windows partition {%user_volume%} 
echo ----------------

pause
goto :EOF