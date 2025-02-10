## 0.2.0
* Change initialize() for init() in `Module`;
* Create and export `Module.of()` to get the current module;

## 0.1.3
* Reduced the minimum version of `dart` to 3.4.0;

## 0.1.2
* Reduced the minimum version of `dart` to 3.5.2;

## 0.1.1
* Added `listen` property to `Module.get()` to enable widgets to rebuild when module dependencies change;
* Added dependency replacement methods:
  * `ModulesManager.instance.replace()` - Replaces a dependency across all modules;
  * `ModulesManager.instance.replaceFromModule()` - Replaces a dependency in a specific module;

## 0.1.0
* Changed the logging system to use debugPrint instead of print.
* Added a Logger class for logging, which can be enabled/disabled.
* Added a flag to ModuleWidget to enable/disable automatic dispose of modules when the widget is disposed.
* Changed few methods from `ModulesManager` to be more intuitive:
    * `addModule` -> `registerModule`
    * `addModules` -> `registerModules`
    * `initAllModules` -> `initRegisteredModules`
* Added tests for:
    * `Module`
    * `ModulesManager`
    * `ModuleWidget`
    * `Injector`
    * `Logger`

## 0.0.1
* Initial release.
