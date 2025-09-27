import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../models/expense.dart';
import '../../services/auth_service.dart';
import '../../services/expense_service.dart';

class NewExpenseForm extends StatefulWidget {
  final Expense? expense; // For editing existing expenses
  
  const NewExpenseForm({super.key, this.expense});

  @override
  State<NewExpenseForm> createState() => _NewExpenseFormState();
}

class _NewExpenseFormState extends State<NewExpenseForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final ExpenseService _expenseService = ExpenseService.instance;
  final AuthService _authService = AuthService.instance;

  // Form controllers
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _isSaving = false;
  String _selectedCategory = 'Office';
  DateTime _selectedDate = DateTime.now();
  String? _receiptPath;

  @override
  void initState() {
    super.initState();
    
    // If editing existing expense, populate form
    if (widget.expense != null) {
      _descriptionController.text = widget.expense!.description;
      _amountController.text = widget.expense!.amount.toString();
      _notesController.text = widget.expense!.notes ?? '';
      _selectedCategory = widget.expense!.category;
      _selectedDate = widget.expense!.date;
      _receiptPath = widget.expense!.receipt;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickReceipt() async {
    // TODO: Implement image picker for receipts
    setState(() {
      _receiptPath = 'sample_receipt_path.jpg';
    });
    _showSuccessSnackBar('Receipt attached');
  }

  Future<void> _saveDraft() async {
    if (_isSaving) return;

    try {
      setState(() => _isSaving = true);

      final expenseData = {
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'amount': double.tryParse(_amountController.text) ?? 0.0,
        'date': _selectedDate.toIso8601String(),
        'receipt': _receiptPath,
        'status': 'draft',
        'notes': _notesController.text.trim(),
      };

      if (widget.expense != null) {
        await _expenseService.updateExpense(widget.expense!.id, expenseData);
        _showSuccessSnackBar('Draft updated successfully');
      } else {
        await _expenseService.createExpense(expenseData);
        _showSuccessSnackBar('Draft saved successfully');
      }
      
      Navigator.pushReplacementNamed(context, AppRoutes.expensesDashboard);
    } catch (error) {
      _showErrorSnackBar('Failed to save draft: $error');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _submitExpense() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    try {
      setState(() => _isSaving = true);

      final expenseData = {
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'amount': double.tryParse(_amountController.text) ?? 0.0,
        'date': _selectedDate.toIso8601String(),
        'receipt': _receiptPath,
        'status': 'pending',
        'notes': _notesController.text.trim(),
      };

      if (widget.expense != null) {
        await _expenseService.updateExpense(widget.expense!.id, expenseData);
        _showSuccessSnackBar('Expense updated successfully');
      } else {
        await _expenseService.createExpense(expenseData);
        _showSuccessSnackBar('Expense submitted successfully');
      }
      
      Navigator.pushReplacementNamed(context, AppRoutes.expensesDashboard);
    } catch (error) {
      _showErrorSnackBar('Failed to submit expense: $error');
    } finally {
      setState(() => _isSaving = false);
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
    final isEditing = widget.expense != null;
    
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Expense' : 'Add Expense',
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description field
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description *',
                        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          hintText: 'What was this expense for?',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: CustomIconWidget(
                            iconName: 'description',
                            color: AppTheme.textSecondaryLight,
                            size: 20,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                        maxLength: 100,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Amount and Category row
              Row(
                children: [
                  // Amount field
                  Expanded(
                    flex: 2,
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Amount *',
                              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: _amountController,
                              decoration: InputDecoration(
                                hintText: '0.00',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: Icon(Icons.attach_money),
                              ),
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                              ],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Enter amount';
                                }
                                final amount = double.tryParse(value);
                                if (amount == null || amount <= 0) {
                                  return 'Enter valid amount';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 12),

                  // Category dropdown
                  Expanded(
                    flex: 2,
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Category *',
                              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: CustomIconWidget(
                                  iconName: 'category',
                                  color: AppTheme.textSecondaryLight,
                                  size: 20,
                                ),
                              ),
                              items: _expenseService.getExpenseCategories()
                                  .map((category) => DropdownMenuItem(
                                        value: category,
                                        child: Text(category),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedCategory = value;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Date field
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date *',
                        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      InkWell(
                        onTap: _selectDate,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.borderLight),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'calendar_today',
                                color: AppTheme.textSecondaryLight,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Text(
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                style: AppTheme.lightTheme.textTheme.bodyLarge,
                              ),
                              Spacer(),
                              CustomIconWidget(
                                iconName: 'arrow_drop_down',
                                color: AppTheme.textSecondaryLight,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Receipt field
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Receipt (Optional)',
                        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      InkWell(
                        onTap: _pickReceipt,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.borderLight),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'camera_alt',
                                color: AppTheme.textSecondaryLight,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Text(
                                _receiptPath != null ? 'Receipt attached' : 'Take photo or select image',
                                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                                  color: _receiptPath != null 
                                      ? AppTheme.lightTheme.primaryColor 
                                      : AppTheme.textSecondaryLight,
                                ),
                              ),
                              Spacer(),
                              if (_receiptPath != null)
                                CustomIconWidget(
                                  iconName: 'check_circle',
                                  color: AppTheme.lightTheme.primaryColor,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Notes field
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notes (Optional)',
                        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          hintText: 'Additional details or context...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: CustomIconWidget(
                            iconName: 'note',
                            color: AppTheme.textSecondaryLight,
                            size: 20,
                          ),
                        ),
                        maxLines: 3,
                        maxLength: 200,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 100), // Space for bottom button
            ],
          ),
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
              onPressed: _isSaving ? null : _submitExpense,
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
                      isEditing ? 'Update Expense' : 'Submit Expense',
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
}