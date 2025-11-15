# Navigation Refactor Design Document

## 1. Overview

This document outlines the design for refactoring the application's navigation system. The primary goal is to replace the existing navigation drawer functionality with a back arrow mechanism, establishing the `HomePage` as the default root for authenticated users and implementing a stack-based navigation approach. This change aims to provide a more intuitive and consistent navigation experience, particularly for mobile users who are accustomed to hierarchical navigation.

## 2. Detailed Analysis of the Goal or Problem

The current navigation setup utilizes a `Drawer` widget, accessible via a menu icon in the `AppBar` of several screens, including `HomePage` and `ChatListScreen`. The user has requested a shift from this drawer-based navigation to a back-arrow-based, stack-oriented navigation model.

**Current State:**
*   `HomePage` (`app/lib/features/home/presentation/pages/home_page.dart`) includes an `AppBar` with a menu icon that opens a `MainDrawer`.
*   `ChatListScreen` (`app/lib/features/chats/presentation/screens/chat_list_screen.dart`) also had a menu icon intended to open a drawer (though the drawer itself was not fully implemented before this refactor request).
*   Navigation between major sections of the app (e.g., `/chats`, `/groups`) is handled by `go_router`.
*   The `AppRouter` (`app/lib/core/router/app_router.dart`) defines routes and handles authentication-based redirects, sending authenticated users to `/home`.

**Desired State:**
*   The `HomePage` will serve as the primary entry point for authenticated users and will **retain its `Drawer` and the associated menu icon** in its `AppBar` to open it.
*   All other navigable screens (i.e., any screen that is *not* the `HomePage`) will have a back arrow in their `AppBar`'s `leading` position.
*   Tapping the back arrow will pop the current screen off the navigation stack, returning to the previous screen. This will naturally lead back to the `HomePage` if it is the only screen left on the stack.
*   The `Drawer` widgets and their associated menu icons will be removed from all screens *except* the `HomePage`.

## 3. Alternatives Considered

*   **Keeping the Drawer for specific sections:** This was considered but rejected as the user explicitly requested replacing the drawer with a back arrow for a consistent stack-based navigation model.
*   **Implementing custom back navigation logic:** Instead of relying on `context.pop()`, one could implement custom logic to navigate to specific routes. However, `context.pop()` is the idiomatic `go_router` way to handle hierarchical navigation and aligns perfectly with the "stack to get back to home" requirement. Custom logic would introduce unnecessary complexity and potential for bugs.
*   **Using `go_router`'s `go()` to `/home` for all back actions:** This would force every back action to return directly to the home page, bypassing intermediate screens. This contradicts the "stack" behavior requested by the user, which implies returning to the *immediately previous* screen. Therefore, `context.pop()` is preferred.

## 4. Detailed Design for the Modification

The refactoring will primarily involve modifications to the `AppBar` configurations of various screens and the removal of `Drawer` widgets.

### 4.1. `HomePage` (`app/lib/features/home/presentation/pages/home_page.dart`)

*   **Retain `leading` menu icon:** The `Builder` and `IconButton` for `Icons.menu` will be retained in the `AppBar`'s `leading` property to open the `MainDrawer`.
*   **Retain `drawer` property:** The `drawer: const MainDrawer()` will be retained in the `Scaffold`.
*   The `HomePage`'s `AppBar` will continue to have its `leading` menu icon, serving as the root of the navigation stack for authenticated users.

### 4.2. `ChatListScreen` (`app/lib/features/chats/presentation/screens/chat_list_screen.dart`)

*   **Replace `leading` menu icon with back arrow:** The `IconButton` with `Icons.menu` will be replaced with an `IconButton` containing `Icons.arrow_back`.
*   **Implement back navigation:** The `onPressed` callback for the back arrow will use `context.pop()` to navigate back.
*   **Remove `drawer` property:** The `drawer` property will be removed from the `Scaffold`.

### 4.3. Other Navigable Screens (All screens *except* `HomePage`)

All other screens that are not the `HomePage` and are accessible via `go_router` routes (e.g., `GroupHomeScreen`, `EventsDashboardScreen`, `ExpensesHomeScreen`, `IdiotGameDashboardScreen`, `ContactListScreen`, `SettingsPage`, `CreateGroupScreen`, `EditGroupScreen`, `MyGroupsOverviewScreen`, `LoginOrCreateAccountScreen`, `LoginCallbackScreen`, `WelcomeScreen`) will need their `AppBar`s inspected.

*   **Add/Replace `leading` back arrow:** If an `AppBar` has a `leading` widget that is not a back arrow, it will be replaced with an `IconButton` containing `Icons.arrow_back`. If it has no `leading` widget, a back arrow will be added.
*   **Implement back navigation:** The `onPressed` callback for the back arrow will use `context.pop()`.
*   **Remove `drawer` property:** Any `Scaffold` with a `drawer` property will have it removed.

### 4.4. `AppRouter` (`app/lib/core/router/app_router.dart`)

*   No direct changes are anticipated for the `AppRouter` configuration itself, as `context.pop()` works with the existing route definitions. The `redirect` logic will continue to function as intended.

## 5. Diagrams

### 5.1. Current Navigation Flow (Simplified)

```mermaid
graph TD
    A[WelcomeScreen] --> B{Authenticated?};
    B -- Yes --> C[HomePage];
    B -- No --> A;
    C -- Menu Icon --> D[MainDrawer];
    D -- Select Item --> E[Other Screens (e.g., ChatListScreen)];
    E -- Menu Icon --> F[Drawer (if present)];
    E -- Back Button --> C;
```

### 5.2. Proposed Navigation Flow (Simplified)

```mermaid
graph TD
    A[WelcomeScreen] --> B{Authenticated?};
    B -- Yes --> C[HomePage];
    B -- No --> A;
    C -- Navigate to --> D[Other Screen 1 (e.g., ChatListScreen)];
    D -- Back Arrow --> C;
    D -- Navigate to --> E[Other Screen 2 (e.g., ChatDetailScreen)];
    E -- Back Arrow --> D;
    E -- Back Arrow --> C;
```

## 6. Summary of the Design

The design focuses on transforming the application's navigation from a drawer-centric model to a hierarchical, stack-based model, with the `HomePage` as a specific exception. The `HomePage` will retain its `Drawer` and menu icon. All other screens will have their `Drawer` widgets removed and their menu icons replaced with back arrows. The `go_router`'s `context.pop()` method will be used for back navigation on these screens, ensuring a consistent and predictable user experience.

## 7. References to Research URLs

*   [GoRouter documentation](https://pub.dev/packages/go_router)
*   [Flutter AppBar documentation](https://api.flutter.dev/flutter/material/AppBar-class.html)
*   [Flutter Drawer documentation](https://api.flutter.dev/flutter/material/Drawer-class.html)
*   [Flutter Navigator documentation](https://api.flutter.dev/flutter/widgets/Navigator-class.html)
