# GEMINI.md

## Project Overview

This is a Flutter-based mobile application for the "Idiot Social Platform," a social network for players of the card game "Idiot." The app aims to connect players, facilitate game organization, and track game-related stats and achievements. The backend is powered by Supabase.

The project follows a feature-first, layered architecture (Clean Architecture) to promote scalability and maintainability.

## Building and Running

To build and run the project, use the following standard Flutter commands:

- `flutter pub get`: To install dependencies.
- `flutter run`: To run the application on a connected device or simulator.

## Development Conventions

### State Management

The project uses `ChangeNotifier` with `ListenableBuilder` for state management, particularly for user profiles.

### Routing

Navigation is handled by the `go_router` package, which also manages authentication-based redirects.

### Dependency Injection

`get_it` is used for service location and dependency injection to decouple the application's layers.

### Architecture

The application is structured into three main layers:

- **Presentation:** The UI layer, containing widgets and screens.
- **Domain:** The business logic layer.
- **Data:** The layer responsible for data retrieval and storage, interacting with Supabase.

### Backend

The backend is provided by Supabase. The `supabase_flutter` package is used for authentication and data access.
