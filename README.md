# Modular DI (Dependency Injection)

Hey there! 👋 This is a super simple and flexible way to organize your Flutter app into modules, with some cool dependency injection features thrown in.

## Features

- 🎯 Keep your app tidy with a simple module system
- 💉 Easy dependency injection powered by [auto_injector](https://pub.dev/packages/auto_injector)
- 🔄 Modules can talk to each other through imports
- 🚀 Modules load up and clean up smoothly 
- 🎨 Drop in the ModuleWidget wherever you need it
- 🧪 Testing is a breeze with mock replacements
- 📊 Lightning-fast dependency resolution using directed acyclic graphs
- 🔌 Works with whatever router you love (Go Router, Auto Route, you name it!)

## Getting Started

Add to your `pubspec.yaml`:

```yaml
dependencies:
  modular_di: ^0.0.2
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

## Want to see it in action?
Check out our [example](example) to see how it all comes together!

## Want to help?
Got ideas? Found a bug? We'd love your help! Feel free to open a PR and join the fun.

## Legal stuff
This project uses the MIT License - check out [LICENSE](LICENSE) if you're into that kind of thing.

