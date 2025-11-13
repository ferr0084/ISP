# Idiot Social Platform

## App Overview
Idiot is a card game where there is no winner, just a loser - the idiot. To connect players through a social platform that celebrates the fun of losing in Idiot games and facilitates getting together in real life.

## Core Features

### Member Accounts and Profiles
- an account with email and password or social login with Google, Facebook, etc is required
- Member profiles with customizable:
  - Avatars
  - Custom titles/roles
  - Achievement badges
  - Personal stats page
  - Notification preferences

### Group Management
- Private, invite-only groups

### Group Communication
Basically a Telegram clone. Members can create private groups and invite their friends. At the core of this group, is this persistent chat room.
- Single continuous chat thread for main group conversation
- Threaded comments on individual posts
- Rich media support:
  - Photo sharing
  - Video links
  - Organized media galleries
- Message features:
  - Emoji reactions
  - Pinned messages
  - Push notifications
  - Media gallery organization

### Event Scheduling and Planning
The Ranked-Choice Event Scheduling and Planning feature simplifies group event planning by allowing users to propose events, suggest time slots, and use ranked-choice voting to determine the optimal schedule. Participants rank/order their preferences, and the app calculates the most agreeable time based on collective input, reducing conflicts and decision fatigue. For MVP, start with simpler availability polling (checkbox-style) before implementing full ranked voting.

#### Core Event Planning Functionality
- Event Creation: Users can create events by specifying details (title, description, duration) and proposing multiple time slots.
- Participant Invitation: Invite participants via email, links, or integrations with calendars (e.g., Google Calendar, Outlook).
- Ranked-Choice Voting: Participants order proposed time slots by preference (1st choice, 2nd, etc.).
- Result Calculation: An algorithm aggregates rankings to select the time slot with the highest collective preference, considering factors like majority support and tie-breaking.
- Notification System: Automated reminders and updates via email or in-app notifications.
- Integration: Sync with popular calendar apps for seamless scheduling.

### Game Tracking
- Record games including:
  - Date and time
  - Location
  - Players present
  - Who became the idiot
- Prominent display of current idiot status
- Multiple view options for game history:
  - Calendar view
  - Location-based
  - Player-based
  - Recent games
  - Filtered by specific players
 - Ensure all views are filterable by group to avoid data overload
 - Add export options (e.g., share game stats as PDFs) for IRL sharing

### Achievement System
- Automatic tracking of achievements like:
  - Losing streaks
  - Hosting records
  - Games played
  - Special titles earned
- Custom badges and visual indicators
 - Fun, playful notifications when achievements are earned
 - Include group-level achievements (e.g., "Most Idiots in a Row" for the whole group) to encourage collective play

## Technical Stack

Application Framework: Flutter and Dart
Backend system: Supabase

## Research Findings
### Best Practices
- **Architecture:** A feature-first, layered architecture (Clean Architecture) is the best approach for scalability and maintainability. This involves separating the application into Presentation, Domain, and Data layers.
- **State Management:** For user profiles, `ChangeNotifier` with `ListenableBuilder` is a suitable and recommended approach for managing state.
- **Authentication:** `supabase_flutter` package provides a comprehensive solution for handling user authentication with Supabase.
- **Routing:** `go_router` is a good choice for declarative routing and handling authentication-based redirects.

### Reference Implementations
- **Flutter Architecture:** [https://resocoder.com/2019/08/27/flutter-tdd-clean-architecture-course-1-explanation-project-structure/](https://resocoder.com/2019/08/27/flutter-tdd-clean-architecture-course-1-explanation-project-structure/)
- **Supabase Flutter Docs:** [https://supabase.com/docs/guides/with-flutter](https://supabase.com/docs/guides/with-flutter)

### Technology Decisions
- **State Management:** `ChangeNotifier` will be used for managing user profile state. It's simple, effective, and built-in.
- **Routing:** `go_router` will be used for navigation and to handle redirects based on authentication state.
 - **Dependency Injection:** `get_it` will be used for service location and dependency injection to decouple the layers of the application.

## Scalability and Security Considerations
- **Privacy and Compliance:** Ensure GDPR compliance for user data, especially in private groups and location-based game logs. Implement data encryption and user consent for sensitive features.
- **Performance:** Optimize real-time chat and media uploads with lazy loading and compression to handle mobile bandwidth constraints.
- **Testing:** Plan for unit tests on domain logic and integration tests for Supabase interactions to maintain reliability as the app scales.

## Development Phases and Timeline
- **MVP (3-6 months):** Core features - profiles, groups, basic chat, game logging.
- **Beta:** Add events, achievements.
- **Full Release:** Advanced features like full ranked voting and media galleries.
- **Timeline Buffer:** Allocate 20-30% extra time for testing and user feedback iterations.

## Monetization
- Consider freemium model: Free core features, premium for advanced stats or group analytics.
- Explore sponsorships from board game communities or in-app purchases for custom achievements.