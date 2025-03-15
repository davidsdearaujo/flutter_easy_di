## 0.3.0
* Changed the name of the package to `flutter_easy_di`;
* Changed the name of the class `Module` to `EasyModule`;
* Changed the name of the class `ModuleWidget` to `EasyModuleWidget`;

### Deprecated
Few methods were deprecated, now all the methods are static and can be accessed directly from the class. Instead of using `ModulesManager.instance`, you should use `EasyDI` directly. Here is how to migrate:
  * `ModulesManager.instance.registerModule(module)` -> `EasyDI.registerModules([module])`;
  * `Module.get<T>()` -> `EasyDI.get<T>()` to get a dependency from the current module;
  * `ModulesManager.instance.disposeModule<T>()` -> `EasyDI.disposeModule<T>()` to dispose a module;
  * `ModulesManager.instance.replace<T>()` -> `EasyDI.replace<T>()` to replace a dependency;
  * `ModulesManager.instance.replaceFromModule<TModule, TInstance>()` -> `EasyDI.replaceFromModule<TModule, TInstance>()` to replace a dependency in a specific module;
  * `ModulesManager.instance.reset()` -> `EasyDI.reset()` to reset all registered modules;
  * `ModulesManager.instance.registerModules(modules)` -> `EasyDI.registerModules(modules)` to register multiple modules;
  * `ModulesManager.instance.initModules(modules)` -> `EasyDI.initModules(modules)` to initialize modules;
  * `ModulesManager.instance.initRegisteredModules()` -> `EasyDI.initRegisteredModules()` to initialize registered modules;

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
