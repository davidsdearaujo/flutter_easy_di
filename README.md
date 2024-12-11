# Deivao Modules

A lightweight and flexible module system for Flutter applications, providing dependency injection and module management capabilities.

## Features

- 🎯 Simple module system for organizing application features
- 💉 Built-in dependency injection using auto_injector
- 🔄 Module imports to handle dependencies between features
- 🚀 Easy module initialization and disposal
- 🎨 Widget integration through ModuleWidget
- 🧪 Testing utilities with replace and reset capabilities

## Getting Started

Add deivao_modules to your pubspec.yaml:

```yaml
dependencies:
  deivao_modules: ^0.0.1
```

## Usage

### Creating a Module

Create a module by extending the `Module` class:

```dart
class UserModule extends Module {
  @override
  List<Type> imports = []; // Add other modules to import if needed

  @override
  FutureOr<void> registerBinds(InjectorRegister i) {
    // Register your dependencies
    i.addSingleton<UserRepository>(() => UserRepositoryImpl());
    i.addSingleton<UserService>(() => UserServiceImpl());
  }
}
```

### Using ModulesManager

Initialize and manage your modules using `ModulesManager`:

```dart
void main() async {
  ModulesManager.instance.registerModules([
    UserModule(),
    AuthModule(),
  ]);

  await ModulesManager.instance.initializeModules();
  
  runApp(const MyApp());
}
```

### Accessing Dependencies

Use `ModuleWidget` to provide module access and `Module.get<T>()` to retrieve dependencies:

```dart
class UserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ModuleWidget<UserModule>(
      child: Builder(
        builder: (context) {
          final userService = Module.get<UserService>(context);
          return UserContent(service: userService);
        },
      ),
    );
  }
}
```

### Module Dependencies

Modules can depend on other modules using the `imports` property:

```dart
class ProfileModule extends Module {
  @override
  List<Type> imports = [UserModule]; // Import dependencies from UserModule

  @override
  FutureOr<void> registerBinds(InjectorRegister i) {
    i.addSingleton<ProfileService>(ProfileServiceImpl.new);
  }
}
```

## Dependency Injection Types

The package supports different types of dependency injection:

- **Singleton**: `addSingleton<T>()` - Creates a single instance that persists throughout the app
- **Lazy Singleton**: `addLazySingleton<T>()` - Creates a singleton instance only when first requested
- **Factory**: `add<T>()` - Creates a new instance each time it's requested
- **Instance**: `addInstance<T>()` - Registers an existing instance
- **Replace**: `replace<T>()` - Replaces an existing registration (Useful for testing)

## Complete Example
[example](example)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

