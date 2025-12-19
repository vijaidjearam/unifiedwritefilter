@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ============================================================
REM UWF-Defender-Exclusions-SAFE.cmd
REM Adds UWF exclusions for Microsoft Defender AV + your extra
REM file exclusions (ATP folder, wd drivers folder, printers spool).
REM Avoids broad WdFilter exclusion due to known hang risk.
REM Optional: /reboot  and /commit-wdfilter
REM ============================================================

REM --- Admin check ---
net session >nul 2>&1
if not "%errorlevel%"=="0" (
  echo [ERROR] Please run this script as Administrator.
  exit /b 1
)

set DO_REBOOT=0
set DO_COMMIT_WDFILTER=0

if /I "%~1"=="/reboot" set DO_REBOOT=1
if /I "%~1"=="/commit-wdfilter" set DO_COMMIT_WDFILTER=1
if /I "%~2"=="/reboot" set DO_REBOOT=1
if /I "%~2"=="/commit-wdfilter" set DO_COMMIT_WDFILTER=1

echo ============================================================
echo [INFO] Applying SAFE UWF exclusions for Microsoft Defender...
echo ============================================================

REM --- Helper commands ---
set FILE_EXCLUSIONS_CMD=uwfmgr file get-exclusions C:
set REG_EXCLUSIONS_CMD=uwfmgr registry get-exclusions

REM ------------------------------------------------------------
REM FILE EXCLUSIONS
REM Includes Microsoft-recommended Defender exclusions + your extras:
REM  - Defender ATP folder
REM  - wd drivers folder
REM  - PRINTERS spool folder
REM ------------------------------------------------------------
for %%P in (
  "C:\ProgramData\Microsoft\Windows Defender"
  "C:\Program Files\Windows Defender"
  "C:\Program Files\Windows Defender Advanced Threat Protection"
  "C:\Windows\System32\drivers\wd"
  "C:\Windows\System32\spool\PRINTERS"
  "C:\Windows\WindowsUpdate.log"
  "C:\Windows\Temp\MpCmdRun.log"
) do (
  call :EnsureFileExclusion %%P
)

REM ------------------------------------------------------------
REM REGISTRY EXCLUSIONS (Microsoft Defender on UWF requirements)
REM ------------------------------------------------------------
for %%K in (
  "HKLM\SOFTWARE\Microsoft\Windows Defender"
  "HKLM\SYSTEM\CurrentControlSet\Services\WdBoot"
  "HKLM\SYSTEM\CurrentControlSet\Services\WdNisSvc"
  "HKLM\SYSTEM\CurrentControlSet\Services\WdNisDrv"
  "HKLM\SYSTEM\CurrentControlSet\Services\WinDefend"
) do (
  call :EnsureRegExclusion %%K
)

REM Optional extras you already used (kept separate; not required by the MS minimum list)
call :EnsureRegExclusion "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender"
call :EnsureRegExclusion "HKLM\SOFTWARE\Microsoft\Windows Defender Advanced Threat Protection"

echo.
echo [INFO] Done adding exclusions.
echo [INFO] Current exclusions (summary):
echo ------------------------------------------------------------
uwfmgr file get-exclusions C:
echo ------------------------------------------------------------
uwfmgr registry get-exclusions
echo ------------------------------------------------------------
echo.

REM --- Optional: apply Microsoft workaround commits for WdFilter values ---
if "%DO_COMMIT_WDFILTER%"=="1" (
  echo [INFO] Applying optional WdFilter value commits (workaround approach)...
  call :CommitWdFilterValues
)

echo.
if "%DO_REBOOT%"=="1" (
  echo [INFO] Rebooting now so UWF exclusions apply to next session...
  shutdown /r /t 0
) else (
  echo [ACTION] Please reboot when convenient so UWF exclusions apply.
  echo [TIP] Re-run 'uwfmgr get-config' after reboot to confirm.
)

exit /b 0


:EnsureFileExclusion
set "PATH_TO_ADD=%~1"
%FILE_EXCLUSIONS_CMD% | findstr /I /C:"%PATH_TO_ADD%" >nul 2>&1
if "%errorlevel%"=="0" (
  echo [OK] File exclusion already present: %PATH_TO_ADD%
) else (
  echo [ADD] File exclusion: %PATH_TO_ADD%
  uwfmgr file add-exclusion "%PATH_TO_ADD%"
  if not "%errorlevel%"=="0" echo [WARN] Failed to add file exclusion: %PATH_TO_ADD%
)
exit /b 0


:EnsureRegExclusion
set "KEY_TO_ADD=%~1"
%REG_EXCLUSIONS_CMD% | findstr /I /C:"%KEY_TO_ADD%" >nul 2>&1
if "%errorlevel%"=="0" (
  echo [OK] Registry exclusion already present: %KEY_TO_ADD%
) else (
  echo [ADD] Registry exclusion: %KEY_TO_ADD%
  uwfmgr registry add-exclusion "%KEY_TO_ADD%"
  if not "%errorlevel%"=="0" echo [WARN] Failed to add registry exclusion: %KEY_TO_ADD%
)
exit /b 0


:CommitWdFilterValues
REM Microsoft warns that excluding HKLM...\WdFilter may cause startup hangs,
REM and provides commit-values workaround instead.
for %%V in (
  DependOnService
  Description
  DisplayName
  ErrorControl
  Group
  ImagePath
  Start
  SupportedFeatures
  Type
) do (
  uwfmgr.exe registry commit "HKLM\SYSTEM\CurrentControlSet\Services\WdFilter" %%V
)

uwfmgr.exe registry commit "HKLM\SYSTEM\CurrentControlSet\Services\WdFilter\Instances" DefaultInstance
uwfmgr.exe registry commit "HKLM\SYSTEM\CurrentControlSet\Services\WdFilter\Instances\WdFilter Instance" Altitude
uwfmgr.exe registry commit "HKLM\SYSTEM\CurrentControlSet\Services\WdFilter\Instances\WdFilter Instance" Flags
uwfmgr.exe registry commit "HKLM\SYSTEM\CurrentControlSet\Services\WdFilter\Security" Security

echo [OK] WdFilter value commits executed.
exit /b 0
