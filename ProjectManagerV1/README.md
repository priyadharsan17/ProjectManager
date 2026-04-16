# ProjectManager

A modern project management application built with PySide6 and QML, featuring a sleek, animated login interface and a frameless window design.

## Features

- 🎨 Modern, glass-morphism UI design
- 🔐 Secure login system with backend authentication
- 🖼️ Frameless window with custom title bar controls
- ⚡ Smooth animations and transitions
- 🎯 Built with PySide6 and Qt Quick (QML)

## Screenshots

The application features a dark-themed login screen with:
- Animated gradient background
- Glass-morphism design elements
- Real-time form validation
- Custom window controls (minimize, maximize, close)

## Requirements

- Python 3.8 or higher
- PySide6 6.10.1

## Installation & Setup

### For Windows

#### 1. Clone the Repository
```bash
git clone https://github.com/priyadharsan17/ProjectManager.git
cd ProjectManager
```

#### 2. Create Virtual Environment
```bash
# Create a new virtual environment
python -m venv venv

# Activate the virtual environment
# For PowerShell:
.\venv\Scripts\Activate.ps1

# For Command Prompt:
.\venv\Scripts\activate.bat
```

**Note:** If you encounter an error about execution policies in PowerShell, run:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### 3. Install Dependencies
```bash
pip install --upgrade pip
pip install -r requirements.txt
```

#### 4. Run the Application
```bash
python main.py
```

### For Linux/macOS

#### 1. Clone the Repository
```bash
git clone https://github.com/priyadharsan17/ProjectManager.git
cd ProjectManager
```

#### 2. Create Virtual Environment
```bash
# Create a new virtual environment
python3 -m venv venv

# Activate the virtual environment
source venv/bin/activate
```

#### 3. Install Dependencies
```bash
pip install --upgrade pip
pip install -r requirements.txt
```

#### 4. Run the Application
```bash
python main.py
```

## Quick Setup Script (Windows)

A batch script is provided for quick setup on Windows:

```bash
# Run the setup script
.\setup_venv.bat
```

This script will automatically:
1. Create a virtual environment
2. Activate it
3. Install all required dependencies

After running the script, simply execute:
```bash
python main.py
```

## Demo Credentials

For testing the login functionality, use these credentials:

- **Username:** `admin` | **Password:** `admin123`
- **Username:** `demo` | **Password:** `demo123`

## Project Structure

```
ProjectManager/
├── main.py                  # Application entry point
├── main.qml                 # Main application window
├── requirements.txt         # Python dependencies
├── setup_venv.bat          # Windows setup script
├── Backend/
│   └── LoginManager.py     # Authentication backend
├── Screens/
│   └── LoginScreen.qml     # Login UI screen
├── Components/             # Reusable QML components
└── Assets/                 # Images, icons, fonts
    ├── Fonts/
    └── Icons/
```

## Development

### Adding New Screens

1. Create a new QML file in the `Screens/` folder
2. Load it using the window's `loadScreen()` function:

```qml
mainWindow.loadScreen("Screens/YourNewScreen.qml")
```

### Creating Backend Managers

1. Create a new Python class in the `Backend/` folder
2. Inherit from `QObject`
3. Use `@Slot` decorator for methods callable from QML
4. Use `Signal` for emitting events to QML

Example:
```python
from PySide6.QtCore import QObject, Slot, Signal

class YourManager(QObject):
    dataChanged = Signal(str)
    
    @Slot(str)
    def processData(self, data):
        # Your logic here
        self.dataChanged.emit("Processed!")
```

## Troubleshooting

### Virtual Environment Not Activating
- **Windows PowerShell:** Run `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
- Verify Python is in your PATH

### Module Not Found Error
```bash
# Ensure virtual environment is activated
# Reinstall dependencies
pip install -r requirements.txt
```

### QML Warnings
If you see Qt Quick Controls customization warnings, ensure the application sets:
```python
os.environ["QT_QUICK_CONTROLS_STYLE"] = "Basic"
```
This is already configured in `main.py`.

## Technologies Used

- **PySide6** - Python bindings for Qt 6
- **Qt Quick (QML)** - Declarative UI framework
- **Python 3** - Backend logic

## License

This project is open source and available under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Author

**Priyadharsan**
- GitHub: [@priyadharsan17](https://github.com/priyadharsan17)

## Acknowledgments

- Qt for the amazing PySide6 framework
- The open-source community for inspiration
