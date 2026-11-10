# Feature Implementation Guide

Templates mirror `lib/admin/monthly_payment_list/` (verified in source). Check a neighbouring feature first. User-app features (`lib/user/*`) are registered in `setupDi()` and provided from `MyApp`/shell; some admin screens provide locally.

## 1. Folder
```
lib/admin/<feature>/{cubit,model,repository,screen/widgets}
```

## 2. Endpoint
Add to `lib/core/constants/api_endpoints.dart`:
```dart
static const String myThing = "/api/Area/MyThing";
```
Confirm path and payload with API_INTEGRATION.md or the backend; do not guess.

## 3. Model
Follow `monthly_payment_list_model.dart`: `XResponseModel {status, message, data}` with `fromJson`, nested `XDataModel`. Parse defensively (nullable, defaults). See DATA_MODELS.md.

## 4. Repository
```dart
class MyRepository {
  MyRepository({required this.dio});
  final Dio dio;

  Future<MyResponseModel> getThing({CancelToken? cancelToken}) async {
    try {
      final response = await dio.get(ApiEndpoints.myThing, cancelToken: cancelToken);
      if (response.data is! Map<String, dynamic>) {
        throw Exception('Invalid response received from the server.');
      }
      final result = MyResponseModel.fromJson(response.data as Map<String, dynamic>);
      if (!result.status) {
        throw Exception(result.message.isNotEmpty ? result.message : 'Failed to fetch.');
      }
      return result;
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) rethrow;
      final d = e.response?.data;
      if (d is Map<String, dynamic> && d['message'] != null) {
        throw Exception(d['message'].toString());
      }
      // mirror the switch on e.type (timeouts / connection) from monthly_payment_list_repository.dart
      throw Exception('Network error. Please try again.');
    }
  }
}
```

## 5. State + Cubit
```dart
// my_state.dart
part of 'my_cubit.dart';
@immutable
sealed class MyState {}
final class MyInitial extends MyState {}
final class MyLoading extends MyState {}
final class MyLoaded extends MyState {
  MyLoaded({required this.data});
  final MyDataModel data;
}
final class MyError extends MyState {
  MyError({required this.message});
  final String message;
}

// my_cubit.dart
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
part 'my_state.dart';

class MyCubit extends Cubit<MyState> {
  MyCubit({required MyRepository repository})
      : _repository = repository,
        super(MyInitial());
  final MyRepository _repository;

  Future<void> fetch() async {
    emit(MyLoading());
    try {
      final r = await _repository.getThing();
      emit(MyLoaded(data: r.data));
    } catch (error, stackTrace) {
      log('Fetch failed: $error', name: 'MyCubit', error: error, stackTrace: stackTrace);
      emit(MyError(message: error.toString().replaceFirst('Exception: ', '')));
    }
  }
}
```
For refresh/submit, add flags to `Loaded` plus `copyWith` as in `PaymentListState`.

## 6. Provide the cubit
Screen-local (as in `monthly_payments_list_screen.dart`):
```dart
return RepositoryProvider(
  create: (_) => MyRepository(dio: getIt<Dio>()),
  child: BlocProvider(
    create: (context) => MyCubit(repository: context.read<MyRepository>()),
    child: const _MyView(),
  ),
);
```
Shared / user-app: register in `setupDi()`:
```dart
getIt.registerLazySingleton<MyRepository>(() => MyRepository(dio: getIt<Dio>()));
getIt.registerFactory<MyCubit>(() => MyCubit(repository: getIt<MyRepository>()));
```
then `BlocProvider(create: (_) => getIt<MyCubit>())` where used (app-wide ones in `MyApp`).

## 7. Screen
`BlocConsumer`/`BlocBuilder<MyCubit, MyState>`; handle loading, error (with retry) and loaded; use `BlocListener` on `actionMessage` to show `AppSnackBar`. Use `AppColors`, `core/utils` widgets; keep layouts responsive (RESPONSIVE_DESIGN.md). Admin screens are wide; user screens are mobile portrait.

## 8. Navigation
Admin: add the screen to the shell in `lib/admin/navigation/admin_main_screen.dart` and gate with `admin_nav_permissions.dart` (ADMIN_NAVIGATION.md). User: `lib/user/navigation/user_main_screen.dart` (USER_NAVIGATION.md). Detail screens: confirm the push mechanism in NAVIGATION.md.

## 9. Reuse
Search `lib/core/utils/` and sibling `widgets/` first (snack bar, toast, currency formatter, top bar, footer, photo picker, media URL, go-to-top). Do not duplicate.

## 10. Finish
`flutter analyze`, `flutter test`, update the module doc in `docs/modules/` and API_INTEGRATION / DATA_MODELS / DOC_COVERAGE entries.
