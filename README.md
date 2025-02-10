<a name="readme-top"></a>


<h1 align="center">Modular DI (Dependency Injection)</h1>

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <!-- You should link the logo to the pub dev page of you project or a homepage otherwise -->
  <a href="https://github.com/davidsdearaujo/modular_di/">
    <img src="https://raw.githubusercontent.com/davidsdearaujo/modular_di/main/readme_assets/logo.webp" alt="Logo" width="180">
  </a>

  <p align="center">
    A simple way to organize dependency injection using modules.
    <br />
    <!-- Put the link for the documentation here -->
    <a href="https://pub.dev/documentation/modular_di/latest/"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <!-- Disable unused links with with comments -->
    <!--<a href="https://pub.dev/publishers/deivao.dev/packages">View Demo</a> -->
    <!-- The Report Bug and Request Feature should point to the issues page of the project, in this example we use the pull requests page because this is a github template -->
    <a href="https://github.com/davidsdearaujo/modular_di/issues">Report Bug</a>
    ·
    <a href="https://github.com/davidsdearaujo/modular_di/issues">Request Feature</a>
  </p>

<br>

<!--  SHIELDS  ---->


<!-- The shields here are an example of what could be used and are the most recommended, there are more below in the "some recomendations about shields" section. 
See the links in the example below, changing the parts after img.shields.io you can change the content of the shields. Alternatively, go to the website and generate new shields.  

The ones used here are:
- Release version
- Pub Points
- publisher: deivao.dev --->

[![Version](https://img.shields.io/github/v/release/davidsdearaujo/modular_di?style=plastic)](https://pub.dev/packages/modular_di)
[![Pub Points](https://img.shields.io/pub/points/modular_di?label=pub%20points&style=plastic)](https://pub.dev/packages/modular_di/score)

[![Pub Publisher](https://img.shields.io/pub/publisher/modular_di?style=plastic)](https://pub.dev/publishers/deivao.dev/packages)
</div>

<!----
About Shields, some recommendations:
+-+
Build - GithubWorkflow ou Github Commit checks state
CodeCoverage - Codecov
Chat - Discord 
License - Github
Rating - Pub Likes, Pub Points and Pub Popularity (if still in early stages, we recommend only Pub Points since it's controllable)
Social - GitHub Forks, Github Org's Stars (if using Flutterando as the main org), YouTube Channel Subscribers (Again, using Flutterando, as set in the example)
--->

---

<br>
Hey there! 👋 This is a super simple and flexible way to organize your Flutter app into modules, with a dependency injection features thrown in.


## Features

- 🔌 Works with whatever router you love (Go Router, Auto Route, you name it!)
- 🎯 Keep your app tidy with a simple module system
- 💉 Easy dependency injection powered by [auto_injector](https://pub.dev/packages/auto_injector)
- 🔄 Modules can talk to each other through imports
- 🚀 Modules load up and clean up smoothly 
- 🎨 Drop in the ModuleWidget wherever you need it
- 🧪 Testing is a breeze with mock replacements
- 📊 Lightning-fast dependency resolution using directed acyclic graphs

## Getting Started

Add to your `pubspec.yaml`:

```yaml
dependencies:
  modular_di: <last version>
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
  WidgetsFlutterBinding.ensureInitialized();

  //Register and initialize modules
  await ModulesManager.instance.initModules([
    UserModule(),
    AuthModule(),
  ]);
  
  runApp(const MyApp());
}
```

#### Registering Modules separately
You can register modules in any order from anywhere, as long as you register them before initializing them.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register CoreModule
  ModulesManager.instance.registerModule(CoreModule());

  // Register User and Auth modules
  ModulesManager.instance.registerModules([
    UserModule(),
    AuthModule(),
  ]);

  // Initialize all the registered modules
  await ModulesManager.instance.initRegisteredModules();
  
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
          // Without listening to changes
          final userService = Module.get<UserService>(context);
          return UserContent(service: userService);
        },
      ),
    );
  }
}
```

### Accessing Current Module

Use `ModuleWidget` to provide module access and `Module.of()` to retrieve dependencies:

```dart
class UserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ModuleWidget<UserModule>(
      child: Builder(
        builder: (context) {
          // Without listening to changes
          final userService = Module.get<UserService>(context);
          final userModule = Module.of(context);
          final String module = userModule.runtimeType.toString();
          return UserContent(service: userService);
        },
      ),
    );
  }
}
```

#### Listening to Module Changes

It's recommended to use `listen: true` when getting dependencies, especially if you're working with modules that might be reset or if you're using imported modules. This ensures your widget rebuilds when dependencies are updated:

```dart
class UserProfileWidget extends StatefulWidget {
  @override
  State<UserProfileWidget> createState() => _UserProfileWidgetState();
}

class _UserProfileWidgetState extends State<UserProfileWidget> {
  late UserService _userService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // With listening to changes - widget will rebuild when:
    // 1. The current module is reset
    // 2. Any imported module is disposed/reset
    _userService = Module.get<UserService>(context, listen: true);
  }

  @override
  Widget build(BuildContext context) {
    return Text(_userService.username);
  }
}
```

For example, if `UserModule` imports `AuthModule`, and you dispose `AuthModule` using:
```dart
await ModulesManager.instance.disposeModule<AuthModule>();
```
Any widget using `listen: true` with dependencies from `UserModule` will automatically rebuild with the new dependencies.

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

## Logging

The package includes a built-in logging system that can be enabled/disabled as needed:

```dart
import 'package:modular_di/logger.dart';

// Enable logging (disabled by default)
Logger.enable();

// Disable logging
Logger.disable();
```

Logs will only be printed in debug mode, making it safe to leave logging code in production.

## Want to see it in action?
Check out our [example](example) to see how it all comes together!

## Want to help?
Got ideas? Found a bug? We'd love your help! Feel free to open a PR and join the fun.

## Legal stuff
This project uses the MIT License - check out [LICENSE](LICENSE) if you're into that kind of thing.

