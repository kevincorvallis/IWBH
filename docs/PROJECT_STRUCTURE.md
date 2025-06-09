# IWBH Project Structure

This document explains the organized structure of the IWBH repository and how each directory contributes to the project.

## 📁 Root Directory Structure

```
IWBH/
├── ios-app/                # iOS Application & Xcode Project
├── backend/                # Node.js API Server
├── assets/                 # Static assets and resources
├── scripts/                # Utility scripts
├── docs/                   # Documentation files
├── .vscode/                # VS Code workspace configuration
├── .git/                   # Git repository data
├── .gitignore              # Git ignore rules
└── README.md               # Main project documentation
```

## 🍎 iOS App Directory (`ios-app/`)

Contains the complete iOS application built with SwiftUI:

```
ios-app/
├── IWBH/                   # Main app source code
│   ├── Models/             # Data models and business logic
│   ├── Views/              # SwiftUI views and UI components
│   ├── Services/           # API communication services
│   ├── Extensions/         # Swift extensions and utilities
│   ├── Assets.xcassets/    # App icons, images, and colors
│   └── Widgets/            # Widget-related files
├── TrackerWidgetExtension/ # iOS Widget Extension
├── IWBHTests/              # Unit tests
├── IWBHUITests/            # UI automation tests
└── IWBH.xcodeproj/         # Xcode project file
```

### Key iOS Components

- **Models/**: Core data structures (AuthenticationModel, CustomTrackersModel, etc.)
- **Views/**: SwiftUI interface components organized by feature
- **Services/**: External API communication (ChatService for AI integration)
- **Extensions/**: Utility extensions (HapticFeedback, etc.)

## 🖥️ Backend Directory (`backend/`)

Node.js/Express API server that powers the AI chat functionality:

```
backend/
├── services/               # Business logic services
│   └── chatService.js      # OpenAI integration and data management
├── routes/                 # API endpoint definitions
│   └── chatRoutes.js       # Chat-related API routes
├── config/                 # Configuration files
│   ├── dynamodb.js         # AWS DynamoDB configuration
│   └── openai.js           # OpenAI API configuration
├── package.json            # Node.js dependencies and scripts
└── server.js               # Express server entry point
```

### Backend Features

- **RESTful API**: Clean endpoint design for iOS app communication
- **OpenAI Integration**: GPT-4 powered dating coach conversations
- **AWS Services**: DynamoDB for data storage, S3 for file uploads
- **Security**: Helmet middleware, CORS configuration, environment variables

## 🎨 Assets Directory (`assets/`)

Static resources and branding materials:

```
assets/
└── AppIcons/               # App icons and branding
    └── iwbh_app_icon_simple.svg
```

## 🔧 Scripts Directory (`scripts/`)

Utility scripts for development and maintenance:

```
scripts/
├── nuclear_secret_removal.sh    # Security script for removing secrets
└── remove_env_from_history.sh   # Git history cleanup script
```

## 📚 Documentation Directory (`docs/`)

Project documentation (expandable for future docs):

```
docs/
└── PROJECT_STRUCTURE.md         # This file
```

## ⚙️ Development Configuration

### VS Code Workspace (`.vscode/`)

- **tasks.json**: Build tasks for iOS app and backend server
- Configured for both Xcode builds and Node.js development

### Git Configuration

- **.gitignore**: Comprehensive ignore rules for Xcode, Node.js, and development files
- **Repository**: Clean history with sensitive data removed

## 🚀 Getting Started

1. **iOS Development**: Open `ios-app/IWBH.xcodeproj` in Xcode
2. **Backend Development**: Run `npm install` in `backend/` directory
3. **Full Stack**: Use VS Code tasks to build both iOS app and start backend server

## 📋 Build Tasks

Available via VS Code Command Palette (`Cmd+Shift+P` → "Tasks: Run Task"):

- **Build IWBH App**: Compiles iOS app for simulator
- **Start Backend Server**: Runs Node.js server in development mode
- **Install Backend Dependencies**: Installs npm packages
- **Clean iOS Build**: Cleans Xcode build artifacts

## 🔄 Workflow

1. **Feature Development**: Work in appropriate directory (ios-app or backend)
2. **Testing**: Use respective test suites (XCTest for iOS, manual testing for backend)
3. **Integration**: Both components communicate via HTTP API
4. **Deployment**: iOS app via App Store, backend via cloud hosting

This organized structure separates concerns clearly while maintaining a cohesive development experience.
