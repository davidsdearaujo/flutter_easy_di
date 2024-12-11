part of 'architecture.dart';

/// A mixin that provides [ViewModel] functionality to a [State] object.
///
/// This mixin handles the lifecycle of a [ViewModel], including creation and
/// updates. It automatically creates the [ViewModel] when the State is
/// initialized and rebuilds the widget when the [ViewModel] changes.
///
/// The type parameter [T] must be a [ViewModel].
///
/// Example usage:
/// ```dart
/// class _MyWidgetState extends State<MyWidget> with ViewModelStateMixin<MyViewModel> {
///   @override
///   Widget build(BuildContext context) {
///     return Text(viewModel.someValue);
///   }
/// }
/// ```
///
/// The mixin will automatically:
/// - Create the ViewModel when dependencies change
/// - Rebuild the widget when the ViewModel updates
mixin ViewModelStateMixin<T extends ViewModel> {
  /// The build context for this widget.
  BuildContext get context;

  /// Method to trigger a rebuild of the widget.
  void setState(VoidCallback fn);

  T? _viewModel;

  /// The ViewModel instance associated with this widget.
  ///
  /// This will throw if accessed before the ViewModel is created in [didChangeDependencies].
  T get viewModel => _viewModel!;

  /// Called when a dependency of this State object changes.
  ///
  /// This implementation creates a new ViewModel instance and sets up listeners.
  ///
  /// If a previous ViewModel exists, it removes the listener before creating
  /// the new instance. The new ViewModel is obtained from the [Module] system
  /// using the current build context.
  void didChangeDependencies() {
    if (_viewModel != null) {
      viewModel.removeListener(_onViewModelUpdate);
    }
    _viewModel = Module.get<T>(context);
    viewModel.addListener(_onViewModelUpdate);
  }

  /// Callback that triggers a rebuild when the ViewModel changes.
  void _onViewModelUpdate() {
    setState(() {});
  }
}
