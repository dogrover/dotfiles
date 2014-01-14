@ECHO OFF
REM Default exit code is non-zero
SET EXIT_CODE=1

REM Windows XP and earlier not supported right now.
ver | find "Version 5"
IF "%ERRORLEVEL%" == "0" GOTO ERR_XPOrOlder
ver | find "Version 4"
IF "%ERRORLEVEL%" == "0" GOTO ERR_XPOrOlder

REM Base directory for the dotfiles repo
SET DOTFILES_DIR=%~dp0
SET LOG_FILE=%DOTFILES_DIR%\dotfiles_setup.log
ECHO Logging dotfiles setup to "%LOG_FILE%" > "%LOG_FILE%"

SET USER_PS_FOLDER=%USERPROFILE%\Documents\WindowsPowerShell

REM Check pre-requisites
REM --------------------
REM Check for GIT
git --help >NUL 2>&1
IF NOT "%ERRORLEVEL%" == "0" GOTO ERR_NoGit

REM Check for target files
IF NOT EXIST "%DOTFILES_DIR%\vim\vimrc" GOTO ERR_NoVimrc
IF NOT EXIST "%DOTFILES_DIR%\pentadactyl\pentadactylrc" GOTO ERR_NoPentarc
IF NOT EXIST "%DOTFILES_DIR%\powershell\powershell_profile.ps1" GOTO ERR_NoPowershellrc

REM Check for elevated permissions on Vista and above
NET FILE 1>NUL 2>NUL
IF NOT "%ERRORLEVEL%" == "0" GOTO ERR_NotAdmin

:ChecksAllPass

:SetupConEmu
REM Setup ConEmu
REM ------------

REM Create file links
ECHO Link ConEmu.xml settings
del "%APPDATA%\ConEmu.xml" >NUL 2>&1
mklink /H "%APPDATA%\ConEmu.xml" "%DOTFILES_DIR%\ConEmu\ConEmu.xml" >> "%LOG_FILE%" 2>&1

:SetupVim
REM Setup Vim
REM ---------

REM Create file links
ECHO Link _vimrc to dotfiles\vim\vimrc
mklink /H "%USERPROFILE%\_vimrc" "%DOTFILES_DIR%\vim\vimrc" >> "%LOG_FILE%" 2>&1
IF NOT "%ERRORLEVEL%" == "0" GOTO ERR_CreatingLink

ECHO Link .vim to dotfiles\vim
mklink /D "%USERPROFILE%\.vim" "%DOTFILES_DIR%\vim" >> "%LOG_FILE%" 2>&1
IF NOT "%ERRORLEVEL%" == "0" GOTO ERR_CreatingLink

REM Create working folders
ECHO Create Vim working folder
mkdir "%LOCALAPPDATA%\Vim" > "%LOG_FILE%" 2>&1
IF NOT "%ERRORLEVEL%" == "0" GOTO ERR_CreatingDir

ECHO Create Vim swap folder
mkdir "%LOCALAPPDATA%\Vim\swap" >> "%LOG_FILE%" 2>&1
IF NOT "%ERRORLEVEL%" == "0" GOTO ERR_CreatingDir

ECHO Create Vim backup folder
mkdir "%LOCALAPPDATA%\Vim\backup" >> "%LOG_FILE%" 2>&1
IF NOT "%ERRORLEVEL%" == "0" GOTO ERR_CreatingDir

ECHO Create Vim undo folder
mkdir "%LOCALAPPDATA%\Vim\undo" >> "%LOG_FILE%" 2>&1
IF NOT "%ERRORLEVEL%" == "0" GOTO ERR_CreatingDir

REM Add Vundle to the vim setup
ECHO Cloning Vundle repo
git clone https://github.com/gmarik/vundle "%DOTFILES_DIR%/vim/bundle/vundle" >> "%LOG_FILE%" 2>&1
IF NOT "%ERRORLEVEL%" == "0" GOTO ERR_GettingVundle

:SetupPentadactyl
REM Setup Pentadactyl
REM -----------------

REM Create file links
ECHO Link .pentadactylrc to dotfiles\pentadactyl\pentadactylrc
mklink /H "%USERPROFILE%\.pentadactylrc" "%DOTFILES_DIR%\pentadactyl\pentadactylrc" >> "%LOG_FILE%" 2>&1
IF NOT "%ERRORLEVEL%" == "0" GOTO ERR_CreatingLink

ECHO Link pentadactyl to dotfiles\pentadactyl
mklink /J "%USERPROFILE%\pentadactyl" "%DOTFILES_DIR%\pentadactyl" >> "%LOG_FILE%" 2>&1
IF NOT "%ERRORLEVEL%" == "0" GOTO ERR_CreatingLink

:SetupPowerShell
REM Setup PowerShell
REM ----------------

ECHO Ensure user PowerShell profile folder exists
IF NOT EXIST "%USER_PS_FOLDER%" mkdir "%USER_PS_FOLDER%" > "%LOG_FILE%" 2>&1
IF NOT "%ERRORLEVEL%" == "0" GOTO ERR_CreatingDir

REM Create file links
ECHO Link user's PowerShell profile
mklink "%USER_PS_FOLDER%\Microsoft.PowerShell_profile.ps1" "%DOTFILES_DIR%\powershell\powershell_profile.ps1" >> "%LOG_FILE%" 2>&1
IF NOT "%ERRORLEVEL%" == "0" GOTO ERR_CreatingLink

:Success
ECHO Success!
SET EXIT_CODE=0
GOTO Done

:ERR_XPOrOlder
REM No symlinks means copies of everything. Ick. Fix later, if needed.
ECHO ERROR: Windows XP is too old! You're on your own.
GOTO Done

:ERR_NoGit
ECHO ERROR: Git install required. Download from https://code.google.com/p/msysgit/
GOTO Done

:ERR_NoVimrc
ECHO ERROR: "%DOTFILES_DIR%\vim\vimrc" not found. Project in unknown state. Cannot continue.
GOTO Done

:ERR_NoPentarc
ECHO ERROR: "%DOTFILES_DIR%\pentadactyl\pentadactylrc" not found. Project in unknown state. Cannot continue.
GOTO Done

:ERR_NoPentarc
ECHO ERROR: "%DOTFILES_DIR%\powershell\powershell_profile.ps1" not found. Project in unknown state. Cannot continue.
GOTO Done

:ERR_NotAdmin
ECHO ERROR: Admin permissions required. Please use a command prompt with admin permissions.
GOTO Done

:ERR_CreatingDir
ECHO ERROR: Could not create new directory. Log follows:
GOTO ShowLogFile

:ERR_CreatingLink
ECHO ERROR: Could not create hard link or junction. Log follows:
GOTO ShowLogFile

:ERR_GettingVundle
ECHO ERROR: Error cloning Vundle repository. Log follows:
GOTO ShowLogFile

:ShowLogFile
ECHO.
TYPE "%LOG_FILE%"
GOTO Done

:Done
ECHO.
PAUSE
EXIT /B %EXIT_CODE%

