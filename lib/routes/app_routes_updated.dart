import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/travel_requests_dashboard/travel_requests_dashboard.dart';
import '../presentation/expenses_dashboard/expenses_dashboard.dart';
import '../presentation/travel_calendar/travel_calendar.dart';
import '../presentation/travel_request_detail_view/travel_request_detail_view.dart';
import '../presentation/expense_detail_view/expense_detail_view.dart';
import '../presentation/profile_settings/profile_settings.dart';
import '../presentation/manager_approval_dashboard/manager_approval_dashboard.dart';
import '../presentation/new_travel_request_form/new_travel_request_form.dart';
import '../presentation/new_expense_form/new_expense_form.dart';

class AppRoutes {
  static const String initial = '/';
  static const String splashScreen = '/splash-screen';
  static const String loginScreen = '/login-screen';
  
  // Keep old routes for compatibility
  static const String travelRequestsDashboard = '/travel-requests-dashboard';
  static const String newTravelRequestForm = '/new-travel-request-form';
  static const String travelRequestDetailView = '/travel-request-detail-view';
  static const String travelCalendar = '/travel-calendar';
  static const String managerApprovalDashboard = '/manager-approval-dashboard';
  
  // New expense routes
  static const String expensesDashboard = '/expenses-dashboard';
  static const String newExpenseForm = '/new-expense-form';
  static const String expenseDetailView = '/expense-detail-view';
  
  static const String profileSettings = '/profile-settings';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splashScreen: (context) => const SplashScreen(),
    loginScreen: (context) => const LoginScreen(),
    
    // Old routes (keeping for compatibility)
    travelRequestsDashboard: (context) => const TravelRequestsDashboard(),
    newTravelRequestForm: (context) => const NewTravelRequestForm(),
    travelRequestDetailView: (context) => const TravelRequestDetailView(),
    travelCalendar: (context) => const TravelCalendar(),
    managerApprovalDashboard: (context) => const ManagerApprovalDashboard(),
    
    // New expense routes
    expensesDashboard: (context) => const ExpensesDashboard(),
    newExpenseForm: (context) => const NewExpenseForm(),
    expenseDetailView: (context) => const ExpenseDetailView(expense: null), // Will be handled with arguments
    
    profileSettings: (context) => const ProfileSettings(),
  };

  // Route generator for handling arguments
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case expenseDetailView:
        final expense = settings.arguments;
        if (expense != null) {
          return MaterialPageRoute(
            builder: (context) => ExpenseDetailView(expense: expense),
          );
        }
        break;
      case newExpenseForm:
        final expense = settings.arguments;
        return MaterialPageRoute(
          builder: (context) => NewExpenseForm(expense: expense),
        );
      case travelRequestDetailView:
        final request = settings.arguments;
        if (request != null) {
          return MaterialPageRoute(
            builder: (context) => TravelRequestDetailView(request: request),
          );
        }
        break;
      case newTravelRequestForm:
        final request = settings.arguments;
        return MaterialPageRoute(
          builder: (context) => NewTravelRequestForm(request: request),
        );
    }
    
    // Check if route exists in routes map
    if (routes.containsKey(settings.name)) {
      return MaterialPageRoute(
        builder: routes[settings.name]!,
      );
    }
    
    // Default route
    return MaterialPageRoute(
      builder: (context) => const ExpensesDashboard(),
    );
  }
}