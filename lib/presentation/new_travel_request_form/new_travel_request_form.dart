import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../services/travel_request_service.dart';
import './widgets/approval_section_widget.dart';
import './widgets/attendees_section_widget.dart';
import './widgets/business_justification_section_widget.dart';
import './widgets/cost_estimates_section_widget.dart';
import './widgets/dates_locations_section_widget.dart';
import './widgets/trip_details_section_widget.dart';

class NewTravelRequestForm extends StatefulWidget {
  const NewTravelRequestForm({super.key});

  @override
  State<NewTravelRequestForm> createState() => _NewTravelRequestFormState();
}

class _NewTravelRequestFormState extends State<NewTravelRequestForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final TravelRequestService _travelRequestService =
      TravelRequestService.instance;
  final AuthService _authService = AuthService.instance;

  bool _isLoading = false;
  bool _isSaving = false;
  List<UserProfile> _managers = [];

  // Form data
  Map<String, dynamic> formData = {
    'tripName': '',
    'businessJustification': '',
    'expectedOutcomes': '',
    'attendees': <Map<String, dynamic>>[],
    'departureDate': null,
    'departureTime': null,
    'returnDate': null,
    'returnTime': null,
    'originCity': '',
    'destinationCity': '',
    'transportationCost': 0.0,
    'accommodationCost': 0.0,
    'mealsCost': 0.0,
    'otherCost': 0.0,
    'totalCost': 0.0,
    'selectedManager': '',
    'comments': '',
    'status': 'draft',
  };

  // Section completion status
  Map<String, bool> sectionCompletion = {
    'tripDetails': false,
    'businessJustification': false,
    'attendees': false,
    'datesLocations': false,
    'costEstimates': false,
    'approval': false,
  };

  // Section expansion status
  Map<String, bool> sectionExpansion = {
    'tripDetails': true,
    'businessJustification': false,
    'attendees': false,
    'datesLocations': false,
    'costEstimates': false,
    'approval': false,
  };

  @override
  void initState() {
    super.initState();
    _calculateTotalCost();
    _loadManagers();
  }

  Future<void> _loadManagers() async {
    try {
      setState(() => _isLoading = true);
      final managers = await _travelRequestService.getManagers();
      setState(() {
        _managers = managers;
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load managers: $error');
    }
  }

  void _updateFormData(String key, dynamic value) {
    setState(() {
      formData[key] = value;
      _updateSectionCompletion();
      if (key.contains('Cost')) {
        _calculateTotalCost();
      }
    });
  }

  void _calculateTotalCost() {
    double total = (formData['transportationCost'] ?? 0.0) +
        (formData['accommodationCost'] ?? 0.0) +
        (formData['mealsCost'] ?? 0.0) +
        (formData['otherCost'] ?? 0.0);
    setState(() {
      formData['totalCost'] = total;
    });
  }

  void _updateSectionCompletion() {
    setState(() {
      sectionCompletion['tripDetails'] =
          (formData['tripName'] as String).isNotEmpty;

      sectionCompletion['businessJustification'] =
          (formData['businessJustification'] as String).isNotEmpty &&
              (formData['expectedOutcomes'] as String).isNotEmpty;

      sectionCompletion['attendees'] =
          (formData['attendees'] as List).isNotEmpty;

      sectionCompletion['datesLocations'] = formData['departureDate'] != null &&
          formData['returnDate'] != null &&
          (formData['originCity'] as String).isNotEmpty &&
          (formData['destinationCity'] as String).isNotEmpty;

      sectionCompletion['costEstimates'] =
          (formData['totalCost'] as double) > 0;

      sectionCompletion['approval'] =
          (formData['selectedManager'] as String).isNotEmpty;
    });
  }

  void _toggleSection(String section) {
    setState(() {
      sectionExpansion[section] = !sectionExpansion[section]!;
    });
  }

  bool _validateAdvanceBooking() {
    if (formData['departureDate'] != null) {
      DateTime departureDate = formData['departureDate'] as DateTime;
      DateTime now = DateTime.now();
      int daysDifference = departureDate.difference(now).inDays;
      return daysDifference >= 10;
    }
    return true;
  }

  void _showAdvanceBookingWarning() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Advance Booking Warning',
            style: AppTheme.lightTheme.textTheme.titleMedium,
          ),
          content: Text(
            'Your travel date is less than 10 days away. This may affect approval processing time and availability of preferred options.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _submitForm();
              },
              child: Text('Submit Anyway'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveDraft() async {
    if (_isSaving) return;

    try {
      setState(() => _isSaving = true);

      formData['status'] = 'draft';
      await _travelRequestService.createTravelRequest(formData);

      _showSuccessSnackBar('Draft saved successfully');
      Navigator.pushReplacementNamed(
          context, AppRoutes.travelRequestsDashboard);
    } catch (error) {
      _showErrorSnackBar('Failed to save draft: $error');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    try {
      setState(() => _isSaving = true);

      formData['status'] = 'pending';
      await _travelRequestService.createTravelRequest(formData);

      _showSuccessSnackBar('Travel request submitted successfully');
      Navigator.pushReplacementNamed(
          context, AppRoutes.travelRequestsDashboard);
    } catch (error) {
      _showErrorSnackBar('Failed to submit travel request: $error');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _handleSubmit() {
    if (!_validateAdvanceBooking()) {
      _showAdvanceBookingWarning();
    } else {
      _submitForm();
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'New Travel Request',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'close',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveDraft,
            child: _isSaving
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Save Draft',
                    style: TextStyle(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  // Progress indicator
                  Container(
                    padding: EdgeInsets.all(16),
                    child: LinearProgressIndicator(
                      value: sectionCompletion.values
                              .where((completed) => completed)
                              .length /
                          6,
                      backgroundColor: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  ),

                  // Form sections
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          SizedBox(height: 8),

                          // Trip Details Section
                          TripDetailsSectionWidget(
                            isExpanded: sectionExpansion['tripDetails']!,
                            isCompleted: sectionCompletion['tripDetails']!,
                            onToggle: () => _toggleSection('tripDetails'),
                            tripName: formData['tripName'] as String,
                            onTripNameChanged: (value) =>
                                _updateFormData('tripName', value),
                          ),

                          SizedBox(height: 16),

                          // Business Justification Section
                          BusinessJustificationSectionWidget(
                            isExpanded:
                                sectionExpansion['businessJustification']!,
                            isCompleted:
                                sectionCompletion['businessJustification']!,
                            onToggle: () =>
                                _toggleSection('businessJustification'),
                            businessJustification:
                                formData['businessJustification'] as String,
                            expectedOutcomes:
                                formData['expectedOutcomes'] as String,
                            onBusinessJustificationChanged: (value) =>
                                _updateFormData('businessJustification', value),
                            onExpectedOutcomesChanged: (value) =>
                                _updateFormData('expectedOutcomes', value),
                          ),

                          SizedBox(height: 16),

                          // Attendees Section
                          AttendeesSectionWidget(
                            isExpanded: sectionExpansion['attendees']!,
                            isCompleted: sectionCompletion['attendees']!,
                            onToggle: () => _toggleSection('attendees'),
                            attendees: formData['attendees']
                                as List<Map<String, dynamic>>,
                            onAttendeesChanged: (value) =>
                                _updateFormData('attendees', value),
                          ),

                          SizedBox(height: 16),

                          // Dates & Locations Section
                          DatesLocationsSectionWidget(
                            isExpanded: sectionExpansion['datesLocations']!,
                            isCompleted: sectionCompletion['datesLocations']!,
                            onToggle: () => _toggleSection('datesLocations'),
                            departureDate:
                                formData['departureDate'] as DateTime?,
                            departureTime:
                                formData['departureTime'] as TimeOfDay?,
                            returnDate: formData['returnDate'] as DateTime?,
                            returnTime: formData['returnTime'] as TimeOfDay?,
                            originCity: formData['originCity'] as String,
                            destinationCity:
                                formData['destinationCity'] as String,
                            onDepartureDateChanged: (value) =>
                                _updateFormData('departureDate', value),
                            onDepartureTimeChanged: (value) =>
                                _updateFormData('departureTime', value),
                            onReturnDateChanged: (value) =>
                                _updateFormData('returnDate', value),
                            onReturnTimeChanged: (value) =>
                                _updateFormData('returnTime', value),
                            onOriginCityChanged: (value) =>
                                _updateFormData('originCity', value),
                            onDestinationCityChanged: (value) =>
                                _updateFormData('destinationCity', value),
                          ),

                          SizedBox(height: 16),

                          // Cost Estimates Section
                          CostEstimatesSectionWidget(
                            isExpanded: sectionExpansion['costEstimates']!,
                            isCompleted: sectionCompletion['costEstimates']!,
                            onToggle: () => _toggleSection('costEstimates'),
                            transportationCost:
                                formData['transportationCost'] as double,
                            accommodationCost:
                                formData['accommodationCost'] as double,
                            mealsCost: formData['mealsCost'] as double,
                            otherCost: formData['otherCost'] as double,
                            totalCost: formData['totalCost'] as double,
                            onTransportationCostChanged: (value) =>
                                _updateFormData('transportationCost', value),
                            onAccommodationCostChanged: (value) =>
                                _updateFormData('accommodationCost', value),
                            onMealsCostChanged: (value) =>
                                _updateFormData('mealsCost', value),
                            onOtherCostChanged: (value) =>
                                _updateFormData('otherCost', value),
                          ),

                          SizedBox(height: 16),

                          // Approval Section
                          ApprovalSectionWidget(
                            isExpanded: sectionExpansion['approval']!,
                            isCompleted: sectionCompletion['approval']!,
                            onToggle: () => _toggleSection('approval'),
                            selectedManager:
                                formData['selectedManager'] as String,
                            comments: formData['comments'] as String,
                            managers: _managers,
                            onManagerChanged: (value) =>
                                _updateFormData('selectedManager', value),
                            onCommentsChanged: (value) =>
                                _updateFormData('comments', value),
                          ),

                          SizedBox(height: 100), // Space for bottom button
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

      // Submit button
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.cardColor,
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.colorScheme.shadow,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: (_isSaving ||
                      !sectionCompletion.values.every((completed) => completed))
                  ? null
                  : _handleSubmit,
              style: AppTheme.lightTheme.elevatedButtonTheme.style,
              child: _isSaving
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Submit Request',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
