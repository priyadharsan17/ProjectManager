@echo off
echo Setting up MindMapIO virtual environment...

python -m venv .venv
call .venv\Scripts\activate.bat
pip install -r requirements.txt

echo.
echo Setup complete! Run with: python main.py
pause
