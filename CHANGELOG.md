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
