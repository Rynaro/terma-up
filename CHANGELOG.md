# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2024-09-27

### Added

#### Core Features
- Complete Ruby-based ClickUp Terminal User Interface (TUI)
- Multi-platform support for ARM64 and AMD64 architectures
- Secure file-based authentication with encrypted token storage
- Interactive TTY-based navigation system
- Rich terminal UI with colors, tables, and formatting
- Rate-limited ClickUp API client with Faraday

#### CLI Commands
- `clickup-tui start` - Launch the interactive TUI interface
- `clickup-tui auth [TOKEN]` - Set up ClickUp API authentication (interactive or parameter)
- `clickup-tui status` - Show authentication and configuration status
- `clickup-tui version` - Display version information
- `clickup-tui clear-auth` - Clear stored authentication token
- `clickup-tui clear-cache` - Clear cached API responses

#### Data Models
- Workspace model with member information
- Space model with privacy settings
- Folder model with task counts
- List model with priority indicators
- Task model with status icons, priority levels, assignees, due dates

#### Navigation System
- Hierarchical navigation: Workspaces → Spaces → Folders → Lists → Tasks
- Task detail view with markdown description rendering
- Breadcrumb navigation
- Back/Home navigation options
- Status-based task grouping

#### Technical Features
- Configuration management with environment variable overrides
- Intelligent API response caching with TTL
- Rate limiting (100 requests/minute)
- Error handling with user-friendly messages
- Loading indicators and spinners
- Table-based data display

#### Docker Support
- Multi-stage Dockerfile for optimized builds
- Docker Compose for development and production
- Multi-platform build scripts for ARM64/AMD64
- Development container with source mounting

#### Testing
- RSpec test suite with 24 passing tests
- Unit tests for authentication, configuration, and models
- Comprehensive test coverage for core functionality
- Automated CI/CD pipeline configuration

#### Documentation
- Comprehensive README with installation and usage instructions
- API endpoint coverage documentation
- Docker deployment guide
- Development setup instructions
- Contributing guidelines

### Technical Specifications
- **Language**: Ruby 3.0+
- **Dependencies**: TTY Toolkit, Faraday, Thor
- **Platforms**: Linux, macOS, Windows
- **Architectures**: ARM64, AMD64
- **Performance**: <500ms API response time
- **Security**: Encrypted credential storage

### Breaking Changes
- None (initial release)

### Security
- API tokens stored in encrypted files with secure permissions
- No tokens logged or exposed in error messages
- Fallback authentication storage when keyring unavailable

[0.1.0]: https://github.com/Rynaro/terma-up/releases/tag/v0.1.0