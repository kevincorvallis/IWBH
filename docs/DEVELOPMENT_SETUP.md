# Development Setup Guide

This guide will help you set up the IWBH development environment on macOS.

## Prerequisites

### Required Software
- **Xcode 15.0+** - For iOS development
- **Node.js 18+** - For backend development
- **Git** - Version control (usually pre-installed on macOS)

### Optional but Recommended
- **VS Code** - Configured workspace with tasks
- **iOS Simulator** - For testing (included with Xcode)
- **Postman** - For API testing

## Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/yourusername/IWBH.git
cd IWBH
```

### 2. iOS App Setup
```bash
# Open Xcode project
open ios-app/IWBH.xcodeproj

# OR use VS Code task
# Cmd+Shift+P → "Tasks: Run Task" → "Build IWBH App"
```

### 3. Backend Setup
```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Create environment file
cp .env.example .env
# Edit .env with your API keys (see Environment Configuration below)

# Start development server
npm run dev
```

## Environment Configuration

Create a `.env` file in the `backend/` directory:

```env
# OpenAI Configuration
OPENAI_API_KEY=your_openai_api_key_here

# AWS Configuration
AWS_ACCESS_KEY_ID=your_aws_access_key
AWS_SECRET_ACCESS_KEY=your_aws_secret_key
AWS_REGION=us-east-1

# Server Configuration
PORT=3000
NODE_ENV=development
```

### Getting API Keys

#### OpenAI API Key
1. Visit [OpenAI Platform](https://platform.openai.com)
2. Create an account or sign in
3. Navigate to API Keys section
4. Create a new secret key
5. Copy the key to your `.env` file

#### AWS Credentials
1. Sign in to [AWS Console](https://aws.amazon.com/console/)
2. Navigate to IAM → Users
3. Create a new user with programmatic access
4. Attach policies: `AmazonDynamoDBFullAccess`, `AmazonS3FullAccess`
5. Copy Access Key ID and Secret Access Key

## iOS App Configuration

### Update Backend URL
Edit `ios-app/IWBH/Services/ChatService.swift`:

```swift
// For local development
private let baseURL = "http://localhost:3000/api"

// For production
private let baseURL = "https://your-production-url.com/api"
```

### Firebase Setup (Optional)
If using Firebase features:
1. Create Firebase project
2. Download `GoogleService-Info.plist`
3. Add to `ios-app/IWBH/` directory in Xcode

## Development Workflow

### VS Code Tasks
Use the Command Palette (`Cmd+Shift+P`) and search for "Tasks: Run Task":

- **Build IWBH App**: Compiles iOS app
- **Start Backend Server**: Runs backend in development mode
- **Install Backend Dependencies**: Updates npm packages
- **Clean iOS Build**: Cleans Xcode build cache

### Manual Commands

#### iOS Development
```bash
# Build for simulator
cd ios-app
xcodebuild -project IWBH.xcodeproj -scheme IWBH -sdk iphonesimulator build

# Clean build
xcodebuild -project IWBH.xcodeproj -scheme IWBH clean
```

#### Backend Development
```bash
cd backend

# Development mode (with nodemon)
npm run dev

# Production mode
npm start

# Install new package
npm install package-name

# Update dependencies
npm update
```

## Testing

### iOS Testing
- **Unit Tests**: Run in Xcode (`Cmd+U`) or via `IWBHTests/`
- **UI Tests**: Run via `IWBHUITests/` in Xcode
- **Device Testing**: Use iOS Simulator or physical device

### Backend Testing
```bash
cd backend

# Manual API testing with curl
curl -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"userId":"test","message":"Hello"}'

# Check health endpoint
curl http://localhost:3000/health
```

## Troubleshooting

### Common Issues

#### Xcode Build Errors
- Clean build folder: `Product → Clean Build Folder`
- Reset simulator: `Device → Erase All Content and Settings`
- Check iOS deployment target (16.0+)

#### Backend Connection Issues
- Verify environment variables in `.env`
- Check port availability: `lsof -i :3000`
- Restart backend server
- Check firewall settings

#### API Key Issues
- Verify OpenAI API key is valid and has credits
- Check AWS credentials and permissions
- Ensure environment variables are loaded

### Debug Mode

#### iOS App Debug
- Use Xcode debugger and breakpoints
- Check Console app for device logs
- Enable Debug mode in scheme settings

#### Backend Debug
```bash
# Run with debugging
DEBUG=* npm run dev

# Check server logs
tail -f server.log
```

## Production Deployment

### iOS App
1. Update configurations for production
2. Archive in Xcode (`Product → Archive`)
3. Submit to App Store Connect

### Backend
1. Set `NODE_ENV=production` in environment
2. Deploy to cloud service (AWS, Railway, etc.)
3. Update iOS app with production URL
4. Configure SSL certificates for HTTPS

## Additional Resources

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Express.js Guide](https://expressjs.com/en/guide/routing.html)
- [OpenAI API Documentation](https://platform.openai.com/docs)
- [AWS SDK Documentation](https://docs.aws.amazon.com/sdk-for-javascript/)

## Getting Help

- Check existing GitHub issues
- Review project documentation in `docs/`
- Contact team via support channels
