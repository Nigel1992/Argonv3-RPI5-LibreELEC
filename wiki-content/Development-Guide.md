# Development Guide

This guide is for developers who want to contribute to or modify the Argon ONE V3 setup script.

## Project Structure

```plaintext
/
├── .github/              # GitHub Actions and workflows
├── wiki/                 # Wiki documentation
├── wiki-content/         # Detailed documentation
├── argonv3.ps1          # Main script
└── README.md            # Project documentation
```

## Development Setup

1. Clone the repository
```powershell
git clone https://github.com/Nigel1992/Argonv3-RPI5-LibreELEC.git
cd Argonv3-RPI5-LibreELEC
```

2. Required Tools
- PowerShell 5.1 or later
- Visual Studio Code (recommended)
- Git

## Contributing

### Guidelines
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

### Code Style
- Use clear, descriptive variable names
- Comment your code
- Follow PowerShell best practices
- Include error handling

## Testing

1. Test Environment
- Windows 10/11
- PowerShell 5.1+
- LibreELEC on RPi5
- Argon ONE V3 case

2. Test Cases
- Connection handling
- Error scenarios
- User interface
- Settings management

## Building

1. Script Packaging
```powershell
# Package the script
./build.ps1
```

2. Release Process
- Update version number
- Run tests
- Create release notes
- Submit for review

## Documentation

1. Update relevant wiki pages
2. Document new features
3. Include usage examples
4. Update README.md 