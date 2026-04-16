@echo off

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Python is not installed. Please install Python and try again.
    exit /b 1
)

REM Create a virtual environment
set VENV_DIR=venv
if exist %VENV_DIR% (
    echo Virtual environment already exists.
) else (
    python -m venv %VENV_DIR%
    echo Virtual environment created.
)

REM Activate the virtual environment
if exist %VENV_DIR%\Scripts\activate (
    echo Activating virtual environment...
    call %VENV_DIR%\Scripts\activate
    echo Virtual environment activated.
) else (
    echo Failed to activate virtual environment. Ensure it was created successfully.
    exit /b 1
)

REM Install required packages (if requirements.txt exists)
if exist requirements.txt (
    echo Installing required packages...
    pip install -r requirements.txt
    echo Packages installed.
) else (
    echo No requirements.txt file found. Skipping package installation.
)

REM Deactivate the virtual environment
echo Deactivating virtual environment...
deactivate

echo Setup complete.