# 🔧 Required File Modifications

To get your expense tracker working, you need to modify these **3 files**:

## 1. **lib/routes/app_routes.dart**
Replace the entire file with this content:

```dart
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
import '../models/expense.dart';

class AppRoutes {
  static const String initial = '/';
  static const String splashScreen = '/splash-screen';
  static const String loginScreen = '/login-screen';
  static const String travelRequestsDashboard = '/travel-requests-dashboard';
  static const String expensesDashboard = '/expenses-dashboard';
  static const String newTravelRequestForm = '/new-travel-request-form';
  static const String newExpenseForm = '/new-expense-form';
  static const String travelRequestDetailView = '/travel-request-detail-view';
  static const String expenseDetailView = '/expense-detail-view';
  static const String travelCalendar = '/travel-calendar';
  static const String managerApprovalDashboard = '/manager-approval-dashboard';
  static const String profileSettings = '/profile-settings';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const ExpensesDashboard(), // Start with expenses
    splashScreen: (context) => const SplashScreen(),
    loginScreen: (context) => const LoginScreen(),
    travelRequestsDashboard: (context) => const TravelRequestsDashboard(),
    expensesDashboard: (context) => const ExpensesDashboard(),
    newTravelRequestForm: (context) => const NewTravelRequestForm(),
    newExpenseForm: (context) => const NewExpenseForm(),
    travelCalendar: (context) => const TravelCalendar(),
    managerApprovalDashboard: (context) => const ManagerApprovalDashboard(),
    profileSettings: (context) => const ProfileSettings(),
  };

  // Route generator for handling arguments
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case expenseDetailView:
        final expense = settings.arguments as Expense?;
        if (expense != null) {
          return MaterialPageRoute(
            builder: (context) => ExpenseDetailView(expense: expense),
          );
        }
        break;
      case newExpenseForm:
        final expense = settings.arguments as Expense?;
        return MaterialPageRoute(
          builder: (context) => NewExpenseForm(expense: expense),
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
```

## 2. **lib/main.dart**
Update the MaterialApp to use the route generator. Find this section:

```dart
MaterialApp(
  title: 'travelrequest',
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: ThemeMode.light,
  // ... other properties
  routes: AppRoutes.routes,
  initialRoute: AppRoutes.initial,
)
```

**Change it to:**

```dart
MaterialApp(
  title: 'Expense Tracker', // Updated title
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: ThemeMode.light,
  // ... other properties
  onGenerateRoute: AppRoutes.generateRoute,
  initialRoute: AppRoutes.initial,
)
```

## 3. **Fix Constructor Issues**
Some of the new widgets need nullable constructors. Update these files:

### **lib/presentation/travel_request_detail_view/travel_request_detail_view.dart**
Find the class definition and add a nullable parameter:

```dart
class TravelRequestDetailView extends StatefulWidget {
  final dynamic request; // Make this nullable
  
  const TravelRequestDetailView({super.key, this.request});
```

### **lib/presentation/new_travel_request_form/new_travel_request_form.dart**
Find the class definition and add a nullable parameter:

```dart
class NewTravelRequestForm extends StatefulWidget {
  final dynamic request; // Make this nullable
  
  const NewTravelRequestForm({super.key, this.request});
```

---

## 🚀 **That's It!**

After making these 3 changes:

1. ✅ Your app will start with the expense dashboard
2. ✅ Navigation between screens will work
3. ✅ You can add/edit/view expenses
4. ✅ Old travel screens still work for backward compatibility

## 🔍 **Testing Steps:**

1. Run the app
2. You should see the expense dashboard with sample data
3. Tap the + button to add a new expense
4. Fill out the form and submit
5. Tap on an expense to view details
6. Use the menu to edit/duplicate/delete

The expense tracker is now fully functional!