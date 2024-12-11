# Architecture Overview

This document describes the architectural patterns used in this project, which follows a modular approach with clear separation of concerns.

## Core Concepts

### 1. Modules

Modules are self-contained features that encapsulate all the dependencies and logic for a specific part of the application. Each module:

- Contains its own dependencies
- Can import other modules
- Has its own dependency injection container
- Is isolated from other modules unless explicitly imported

Example of a module:
```dart
class UserModule extends Module {
  @override
  List<Type> imports = [CoreModule];

  @override
  Future<void> registerBinds(InjectorRegister i) async {
    i.addSingleton<UserRepository>(() => UserRepositoryImpl());
    i.addSingleton<UserService>(() => UserServiceImpl());
  }
}
```

### 2. Layer Organization

Each module follows a clean architecture approach with the following layers:
```
feature/
├── data/
│ ├── repositories/
│ └── services/
├── domain/
│ ├── models/
│ └── repositories/
└── ui/
├── commands/
├── screens/
└── view_models/
```

### 3. ViewModels

ViewModels serve as the bridge between UI and business logic. They:

- Hold the UI state
- Execute commands
- Handle UI logic
- Notify listeners of changes

Example implementation can be found in:
[example/lib/features/profile/ui/view_models/profile_view_model.dart](example/lib/features/profile/ui/view_models/profile_view_model.dart)


### 4. Commands

Commands encapsulate single operations or use cases. They:

- Handle a single responsibility
- Manage their own loading and error states
- Execute business logic
- Return results to ViewModels

Example implementation can be found in:
[example/lib/features/profile/ui/commands/get_profile_command.dart](example/lib/features/profile/ui/commands/get_profile_command.dart)


### 5. Dependency Injection

The architecture uses a dependency injection system that supports:

- Singletons
- Factory instances
- Lazy singletons
- Instance replacement (useful for testing)

## Implementation Guide

### 1. Creating a New Feature

1. Create a new module:
```dart
class NewFeatureModule extends Module {
  @override
  List<Type> imports = [];

  @override
  Future<void> registerBinds(InjectorRegister i) async {
    // Register your dependencies
  }
}
```
2. Create the domain layer (models and repository interfaces)
3. Create the data layer (repository implementations and services)
4. Create the UI layer (commands, view models, and screens)

### 2. Using ViewModels with Widgets

Use the `ViewModelStateMixin` to easily connect widgets with ViewModels:
```dart
class MyScreenState extends State<MyScreen> with ViewModelStateMixin<MyViewModel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: switch (viewModel) {
        MyViewModel vm when vm.loading => const CircularProgressIndicator(),
        MyViewModel vm when vm.errors.isNotEmpty => Text(vm.errors.join('\n')),
        MyViewModel vm => YourSuccessWidget(data: vm.data),
      },
  );
  }
}
```

### 3. Handling Module Dependencies

When a module depends on another module:

1. Add the dependency to the imports list
2. Use the dependency's services through dependency injection
3. The framework will handle initialization order automatically

Example:
[example/lib/features/profile/profile_module.dart](example/lib/features/profile/profile_module.dart)


### 4. Testing

The architecture supports easy testing through:

- Dependency replacement
- Module resetting
- Singleton disposal

Example of replacing a dependency for testing:
```dart
void main() {
  setUp(() async {
    final module = MyModule();
    await module.initialize();
    module.injector?.replace<MyService>(MockMyService());
  });
}
```


## Best Practices

1. **Module Independence**: Keep modules as independent as possible
2. **Single Responsibility**: Each command should handle one operation
3. **State Management**: Use ViewModels for UI state, Commands for operations
4. **Error Handling**: Use the built-in error handling in Commands
5. **Testing**: Write tests at all layers (UI, ViewModel, Command, Repository)
6. **Dependency Injection**: Register dependencies with appropriate lifecycles
7. **Clean Architecture**: Maintain separation between layers

## Common Pitfalls

1. Circular dependencies between modules
2. Mixing UI logic in Commands
3. Not disposing of resources properly
4. Accessing ViewModels before initialization
5. Tight coupling between modules

## Additional Resources

For more examples and implementation details, refer to:
[example/lib/main_standalone.dart](example/lib/main_standalone.dart)
