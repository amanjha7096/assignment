# User App

A Flutter application that fetches and displays user data, posts, and todos from a remote API, allows creating local posts, and supports light/dark theme switching with pull-to-refresh functionality. Built using the BLoC pattern for state management, the app provides a modern, responsive, and attractive UI.

## Demo Video

[Watch the demo video](https://drive.google.com/file/d/1oabfnc2ymRp6eOqU-s_MtLwN9BOGZGoJ/view?usp=sharing)


## Project Overview

The User App is designed to demonstrate a robust Flutter application with the following features:

- **User Listing**: Displays a paginated list of users with search functionality.
- **User Details**: Shows detailed user information, including personal details, address, company, posts, and todos, with animated cards and dialogs.
- **Post Creation**: Allows users to create local posts with a live preview using a reusable `PostCard` widget.
- **Local Posts**: Displays locally created posts, integrated with user-specific posts.
- **Pull-to-Refresh**: Refreshes user lists, details, and local posts.
- **Light/Dark Theme**: Supports theme switching with persistence using `shared_preferences`.
- **Animations**: Includes fade-in, slide-in, and scale animations for a polished UX.

The app uses the [DummyJSON API](https://dummyjson.com/) for user, post, and todo data, and employs clean architecture principles for maintainability and scalability.


## Directory Structure

```
lib/
├── bloc/
│   ├── theme/
│   │   ├── theme_bloc.dart
│   │   ├── theme_event.dart
│   │   └── theme_state.dart
│   └── user/
│       ├── user_bloc.dart
│       ├── user_event.dart
│       └── user_state.dart
├── models/
│   ├── post.dart
│   ├── todo.dart
│   └── user.dart
├── repositories/
│   └── user_repository.dart
├── screens/
│   ├── create_post_screen.dart
│   ├── local_posts_screen.dart
│   ├── user_detail_screen.dart
│   └── user_list_screen.dart
├── services/
│   └── api_service.dart
├── widgets/
│   └── (custom widgets can be added here)
└── main.dart
```

## Architecture Explanation

The app follows a **clean architecture** approach with the **BLoC pattern** for state management, ensuring separation of concerns and testability. Below is an overview of the architecture:

### Layers

1. **Presentation Layer** (`screens/`, `widgets/`):
    - **Screens**: UI components (`UserListScreen`, `UserDetailScreen`, `CreatePostScreen`, `LocalPostsScreen`) that render data and handle user interactions.
    - **Widgets**: Reusable UI components (e.g., `PostCard`, `TodoCard` in `user_detail_screen.dart`).
    - Uses `BlocBuilder` and `BlocListener` to react to state changes from `UserBloc` and `ThemeBloc`.
    - Features animations (fade-in, slide-in, scale) and theme-aware styling.

2. **Business Logic Layer** (`bloc/`):
    - **UserBloc**: Manages user-related state (fetching users, details, creating posts).
        - Events: `FetchUsers`, `FetchUserDetails`, `SearchUsers`, `CreatePost`.
        - States: `UserState` with separate statuses (`usersStatus`, `postsStatus`, `todosStatus`, `localPostsStatus`) and data (`users`, `posts`, `todos`, `localPosts`).
    - **ThemeBloc**: Manages theme switching (light/dark) and persistence.
        - Events: `LoadTheme`, `ToggleTheme`.
        - States: `ThemeState` with `themeData` and `isDark`.
    - Emits states to update the UI reactively.

3. **Data Layer** (`repositories/`, `services/`, `models/`):
    - **Repositories** (`user_repository.dart`): Abstracts data sources, interfacing between BLoC and services.
    - **Services** (`api_service.dart`): Handles HTTP requests to the DummyJSON API using the `http` package.
    - **Models** (`user.dart`, `post.dart`, `todo.dart`): Data classes for API responses, using `fromJson` for serialization.

### Data Flow

1. **User Interaction**: The user triggers an action (e.g., refresh, create post) in a screen.
2. **Event Emission**: The screen sends an event to the appropriate BLoC (e.g., `FetchUsers` to `UserBloc`).
3. **BLoC Processing**:
    - The BLoC processes the event, interacting with the repository.
    - The repository fetches data from the API service or local storage.
    - The BLoC emits a new state (e.g., `UserState` with `usersStatus: DataStatus.loaded`).
4. **UI Update**: The screen rebuilds using `BlocBuilder`, reflecting the new state (e.g., displaying users).
5. **Theme Management**: `ThemeBloc` updates `ThemeData` based on `ToggleTheme` or `LoadTheme`, applied globally via `main.dart`.

### Key Features

- **Separation of Concerns**: Each BLoC handles specific domains (user data, theme).
- **State Isolation**: `UserState` uses separate statuses for users, posts, todos, and local posts to prevent unnecessary rebuilds.
- **Reusability**: Widgets like `PostCard` and `TodoCard` are reused across screens.
- **Persistence**: Theme preferences are saved using `shared_preferences`.
- **Error Handling**: API and local errors are caught and displayed via `SnackBar` or error cards.

## Setup Instructions

### Prerequisites

- **Flutter SDK**: Version 3.19.0 or later.
- **Dart**: Version 3.3.0 or later.
- **IDE**: VS Code or Android Studio with Flutter plugin.
- **Git**: For cloning the repository.
- **Emulator/Device**: Android/iOS emulator or physical device for testing.

### Steps

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-username/user-app.git
   cd user-app
   ```

2. **Install Dependencies**:
   Ensure `pubspec.yaml` includes:
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     flutter_bloc: ^8.1.4
     equatable: ^2.0.5
     http: ^1.2.0
     shared_preferences: ^2.2.2
     
   ```
   Run:
   ```bash
   flutter pub get
   ```

3. **Set Up Emulator/Device**:
    - Start an Android/iOS emulator or connect a physical device.
    - Verify setup:
      ```bash
      flutter devices
      ```

4. **Run the App**:
   ```bash
   flutter run
   ```
   The app will build and launch on the selected device.

5. **Verify Features**:
    - **User List**: Check pagination, search, and pull-to-refresh.
    - **User Details**: View posts, todos, and details; test animations and dialogs.
    - **Create Post**: Create a post with live preview; verify it appears in `LocalPostsScreen`.
    - **Theme Switching**: Toggle light/dark theme in `UserListScreen`; confirm persistence.
    - **Error Handling**: Simulate network failure to test error states.

### Troubleshooting

- **Dependency Issues**:
    - Run `flutter clean` and `flutter pub get` if packages fail to resolve.
- **API Errors**:
    - Ensure internet connectivity; the app uses https://dummyjson.com/.
    - Check `api_service.dart` for correct endpoints.
- **Theme Issues**:
    - Verify `ThemeBloc` is initialized in `main.dart`.
    - Check `shared_preferences` dependency.
- **Build Errors**:
    - Ensure Flutter and Dart versions match prerequisites.
    - Run `flutter doctor` to diagnose issues.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
