import 'package:bloc/bloc.dart';
import 'package:medlink_mobileapp/core/error/failure.dart';
import 'package:medlink_mobileapp/features/auth/domain/usecase/user_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class UserBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUserUseCase registerUserUseCase;
  final VerifySignupUseCase verifySignupUseCase;
  final LoginUseCase loginUseCase;
  final RefreshTokenUseCase refreshTokenUseCase;
  final LogoutUseCase logoutUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final ResendVerificationCodeUseCase resendVerificationCodeUseCase;

  UserBloc({
    required this.registerUserUseCase,
    required this.verifySignupUseCase,
    required this.loginUseCase,
    required this.refreshTokenUseCase,
    required this.logoutUseCase,
    required this.forgotPasswordUseCase,
    required this.resetPasswordUseCase,
    required this.resendVerificationCodeUseCase,
  }) : super(AuthInitial()) {
    on<RegisterRequested>(_onRegisterRequested);
    on<ResendVerificationCodeRequested>(_onResendVerificationCodeRequested);
    on<VerifySignupRequested>(_onVerifySignupRequested);
    on<LoginRequested>(_onLoginRequested);
    on<RefreshTokenRequested>(_onRefreshTokenRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
  }

  Future<void> _onRegisterRequested(
      RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await registerUserUseCase.register(
      event.name,
      event.email,
      event.password,
      event.userType,
    );
    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (response) => emit(AuthRegistered(
        email: event.email,
        userType: event.userType,
        resendAt: response.resendAt,
      )),
    );
  }

  Future<void> _onResendVerificationCodeRequested(
      ResendVerificationCodeRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await resendVerificationCodeUseCase.resend(
      event.name,
      event.email,
      event.password,
      event.userType,
    );
    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (response) => emit(AuthRegistered(
        email: event.email,
        userType: event.userType,
        resendAt: response.resendAt,
      )),
    );
  }

  Future<void> _onVerifySignupRequested(
      VerifySignupRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await verifySignupUseCase.verify(
      event.email,
      event.userType,
      event.otpCode,
    );
    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (success) => emit(AuthVerified()),
    );
  }

  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await loginUseCase.login(
      event.email,
      event.userType,
      event.password,
      event.rememberMe,
    );

    if (result.isLeft()) {
      final failure = result.fold((failure) => failure, (_) => null)!;

      emit(AuthError(message: _mapFailureToMessage(failure)));
    } else {
      final user = result.fold((_) => null, (user) => user)!;
      await _storeTokens(user.accessToken!, user.refreshToken, user.expiresAt);

      emit(AuthAuthenticated(user: user));
    }
  }

  Future<void> _onRefreshTokenRequested(
      RefreshTokenRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result =
        await refreshTokenUseCase.refresh(event.refreshToken, event.userType);
    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (user) async {
        // await _storeTokens(user.accessToken!, null, user.expiresAt);
        emit(AuthAuthenticated(user: user));
      },
    );
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await logoutUseCase.logout(event.accessToken);
    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (success) async {
        await _clearTokens();
        emit(AuthInitial());
      },
    );
  }

  Future<void> _onForgotPasswordRequested(
      ForgotPasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result =
        await forgotPasswordUseCase.forgotPassword(event.email, event.userType);
    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (success) => emit(AuthPasswordResetRequested()),
    );
  }

  Future<void> _onResetPasswordRequested(
      ResetPasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await resetPasswordUseCase.reset(
      event.email,
      event.userType,
      event.password,
      event.otpCode,
    );
    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (success) => emit(AuthPasswordReset()),
    );
  }

  Future<void> _storeTokens(
      String accessToken, String? refreshToken, int? expiresAt) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', accessToken);
      if (refreshToken != null)
        await prefs.setString('refresh_token', refreshToken);
      if (expiresAt != null) await prefs.setInt('expires_at', expiresAt);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('expires_at');
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      String message = failure.message;
      if (message.contains('A verification code already sent')) {
        return 'A verification code has already been sent to your email. Please check your inbox or wait a few moments before requesting a new one.';
      } else if (message.contains('Invalid user input supplied')) {
        return 'Invalid input provided. Please check your details and try again.';
      } else if (message.contains('Incorrect otp code')) {
        return 'The OTP you entered is incorrect. Please try again.';
      } else if (message.contains('Too many trials')) {
        return 'Too many attempts. Please wait a while before trying again.';
      } else if (message.contains('Verification doesn\'t exist')) {
        return 'Verification link has expired or was already used. Please request a new one.';
      } else if (message.contains('Incorrect email or password')) {
        return 'Incorrect email or password. Please try again.';
      } else if (message.contains('Authorization required')) {
        return 'Authentication failed. Please log in again.';
      } else if (message.contains('Account doesn\'t exist')) {
        return 'No account found with this email. Please register first.';
      } else if (message.contains('A password reset link already sent')) {
        return 'A password reset link has already been sent to your email. Please check your inbox or wait a few moments.';
      } else if (message.contains('Invalid or expired password reset link')) {
        return 'The password reset link is invalid or has expired. Please request a new one.';
      } else if (message.contains('Email already exists')) {
        return 'A user with this email already exists. Please use a different email.';
      }
      return message;
    } else if (failure is ConnectionFailure) {
      return 'No internet connection. Please check your network and try again.';
    } else if (failure is UnexpectedFailure) {
      return 'An unexpected error occurred. Please try again later.';
    }
    return 'An unexpected error occurred.';
  }
}
