@echo off

:: Author:Joshua Chang
:: Date:Sep 26 2014
:: Updated by : Joshua Chang 08/10/2015

set arch=%processor_architecture%
set currentpath=%cd%
cd %~dp0
cd ..
echo %cd%
cls
echo.
echo.
echo Please use "Deployment and Imaging Tools Environment" and then select run as administrator. 
echo.
echo If yes done please press any key to continue, or check "Ctrl + C" to leave.
pause
echo.
echo.
echo ===============================================================
echo == Create a set of either 32-bit and 64-bit Windows PE files ==
echo ===============================================================
::WinPERoot=%KitsRoot%Assessment and Deployment Kit\Windows Preinstallation Environment
if /I %arch%==AMD64(cd %WinPERoot%)else if /I %arch%==x86(cd %WinPERoot%)else(echo "System can't compatibility!!" pause cd %currentpath%)
echo The 64-bit version can boot 64-bit UEFI and 64-bit BIOS PCs
start copype.cmd amd64 C:\WinPE_amd64

echo The 32-bit version can boot 32-bit UEFI and 32-bit BIOS PCs
start copype.cmd x86 C:\WinPE_x86

cd %currentpath%