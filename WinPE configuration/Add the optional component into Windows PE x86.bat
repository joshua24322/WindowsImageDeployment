@echo off

:: Author:Joshua Chang
:: Date:Sep 26 2014
:: Updated by : Joshua Chang 08/11/2015

setlocalenabledelayedexpansion
set arch=%processor_architecture%
set currentpath=%cd%
::WinPERoot=%KitsRoot%Assessment and Deployment Kit\Windows Preinstallation Environment
set ADK_x86WinPE_OCs=%WinPERoot%\x86\WinPE_OCs
cd %~dp0
cd ..
echo %cd%

::if /I %arch%==AMD64 (
::	set "ProgramFilesPath=%ProgramFiles(x86)%"
::    ) else if /I %arch%==x86 (
::	set "ProgramFilesPath=%ProgramFiles%"
::	)
::set ADK_x86WinPE_OCs="%ProgramFilesPath%\Windows Kits\8.1\Assessment and Deployment Kit\Windows Preinstallation Environment\x86\WinPE_OCs"
::set ADK_x64WinPE_OCs="%ProgramFilesPath%\Windows Kits\8.1\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs"

cls
echo Applies To: Windows 8, Windows 8.1, Windows 10, Windows Server 2012, Windows Server 2012 R2
echo Add feature packages, also known as optional components, to Windows PE (WinPE).
echo Please use "Deployment and Imaging Tools Environment" and then select run as administrator. 
echo.
echo If yes done please press any key to continue, or check "Ctrl + C" to leave.
pause
echo.
echo.
echo =========================================
echo == Mount the Windows PE x86 boot image ==
echo =========================================

Dism /Mount-Image /ImageFile:"C:\WinPE_x86\media\sources\boot.wim" /index:1 /MountDir:"C:\WinPE_x86\mount"
echo.
echo.
echo Add temporary storage (scratch space) 

Dism /Set-ScratchSpace:512 /Image:"C:\WinPE_x86\mount"
echo.
echo.
echo ====================================================
echo == Add the optional component into Windows PE x86 ==
echo ====================================================

echo Fonts - WinPE-FontSupport-language

dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\WinPE-FontSupport-JA-JP.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\WinPE-FontSupport-ZH-CN.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\WinPE-FontSupport-ZH-TW.cab" /LogPath:AddOptionalComponent.log
echo.
echo.
echo Fonts - WinPE-FontSupport-WinRE

dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\WinPE-FontSupport-WinRE.cab" /LogPath:AddOptionalComponent.log
echo.
echo.
echo HTML - WinPE-HTA

dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\WinPE-HTA.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\en-us\WinPE-HTA_en-us.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\ja-jp\WinPE-HTA_ja-jp.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\zh-cn\WinPE-HTA_zh-cn.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\zh-tw\WinPE-HTA_zh-tw.cab" /LogPath:AddOptionalComponent.log
echo.
echo.
echo Scripting - WinPE-WMI

dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\WinPE-WMI.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\en-us\WinPE-WMI_en-us.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\ja-jp\WinPE-WMI_ja-jp.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\zh-cn\WinPE-WMI_zh-cn.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\zh-tw\WinPE-WMI_zh-tw.cab" /LogPath:AddOptionalComponent.log
echo.
echo.
echo Microsoft .NET - WinPE-NetFX
::Dependencies: Install WinPE-WMI before you install WinPE-NetFX.
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\WinPE-NetFx.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\en-us\WinPE-NetFx_en-us.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\ja-jp\WinPE-NetFx_ja-jp.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\zh-cn\WinPE-NetFx_zh-cn.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\zh-tw\WinPE-NetFx_zh-tw.cab" /LogPath:AddOptionalComponent.log
echo.
echo.
echo Scripting - WinPE-Scripting

dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\WinPE-Scripting.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\en-us\WinPE-Scripting_en-us.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\ja-jp\WinPE-Scripting_ja-jp.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\zh-cn\WinPE-Scripting_zh-cn.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\zh-tw\WinPE-Scripting_zh-tw.cab" /LogPath:AddOptionalComponent.log
echo.
echo.
echo Network - WinPE-WDS-Tools

dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\WinPE-WDS-Tools.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\en-us\WinPE-WDS-Tools_en-us.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\ja-jp\WinPE-WDS-Tools_ja-jp.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\zh-cn\WinPE-WDS-Tools_zh-cn.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\zh-tw\WinPE-WDS-Tools_zh-tw.cab" /LogPath:AddOptionalComponent.log
echo.
echo.
echo Windows PowerShell - WinPE-PowerShell
::Dependencies: Install WinPE-WMI > WinPE-NetFX > WinPE-Scripting before you install WinPE-PowerShell.
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\WinPE-PowerShell.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\en-us\WinPE-PowerShell_en-us.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\ja-jp\WinPE-PowerShell_ja-jp.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\zh-cn\WinPE-PowerShell_zh-cn.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\zh-tw\WinPE-PowerShell_zh-tw.cab" /LogPath:AddOptionalComponent.log
echo.
echo.
echo Windows PowerShell - WinPE-DismCmdlets
::Dependencies: Install WinPE-WMI > WinPE-NetFX > WinPE-Scripting > WinPE-PowerShell before you install WinPE-DismCmdlets.
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\WinPE-DismCmdlets.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\en-us\WinPE-DismCmdlets_en-us.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\ja-jp\WinPE-DismCmdlets_ja-jp.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\zh-cn\WinPE-DismCmdlets_zh-cn.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\zh-tw\WinPE-DismCmdlets_zh-tw.cab" /LogPath:AddOptionalComponent.log
echo.
echo.
echo Windows PowerShell - WinPE-SecureBootCmdlets
::Dependencies: Install WinPE-WMI > WinPE-NetFX > WinPE-Scripting > WinPE-PowerShell before you install WinPE-SecureBootCmdlets.
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\WinPE-SecureBootCmdlets.cab" /LogPath:AddOptionalComponent.log
echo.
echo.
echo Windows PowerShell - WinPE-StorageWMI
::Dependencies: Install WinPE-WMI > WinPE-NetFX > WinPE-Scripting > WinPE-PowerShell before you install WinPE-StorageWMI.
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\WinPE-StorageWMI.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\en-us\WinPE-StorageWMI_en-us.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\ja-jp\WinPE-StorageWMI_ja-jp.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\zh-cn\WinPE-StorageWMI_zh-cn.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\zh-tw\WinPE-StorageWMI_zh-tw.cab" /LogPath:AddOptionalComponent.log
echo.
echo.
echo Storage - WinPE-EnhancedStorage

dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\WinPE-EnhancedStorage.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\en-us\WinPE-EnhancedStorage_en-us.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\ja-jp\WinPE-EnhancedStorage_ja-jp.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\zh-cn\WinPE-EnhancedStorage_zh-cn.cab" /LogPath:AddOptionalComponent.log
dism /image:"C:\WinPE_x86\mount" /add-package /packagepath:"%ADK_x86WinPE_OCs%\zh-tw\WinPE-EnhancedStorage_zh-tw.cab" /LogPath:AddOptionalComponent.log
echo.
echo.
echo.
echo.
echo Verify that the optional component is part of the image 
echo and you can find the log in "c:\Add the optional component into Windows PE.txt"

Dism /Get-Packages /Image:"C:\WinPE_x86\mount" /format:list >> "c:\Add the optional component into Windows PE.txt"

echo.
echo.
echo Unmount the Windows PE image
dism /unmount-image /mountdir:"C:\WinPE_x86\mount" /commit

cd %currentpath%