# TermaUp - ClickUp Terminal UI

[![Ruby](https://img.shields.io/badge/Ruby-3.0%2B-red)](https://www.ruby-lang.org/)
[![Platform](https://img.shields.io/badge/Platform-ARM64%2FAMD64-blue)](https://github.com/Rynaro/terma-up)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

**TermaUp** is a modern Terminal User Interface (TUI) for ClickUp, built with Ruby and designed for multi-platform compatibility including ARM64 and AMD64 architectures.

## ✨ Features

- 🚀 **Fast & Responsive**: Built with Ruby for optimal performance (<500ms response time)
- 🎨 **Rich Terminal UI**: Interactive navigation using TTY toolkit
- 🔐 **Secure Authentication**: Encrypted token storage with file-based fallback
- 📋 **Complete ClickUp Navigation**: Workspaces → Spaces → Folders → Lists → Tasks
- 🎯 **Task Management**: View detailed task information with markdown rendering
- 💾 **Smart Caching**: Reduces API calls with intelligent caching
- 🐳 **Docker Support**: Multi-platform container images (ARM64/AMD64)
- 📱 **Cross-Platform**: Runs on Linux, macOS, and Windows

## 🏗️ Architecture

- **Language**: Ruby 3.0+ with native ARM64 support
- **HTTP Client**: Faraday with rate limiting (100 req/min)
- **Terminal UI**: TTY Toolkit for rich interactive interfaces
- **CLI Framework**: Thor for command-line interface
- **Authentication**: File-based encrypted token storage
- **Caching**: Intelligent API response caching

## 📦 Installation

### From Source

```bash
git clone https://github.com/Rynaro/terma-up.git
cd terma-up
bundle install
./bin/clickup-tui --help
```

### Docker

```bash
# Run directly
docker run -it --rm clickup-tui:latest

# With persistent configuration
docker run -it --rm \
  -v ~/.config/clickup-tui:/home/clickup/.config/clickup-tui \
  -v ~/.cache/clickup-tui:/home/clickup/.cache/clickup-tui \
  clickup-tui:latest
```

### Docker Compose

```bash
# Production
docker-compose --profile tools up clickup-tui

# Development
docker-compose --profile dev up clickup-tui-dev
```

## 🚀 Quick Start

### 1. Authentication

First, set up your ClickUp API token:

```bash
clickup-tui auth
```

You'll need to:
1. Go to [ClickUp Settings > Apps](https://app.clickup.com/settings/apps)
2. Generate a Personal API Token (starts with `pk_`)
3. Enter the token when prompted

### 2. Start the TUI

```bash
clickup-tui start
# or simply
clickup-tui
```

### 3. Navigation

- **Arrow Keys**: Navigate through options
- **Enter**: Select an item
- **Esc / Back**: Go back one level
- **Home**: Return to workspace selection
- **Ctrl+C**: Exit the application

## 💻 Commands

```bash
clickup-tui start         # Start the TUI interface (default)
clickup-tui auth          # Set up authentication
clickup-tui status        # Show authentication and config status  
clickup-tui clear-auth    # Clear stored authentication
clickup-tui clear-cache   # Clear API response cache
clickup-tui version       # Show version information
clickup-tui help          # Show help information
```

## 🔧 Configuration

TermaUp supports configuration via environment variables:

```bash
# API Configuration  
export CLICKUP_API_URL="https://api.clickup.com/api/v2"
export CLICKUP_API_TIMEOUT=30

# UI Configuration
export CLICKUP_TUI_PER_PAGE=15
export CLICKUP_TUI_CACHE_ENABLED=true

# Debug Mode
export CLICKUP_TUI_DEBUG=true
```

Configuration files are stored in:
- **Config**: `~/.config/clickup-tui/`
- **Cache**: `~/.cache/clickup-tui/`

## 🐳 Docker Development

### Building Multi-Platform Images

```bash
# Build for ARM64 and AMD64
./scripts/build-multi-platform.sh

# Build with custom tag
./scripts/build-multi-platform.sh v1.0.0
```

### Local Development

```bash
# Start development environment
docker-compose --profile dev up clickup-tui-dev

# Build local image
docker build -f docker/Dockerfile -t clickup-tui:local .
```

## 🧪 Development

### Prerequisites

- Ruby 3.0+
- Bundler 2.0+

### Setup

```bash
git clone https://github.com/Rynaro/terma-up.git
cd terma-up
bundle install
```

### Running Tests

```bash
# Run test suite (when implemented)
bundle exec rspec

# Run linting
bundle exec rubocop

# Generate docs
bundle exec yard
```

### Project Structure

```
clickup-tui/
├── lib/
│   ├── clickup_tui.rb              # Main module
│   └── clickup_tui/
│       ├── cli.rb                  # Thor CLI interface
│       ├── application.rb          # Main application orchestrator
│       ├── auth.rb                 # Authentication management
│       ├── client.rb               # ClickUp API client
│       ├── navigator.rb            # TUI navigation controller
│       ├── display.rb              # UI rendering components
│       ├── models/                 # Data models
│       └── ...
├── bin/clickup-tui                 # Executable entry point
├── docker/                         # Docker configuration
├── scripts/                        # Build and utility scripts
└── spec/                           # Test suite
```

## 🏗️ API Coverage

### Implemented Endpoints

- ✅ **Teams/Workspaces**: `GET /team`
- ✅ **Spaces**: `GET /team/{team_id}/space`
- ✅ **Folders**: `GET /space/{space_id}/folder`
- ✅ **Lists**: `GET /folder/{folder_id}/list`, `GET /space/{space_id}/list`
- ✅ **Tasks**: `GET /list/{list_id}/task`
- ✅ **Task Details**: `GET /task/{task_id}`
- ✅ **User Info**: `GET /user`

### Rate Limiting

- **Limit**: 100 requests per minute (configurable)
- **Handling**: Automatic rate limiting with wait periods
- **Caching**: Reduces API calls through intelligent caching

## 🎯 Roadmap

- [ ] Task creation and editing
- [ ] Comment viewing and management
- [ ] Time tracking integration
- [ ] Custom fields support
- [ ] Bulk operations
- [ ] Export functionality
- [ ] Plugin system

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with [TTY Toolkit](https://ttytoolkit.org/) for terminal interfaces
- Powered by [Faraday](https://github.com/lostisland/faraday) for HTTP client
- Uses [Thor](https://github.com/rails/thor) for CLI framework

## ⚠️ Disclaimer

This is an unofficial ClickUp client. ClickUp is a trademark of ClickUp Inc.
