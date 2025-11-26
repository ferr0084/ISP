# Idiot Social Platform (ISP) Flutter App

This is the Flutter-based mobile application for the "Idiot Social Platform," a social network for players of the card game "Idiot." The app aims to connect players, facilitate game organization, and track game-related stats and achievements.

## Features

*   **User Authentication:** Secure user login and registration with Supabase Auth.
*   **Profile Management:** View and edit user profiles with avatar upload.
*   **Contact Management:** View, search, and invite friends.
*   **Group Management:** Create and manage groups for games with group avatars and member management.
*   **Event Organization:** Plan, create, edit, and track game events with invitations and attendance tracking.
*   **Expense Tracking:** Manage and split expenses related to events and groups with payment tracking.
*   **Payment Methods:** Manage preferred payment methods (Venmo, PayPal, CashApp, Zelle).
*   **Idiot Game Tracking:** Log and track game sessions, stats, achievements, and game history.
*   **Notifications:** Real-time notifications for invites, events, and game activities.
*   **Real-time Chat:** Group chat functionality for events and groups.
*   **Home Dashboard:** Unified view of upcoming events, groups, and recent games.

## Architecture

The application follows a feature-first, layered architecture (Clean Architecture) to promote scalability and maintainability.

*   **State Management:** Uses `ChangeNotifier` with `ListenableBuilder` and `provider` package.
*   **Routing:** Handled by the `go_router` package, including authentication-based redirects and deep linking.
*   **Dependency Injection:** `get_it` is used for service location and dependency injection.
*   **Layers:** Presentation (UI), Domain (business logic), and Data (data retrieval/storage).

### Feature Architecture

Each major feature resides in its own top-level directory within `app/lib/features/`. For example, a "Notifications" feature would have the following structure:

```
app/lib/features/
├── notifications/
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── notification_remote_datasource.dart
│   │   │   └── notification_local_datasource.dart
│   │   ├── models/
│   │   │   └── notification_model.dart
│   │   └── repositories/
│   │       └── notification_repository_impl.dart
│   ├── domain/
│   │   ├── entities/
│   │   │   └── notification.dart
│   │   ├── repositories/
│   │   │   └── notification_repository.dart
│   │   └── usecases/
│   │       ├── get_notifications.dart
│   │       └── mark_notification_as_read.dart
│   └── presentation/
│       ├── providers/
│       │   └── notification_provider.dart
│       ├── screens/
│       │   ├── notification_detail_screen.dart
│       │   └── notification_list_screen.dart
│       └── widgets/
│           └── notification_card.dart
```

#### Layer Responsibilities

*   **Presentation Layer (`app/lib/features/<feature_name>/presentation/`)**
    *   **Purpose:** Handles everything related to the User Interface (UI). It's responsible for displaying data to the user and reacting to user input.
    *   **Contents:** `screens/`, `widgets/`, `providers/`.
    *   **Dependencies:** Depends on the Domain layer. Should **never** directly depend on the Data layer.

*   **Domain Layer (`app/lib/features/<feature_name>/domain/`)**
    *   **Purpose:** Contains the core business logic of the application. This layer is completely independent of any UI framework, database, or external API. It defines *what* the application does.
    *   **Contents:** `entities/`, `repositories/` (abstract interfaces), `usecases/` (or `interactors/`), `failures/`.
    *   **Dependencies:** Has no dependencies on other layers. It's the most abstract and reusable part of your application.

*   **Data Layer (`app/lib/features/<feature_name>/data/`)**
    *   **Purpose:** Responsible for retrieving and storing data. It provides the concrete implementations for the abstract repository interfaces defined in the Domain layer. It defines *how* data operations are performed.
    *   **Contents:** `datasources/`, `models/` (Data Transfer Objects - DTOs), `repositories/` (concrete implementations).
    *   **Dependencies:** Depends on external packages (e.g., `supabase_flutter`, `http`), and the Domain layer (to implement its interfaces).

#### Repositories vs. Data Sources

*   **Repository:** An abstraction layer over various data sources. It provides a clean, unified API to the Domain Layer, dealing with Domain `Entities`. It orchestrates which data source(s) to use, maps data from Data Source formats to Domain `Entities`, and handles error translation.
*   **Data Source:** A concrete implementation that knows how to interact with a specific data storage mechanism (e.g., remote API, local database). It performs actual I/O operations, deals with raw data or `Models` (DTOs), and contains minimal to no business logic.

The `Repository` uses one or more `Data Sources` to fulfill the contracts defined in the Domain Layer.

#### Key Architectural Patterns in Practice

*   **State Management (`provider` with `ChangeNotifier`):** `ChangeNotifier`s live in the Presentation layer, call `usecases` from the Domain layer, and notify UI widgets of state changes.
*   **Routing (`go_router`):** Routes are defined centrally, target screens from the Presentation layer, and handle deep linking/authentication redirects.
*   **Dependency Injection (`get_it`):** Used to register and provide instances of repositories, use cases, and notifiers, decoupling components. Registrations are typically in `app/lib/core/di/service_locator.dart`.



## Backend

The backend is powered by [Supabase](https://supabase.com/), providing authentication, database, and Edge Functions.

## Getting Started

Follow these steps to set up and run the project locally.

### Prerequisites

*   [Flutter SDK](https://flutter.dev/docs/get-started/install) installed and configured.
*   [Supabase CLI](https://supabase.com/docs/guides/cli) installed (for managing migrations and Edge Functions).
*   A Supabase project set up.

### 1. Clone the Repository

```bash
git clone [YOUR_REPOSITORY_URL]
cd app
```

### 2. Install Dependencies

Navigate to the `app/` directory and install Flutter dependencies:

```bash
flutter pub get
```

### 3. Supabase Project Setup

#### a. Environment Variables

Create a `.env` file in the `app/` directory (at the same level as `pubspec.yaml`) and add your Supabase project credentials:

```
SUPABASE_URL=YOUR_SUPABASE_PROJECT_URL
SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

You can find these values in your Supabase project dashboard under "Project Settings" -> "API".

#### b. Supabase Service Role Key

For Edge Functions to interact with your database with elevated privileges (e.g., bypassing RLS for certain operations), you need to configure the `SUPABASE_SERVICE_ROLE_KEY` as a [Supabase Secret](https://supabase.com/docs/guides/functions/secrets).

```bash
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=YOUR_SERVICE_ROLE_KEY
```

**Important:** Never expose your `SUPABASE_SERVICE_ROLE_KEY` directly in client-side code.

#### c. Apply Database Migrations

The project includes database schema migrations in the `supabase/migrations` directory. Apply them to your Supabase project using the Supabase CLI:

```bash
# From the root of the repository (ISP/)
supabase db push
```

#### d. Deploy Edge Functions

The "Invite Friends" feature uses Supabase Edge Functions. Deploy them using the Supabase CLI:

```bash
# From the root of the repository (ISP/)
supabase functions deploy send-invite --no-verify-jwt
supabase functions deploy accept-invite --no-verify-jwt
```

**Note:** The `--no-verify-jwt` flag is used here for simplicity during development. In a production environment, you might want to enable JWT verification and handle authentication within your functions.

#### e. Deep Linking Configuration

The app uses deep linking for accepting invitations. You'll need to configure this for your target platforms:

*   **Android:** Configure intent filters in `android/app/src/main/AndroidManifest.xml` to handle `yourapp://invite` links.
*   **iOS:** Configure associated domains in Xcode and your `ios/Runner/Info.plist` to handle universal links.
*   **Web:** Configure your web server to handle redirects for deep links (e.g., `https://yourdomain.com/invite?token=...`).

### 4. Run the Application

Once all dependencies are installed and Supabase is configured, you can run the application:

```bash
flutter run
```

## Testing the Invite Friends Feature

1.  **Log in** to the app with an existing user.
2.  Navigate to the **Contacts** screen.
3.  Tap on **"Invite Friends"**.
4.  Select one or more contacts (or enter an email if a search functionality is available for non-contacts).
5.  Tap **"Send Invites"**.
6.  Check your Supabase logs (or the console output of the `send-invite` Edge Function) for the generated invite link.
7.  Open the invite link (e.g., `yourapp://invite?token=...`) on a device with the app installed. This should trigger the `InviteAcceptScreen` to process the invitation.
