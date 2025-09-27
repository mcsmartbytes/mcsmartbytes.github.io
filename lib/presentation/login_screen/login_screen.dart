import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import './widgets/company_logo_widget.dart';
import './widgets/login_form_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService.instance;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    // Check if user is already authenticated
    if (_authService.isAuthenticated) {
      final isValidSession = await _authService.validateSession();
      if (isValidSession) {
        Navigator.pushReplacementNamed(
            context, AppRoutes.travelRequestsDashboard);
      }
    }
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final response = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.session != null) {
        Navigator.pushReplacementNamed(
            context, AppRoutes.travelRequestsDashboard);
      } else {
        _showErrorSnackBar('Login failed. Please check your credentials.');
      }
    } catch (error) {
      String errorMessage = 'Login failed. Please try again.';

      if (error.toString().contains('Invalid login credentials')) {
        errorMessage =
            'Invalid email or password. Please check your credentials.';
      } else if (error.toString().contains('Email not confirmed')) {
        errorMessage = 'Please confirm your email before signing in.';
      } else if (error.toString().contains('Too many requests')) {
        errorMessage = 'Too many login attempts. Please try again later.';
      }

      _showErrorSnackBar(errorMessage);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      // For demo purposes, using a default full name
      final fullName = _emailController.text
          .split('@')[0]
          .replaceAll('.', ' ')
          .split(' ')
          .map(
              (word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
          .join(' ');

      final response = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: fullName,
        role: 'employee',
      );

      if (response.user != null) {
        _showSuccessSnackBar(
            'Account created successfully! Please check your email to confirm your account.');
        // You might want to navigate to email confirmation screen
      }
    } catch (error) {
      String errorMessage = 'Failed to create account. Please try again.';

      if (error.toString().contains('User already registered')) {
        errorMessage =
            'An account with this email already exists. Please sign in instead.';
      } else if (error
          .toString()
          .contains('Password should be at least 6 characters')) {
        errorMessage = 'Password should be at least 6 characters long.';
      } else if (error
          .toString()
          .contains('Unable to validate email address')) {
        errorMessage = 'Please enter a valid email address.';
      }

      _showErrorSnackBar(errorMessage);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleForgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter your email address first.');
      return;
    }

    try {
      await _authService.resetPassword(_emailController.text.trim());
      _showSuccessSnackBar('Password reset link sent to your email!');
    } catch (error) {
      _showErrorSnackBar(
          'Failed to send reset link. Please check your email address.');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successLight,
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40),

                // Company Logo
                CompanyLogoWidget(),

                SizedBox(height: 48),

                // Welcome text
                Text(
                  'Welcome Back',
                  style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 8),

                Text(
                  'Sign in to access your travel requests',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 40),

                // Login Form
                LoginFormWidget(
                  formKey: _formKey,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  emailFocusNode: FocusNode(),
                  passwordFocusNode: FocusNode(),
                  isPasswordVisible: !_obscurePassword,
                  isLoading: _isLoading,
                  onTogglePasswordVisibility: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  onLogin: _handleSignIn,
                  onForgotPassword: _handleForgotPassword,
                ),

                SizedBox(height: 24),

                // Demo credentials info
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'info',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Demo Credentials',
                            style: AppTheme.lightTheme.textTheme.titleSmall
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.lightTheme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Employee: john.doe@travelcompany.com / employee123\nManager: manager@travelcompany.com / manager123\nAdmin: admin@travelcompany.com / admin123',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}