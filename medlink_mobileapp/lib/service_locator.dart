import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:medlink_mobileapp/core/network_info.dart';
import 'package:medlink_mobileapp/features/Pharmacy/data/data_source/profile_remote_data_source.dart';
import 'package:medlink_mobileapp/features/Pharmacy/data/repository/profile_repository.dart';
import 'package:medlink_mobileapp/features/Pharmacy/domain/usecase/profile_usecase.dart';
import 'package:medlink_mobileapp/features/Pharmacy/presentation/bloc/profile_bloc.dart';
import 'package:medlink_mobileapp/features/auth/data/data_source/remote_data_source.dart';
import 'package:medlink_mobileapp/features/auth/data/repository/user_repository_impl.dart';
import 'package:medlink_mobileapp/features/auth/domain/usecase/user_usecase.dart';
import 'package:medlink_mobileapp/features/auth/presentation/bloc/user_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

GetIt getIt = GetIt.instance;

Future<void> setup() async {
  var sharedPreference = await SharedPreferences.getInstance();
  var client = http.Client();
  var connectivity = InternetConnectionChecker();
  getIt.registerSingleton<InternetConnectionChecker>(connectivity);
  getIt.registerSingleton<NetworkInfo>(NetworkInfoImpl(getIt()));
  getIt.registerSingleton<SharedPreferences>(sharedPreference);
  getIt.registerSingleton<http.Client>(client);
  getIt.registerSingleton<UserRemoteDataSource>(UserRemoteDataSourceImpl(client: getIt()));
  getIt.registerSingleton<UserRepository>(UserRepositoryImpl(remoteDataSource: getIt(),networkInfo: getIt(),));
  getIt.registerSingleton<RegisterUserUseCase>(RegisterUserUseCase(getIt()));
  getIt.registerSingleton<ResendVerificationCodeUseCase>(ResendVerificationCodeUseCase(getIt()));
  getIt.registerSingleton<VerifySignupUseCase>(VerifySignupUseCase(getIt()));
  getIt.registerSingleton<LoginUseCase>(LoginUseCase(getIt()));
  getIt.registerSingleton<RefreshTokenUseCase>(RefreshTokenUseCase(getIt()));
  getIt.registerSingleton<LogoutUseCase>(LogoutUseCase(getIt()));
  getIt.registerSingleton<ForgotPasswordUseCase>(ForgotPasswordUseCase(getIt()));
  getIt.registerSingleton<ResetPasswordUseCase>(ResetPasswordUseCase(getIt()));
  getIt.registerSingleton<UserBloc>(UserBloc(
    registerUserUseCase: getIt(),
    resendVerificationCodeUseCase: getIt(),
    verifySignupUseCase: getIt(),
    loginUseCase: getIt(),
    refreshTokenUseCase: getIt(),
    logoutUseCase: getIt(),
    forgotPasswordUseCase: getIt(),
    resetPasswordUseCase: getIt(),
  ));

getIt.registerSingleton<ProfileRemoteDataSource>(ProfileRemoteDataSourceImpl(getIt()));
getIt.registerSingleton<ProfileRepository>(ProfileRepositoryImpl(getIt()));
getIt.registerSingleton<GetProfileUseCase>(GetProfileUseCase(getIt()));
getIt.registerSingleton<UpdateProfileUseCase>(UpdateProfileUseCase(getIt()));
getIt.registerSingleton<ProfileBloc>(ProfileBloc(getIt(), getIt()));


}
