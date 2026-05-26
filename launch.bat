@echo off
setlocal enabledelayedexpansion

REM ============================================================================
REM PicoClaw Agent - Portable Launcher (Windows)
REM ============================================================================
REM Double-click this file to launch PicoClaw.
REM On first run, it downloads the official Sipeed Windows zip (~20 MB) for
REM your architecture, verifies its SHA256 against scripts\release.config,
REM and stages picoclaw.exe inside .cache\.
REM
REM All user state (config, secrets, sessions, memory) lives in data\ on the
REM portable drive. Nothing is written to your real Windows profile.
REM ============================================================================

REM --- Resolve portable root ---------------------------------------------------
set "PORTABLE_ROOT=%~dp0"
set "PORTABLE_ROOT=%PORTABLE_ROOT:~0,-1%"

REM --- Detect architecture (host arch, even on WOW64) -------------------------
set "HOSTARCH=%PROCESSOR_ARCHITEW6432%"
if "%HOSTARCH%"=="" set "HOSTARCH=%PROCESSOR_ARCHITECTURE%"
set "PCARCH=x86_64"
if /I "%HOSTARCH%"=="ARM64" set "PCARCH=aarch64"
if /I "%HOSTARCH%"=="AMD64" set "PCARCH=x86_64"

set "CACHE_DIR=%PORTABLE_ROOT%\.cache"
set "RUNTIME_DIR=%CACHE_DIR%\runtimes\windows-%PCARCH%"
set "PICOCLAW_BIN=%RUNTIME_DIR%\picoclaw.exe"
set "DATA_DIR=%PORTABLE_ROOT%\data"
set "WORKSPACE_DIR=%DATA_DIR%\workspace"
set "CONFIG_PATH=%DATA_DIR%\config.json"

REM --- First-run / repair setup ----------------------------------------------
if not exist "%RUNTIME_DIR%\ready.flag" goto :run_setup
if not exist "%PICOCLAW_BIN%" goto :run_setup
goto :setup_done

:run_setup
echo.
echo ============================================
echo    PicoClaw Portable - Setup
echo ============================================
echo  Downloading official binary for windows-%PCARCH%
echo  and verifying its SHA256 hash.
echo ============================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%PORTABLE_ROOT%\scripts\setup-windows.ps1" -Root "%PORTABLE_ROOT%"
if errorlevel 1 (
    echo.
    echo [ERROR] Setup failed. Check internet, then re-run launch.bat.
    pause
    exit /b 1
)

:setup_done

REM --- Make sure the data folder structure exists -----------------------------
if not exist "%DATA_DIR%"      mkdir "%DATA_DIR%"
if not exist "%WORKSPACE_DIR%" mkdir "%WORKSPACE_DIR%"

REM --- Environment isolation --------------------------------------------------
REM PicoClaw natively honors PICOCLAW_HOME and PICOCLAW_CONFIG, so we just
REM point them at the drive's data/ folder. Works on NTFS, exFAT, and FAT32
REM with no symlinks or junctions required.
set "PATH=%RUNTIME_DIR%;%PATH%"
set "PICOCLAW_HOME=%DATA_DIR%"
set "PICOCLAW_CONFIG=%CONFIG_PATH%"
set "PICOCLAW_BINARY=%PICOCLAW_BIN%"

REM Keep tools that resolve %APPDATA% / %USERPROFILE% inside the portable folder
set "APPDATA=%CACHE_DIR%\win-appdata"
set "LOCALAPPDATA=%CACHE_DIR%\win-localappdata"
if not exist "%APPDATA%"      mkdir "%APPDATA%"
if not exist "%LOCALAPPDATA%" mkdir "%LOCALAPPDATA%"

REM ---------------------------------------------------------------------------
REM Pass-through mode: launch.bat <args> -> picoclaw.exe <args>
REM If the first arg is literally "picoclaw", drop it so users can paste docs
REM verbatim. We use a shift+rebuild loop so quoted args survive.
REM ---------------------------------------------------------------------------
if /I "%~1"=="picoclaw" (
    shift
    set "PT="
    call :build_passthrough %1 %2 %3 %4 %5 %6 %7 %8 %9
    "%PICOCLAW_BIN%" !PT!
    exit /b %ERRORLEVEL%
)

if not "%~1"=="" (
    "%PICOCLAW_BIN%" %*
    exit /b %ERRORLEVEL%
)

goto :after_passthrough

:build_passthrough
:bp_loop
if "%~1"=="" goto :eof
if defined PT (set "PT=!PT! %1") else (set "PT=%1")
shift
goto :bp_loop

:after_passthrough

REM ---------------------------------------------------------------------------
REM ANSI Colors
REM ---------------------------------------------------------------------------
for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "RESET=%ESC%[0m"
set "BOLD=%ESC%[1m"
set "DIM=%ESC%[2m"
set "CYAN=%ESC%[36m"
set "BCYAN=%ESC%[96m"
set "GREEN=%ESC%[32m"
set "BGREEN=%ESC%[92m"
set "YELLOW=%ESC%[33m"
set "BYELLOW=%ESC%[93m"
set "RED=%ESC%[31m"
set "WHITE=%ESC%[37m"
set "BWHITE=%ESC%[97m"
set "GRAY=%ESC%[90m"

REM ---------------------------------------------------------------------------
REM Status detection
REM ---------------------------------------------------------------------------
:detect_status
set "SETUP_STATUS=Not configured"
set "SETUP_ICON=[x]"
set "SETUP_COLOR=%RED%"
set "MODEL_NAME="
set "PROVIDER_NAME="
set "GATEWAY_STATUS=Stopped"
set "GATEWAY_COLOR=%GRAY%"
set "GATEWAY_ICON=[ ]"

if exist "%CONFIG_PATH%" (
    findstr /R /C:"\"api_keys\"" /C:"\"api_key\"" "%CONFIG_PATH%" >nul 2>&1
    if not errorlevel 1 (
        set "SETUP_STATUS=Configured"
        set "SETUP_ICON=[OK]"
        set "SETUP_COLOR=%BGREEN%"
    )
    REM Pull "model_name": "..." from the active agent config.
    for /f "usebackq tokens=2 delims=:" %%a in (`findstr /R /C:"\"model_name\"" "%CONFIG_PATH%"`) do (
        if not defined MODEL_NAME (
            set "raw=%%a"
            set "raw=!raw:"=!"
            set "raw=!raw:,=!"
            set "raw=!raw: =!"
            set "MODEL_NAME=!raw!"
        )
    )
    REM Pull "provider": "..." line.
    for /f "usebackq tokens=2 delims=:" %%a in (`findstr /R /C:"\"provider\"" "%CONFIG_PATH%"`) do (
        if not defined PROVIDER_NAME (
            set "raw=%%a"
            set "raw=!raw:"=!"
            set "raw=!raw:,=!"
            set "raw=!raw: =!"
            set "PROVIDER_NAME=!raw!"
        )
    )
)

REM Detect a running gateway via "picoclaw status".
"%PICOCLAW_BIN%" status >nul 2>&1
if not errorlevel 1 (
    set "GATEWAY_STATUS=Running (127.0.0.1:18790)"
    set "GATEWAY_ICON=[OK]"
    set "GATEWAY_COLOR=%BGREEN%"
)

set "PC_VERSION=unknown"
if exist "%RUNTIME_DIR%\version.txt" (
    set /p PC_VERSION=<"%RUNTIME_DIR%\version.txt"
)

REM ---------------------------------------------------------------------------
REM Main menu
REM ---------------------------------------------------------------------------
:show_menu
echo.
echo %BCYAN%----------------------------------------------------------------%RESET%
echo %BOLD%%BWHITE%                   PICOCLAW PORTABLE LAUNCHER%RESET%
echo %DIM%%GRAY%               Ultra-efficient AI agent in Go (Sipeed)%RESET%
echo %BCYAN%----------------------------------------------------------------%RESET%
echo.
echo  %DIM%Setup%RESET%    !SETUP_COLOR!!SETUP_ICON!%RESET% %WHITE%!SETUP_STATUS!%RESET%
if defined PROVIDER_NAME echo  %DIM%Provider%RESET% %CYAN%!PROVIDER_NAME!%RESET%
if defined MODEL_NAME echo  %DIM%Model%RESET%    %WHITE%!MODEL_NAME!%RESET%
echo  %DIM%Gateway%RESET%  !GATEWAY_COLOR!!GATEWAY_ICON!%RESET% %WHITE%!GATEWAY_STATUS!%RESET%
echo  %DIM%Binary%RESET%   %GRAY%!PC_VERSION! ^(windows-%PCARCH%^)%RESET%
echo  %DIM%Data%RESET%     %GRAY%%DATA_DIR%%RESET%
echo.
echo %BCYAN%----------------------------------------------------------------%RESET%
echo.
echo  %BYELLOW%[1]%RESET%  %WHITE%Start PicoClaw chat%RESET%       %GRAY%(interactive agent)%RESET%
echo  %BYELLOW%[2]%RESET%  %WHITE%Onboard / Reconfigure%RESET%     %GRAY%(API keys, channels)%RESET%
echo  %BYELLOW%[3]%RESET%  %WHITE%Start gateway%RESET%             %GRAY%(127.0.0.1:18790)%RESET%
echo  %BYELLOW%[4]%RESET%  %WHITE%Advanced options%RESET%          %GRAY%--^>%RESET%
echo  %BYELLOW%[5]%RESET%  %GRAY%Exit%RESET%
echo.
choice /C 12345 /N /M "%BCYAN%Select option: %RESET%"
if errorlevel 5 goto :menu_exit
if errorlevel 4 goto :show_advanced
if errorlevel 3 goto :menu_gateway
if errorlevel 2 goto :menu_onboard
if errorlevel 1 goto :menu_chat
goto :show_menu

:menu_chat
echo.
"%PICOCLAW_BIN%" agent
goto :detect_status

:menu_onboard
echo.
"%PICOCLAW_BIN%" onboard
goto :detect_status

:menu_gateway
echo.
echo %CYAN%Starting gateway in a separate window ...%RESET%
start "PicoClaw Gateway" "%PICOCLAW_BIN%" gateway
timeout /t 2 /nobreak >nul
goto :detect_status

:menu_exit
echo.
echo %GRAY%Goodbye.%RESET%
echo.
exit /b 0

REM ---------------------------------------------------------------------------
REM Advanced menu
REM ---------------------------------------------------------------------------
:show_advanced
echo.
echo %BCYAN%----------------------------------------------------------------%RESET%
echo %BOLD%%BWHITE%                       Advanced Options%RESET%
echo %BCYAN%----------------------------------------------------------------%RESET%
echo.
echo  %BYELLOW%[1]%RESET%  %WHITE%Show status%RESET%             %GRAY%- check provider/channels%RESET%
echo  %BYELLOW%[2]%RESET%  %WHITE%Switch model%RESET%            %GRAY%- picoclaw model%RESET%
echo  %BYELLOW%[3]%RESET%  %WHITE%Edit config.json%RESET%        %GRAY%- open in notepad%RESET%
echo  %BYELLOW%[4]%RESET%  %WHITE%Update binary%RESET%           %GRAY%- bump to manifest version%RESET%
echo  %BYELLOW%[5]%RESET%  %WHITE%List MCP servers%RESET%        %GRAY%- picoclaw mcp list%RESET%
echo  %BYELLOW%[6]%RESET%  %WHITE%List skills%RESET%             %GRAY%- picoclaw skills list%RESET%
echo  %BYELLOW%[7]%RESET%  %GRAY%Back to main menu%RESET%
echo.
choice /C 1234567 /N /M "%BCYAN%Select option: %RESET%"
if errorlevel 7 goto :show_menu
if errorlevel 6 goto :adv_skills
if errorlevel 5 goto :adv_mcp
if errorlevel 4 goto :adv_update
if errorlevel 3 goto :adv_config
if errorlevel 2 goto :adv_model
if errorlevel 1 goto :adv_status
goto :show_advanced

:adv_status
echo.
"%PICOCLAW_BIN%" status
pause
goto :show_advanced

:adv_model
echo.
"%PICOCLAW_BIN%" model
pause
goto :show_advanced

:adv_config
if not exist "%CONFIG_PATH%" (
    echo %YELLOW%No config.json yet - run option [2] Onboard first.%RESET%
    pause
    goto :show_advanced
)
notepad "%CONFIG_PATH%"
goto :show_advanced

:adv_update
echo.
echo %CYAN%Refreshing binary against scripts\release.config ...%RESET%
powershell -NoProfile -ExecutionPolicy Bypass -File "%PORTABLE_ROOT%\scripts\setup-windows.ps1" -Root "%PORTABLE_ROOT%" -Force
pause
goto :show_advanced

:adv_mcp
echo.
"%PICOCLAW_BIN%" mcp list
pause
goto :show_advanced

:adv_skills
echo.
"%PICOCLAW_BIN%" skills list
pause
goto :show_advanced
