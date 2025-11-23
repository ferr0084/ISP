# AGENTS.md

Use MCP servers if available
Use LSP servers if available

## Commands
- **Install deps**: `cd app && flutter pub get`
- **Check outdated deps**: `cd app && flutter pub outdated`
- **Build**: `cd app && flutter build apk` (Android) or `flutter build ios` (iOS)
- **Run**: `cd app && flutter run`
- **Lint**: `cd app && flutter analyze`
- **Test all**: `cd app && flutter test`
- **Test single**: `cd app && flutter test path/to/test_file.dart`
- **Test coverage**: `cd app && flutter test --coverage`
- **Format**: `cd app && dart format .`

## Code Style Guidelines
- **Architecture**: Follow Clean Architecture (presentation → domain → data layers) with domain-driven design
- **State Management**: Use Provider with ChangeNotifier for state
- **Imports**: Order: dart:*, flutter/*, third-party packages, local imports (use relative paths)
- **Naming**: camelCase for variables/methods, PascalCase for classes/types, snake_case for files
- **Types**: Always declare return types, use final/const where possible
- **Error Handling**: Use Either<Failure, T> in domain layer, handle in presentation
- **Formatting**: Use dart format, prefer single quotes, const constructors
- **Lint Rules**: Avoid print, prefer const, sort directives, no unused params
- **Entities**: Use Equatable for domain entities
- **Dependencies**: Use get_it for DI, go_router for navigation