import 'package:deivao_modules/deivao_modules.dart';

import 'features/core/core_module.dart';
import 'features/home/home_module.dart';

final injector = InjectionContainer();

class InjectionContainer {
  final CustomAutoInjector _injector;
  final ModulesInitializer _modulesInitializer;

  InjectionContainer()
      : _injector = CustomAutoInjector(),
        _modulesInitializer = ModulesInitializer();

  InjectionContainer.test({
    required CustomAutoInjector injector,
    required ModulesInitializer modulesInitializer,
  })  : _modulesInitializer = modulesInitializer,
        _injector = injector;

  /// ### All the modules that the app has. <br/>
  /// It's used to initialize the dependencies. <br/><br/>
  static final modules = <Module>[
    CoreModule(),
    HomeModule(),
  ];

  T get<T>() => _injector.get<T>();
  Future<void> init() async {
    /// ### Initialize the modules.
    /// It's used to initialize the dependencies.
    _modulesInitializer.addModules(modules);
    await _modulesInitializer.initAllModules();

    /// ### Initialize the global injector.
    /// Add the injectors of the modules created on the modulesInitializer.
    ///
    /// Note: It should not be used when you connect the module to the router.
    for (final module in modules) {
      // ignore: invalid_use_of_visible_for_testing_member
      if (module.injector != null) _injector.addInjector(module.injector!);
    }
    _injector.commit();
  }
}
