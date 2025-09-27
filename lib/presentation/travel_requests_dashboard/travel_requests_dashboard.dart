import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../models/travel_request.dart';
import '../../services/auth_service.dart';
import '../../services/travel_request_service.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_chip_widget.dart';
import './widgets/travel_request_card_widget.dart';

class TravelRequestsDashboard extends StatefulWidget {
  const TravelRequestsDashboard({super.key});

  @override
  State<TravelRequestsDashboard> createState() =>
      _TravelRequestsDashboardState();
}

class _TravelRequestsDashboardState extends State<TravelRequestsDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  final TravelRequestService _travelRequestService =
      TravelRequestService.instance;
  final AuthService _authService = AuthService.instance;

  List<String> activeFilters = ['Pending', 'Draft'];
  bool isLoading = true;
  String lastSyncTime = '';
  List<TravelRequest> travelRequests = [];
  List<TravelRequest> filteredRequests = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(_onSearchChanged);
    _loadTravelRequests();
    _updateLastSyncTime();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _searchController.text.toLowerCase();
      _applyFilters();
    });
  }

  Future<void> _loadTravelRequests() async {
    try {
      setState(() => isLoading = true);
      final requests = await _travelRequestService.getUserTravelRequests();
      setState(() {
        travelRequests = requests;
        isLoading = false;
        _applyFilters();
      });
      _updateLastSyncTime();
    } catch (error) {
      setState(() => isLoading = false);
      _showErrorSnackBar('Failed to load travel requests: $error');
    }
  }

  void _applyFilters() {
    setState(() {
      filteredRequests = travelRequests.where((request) {
        // Filter by status
        bool matchesStatus = activeFilters.isEmpty ||
            activeFilters.contains('All') ||
            activeFilters.any((filter) =>
                request.status.toLowerCase() == filter.toLowerCase());

        // Filter by search query
        bool matchesSearch = searchQuery.isEmpty ||
            request.tripName.toLowerCase().contains(searchQuery) ||
            request.destinationCity.toLowerCase().contains(searchQuery) ||
            request.originCity.toLowerCase().contains(searchQuery);

        return matchesStatus && matchesSearch;
      }).toList();
    });
  }

  void _updateLastSyncTime() {
    setState(() {
      lastSyncTime =
          'Last synced: ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _handleRefresh() async {
    await _loadTravelRequests();
  }

  void _removeFilter(String filter) {
    setState(() {
      activeFilters.remove(filter);
      _applyFilters();
    });
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Options',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'All',
                'Draft',
                'Pending',
                'Approved',
                'Rejected',
                'Cancelled'
              ]
                  .map((status) => FilterChip(
                        label: Text(status),
                        selected: activeFilters.contains(status),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              if (!activeFilters.contains(status)) {
                                activeFilters.add(status);
                              }
                            } else {
                              activeFilters.remove(status);
                            }
                          });
                          _applyFilters();
                          Navigator.pop(context);
                        },
                      ))
                  .toList(),
            ),
            SizedBox(height: 24),
          ],
        ),
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }

  Future<void> _handleDelete(TravelRequest request) async {
    try {
      await _travelRequestService.deleteTravelRequest(request.id);
      _showSuccessSnackBar('Request deleted successfully');
      _loadTravelRequests();
    } catch (error) {
      _showErrorSnackBar('Failed to delete request: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with search and filter
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowLight,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.borderLight,
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search travel requests...',
                              prefixIcon: CustomIconWidget(
                                iconName: 'search',
                                color: AppTheme.textSecondaryLight,
                                size: 20,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      GestureDetector(
                        onTap: _showFilterOptions,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CustomIconWidget(
                            iconName: 'filter_list',
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  // Tab Bar
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'assignment',
                              color: _tabController.index == 0
                                  ? AppTheme.lightTheme.primaryColor
                                  : AppTheme.textSecondaryLight,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text('Requests'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'calendar_today',
                              color: _tabController.index == 1
                                  ? AppTheme.lightTheme.primaryColor
                                  : AppTheme.textSecondaryLight,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text('Calendar'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'person',
                              color: _tabController.index == 2
                                  ? AppTheme.lightTheme.primaryColor
                                  : AppTheme.textSecondaryLight,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text('Profile'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Filter chips
            if (activeFilters.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: activeFilters
                        .map((filter) => FilterChipWidget(
                              label: filter,
                              count: travelRequests
                                  .where((req) =>
                                      req.status.toLowerCase() ==
                                      filter.toLowerCase())
                                  .length,
                              onRemove: () => _removeFilter(filter),
                            ))
                        .toList(),
                  ),
                ),
              ),

            // Last sync time
            if (lastSyncTime.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  lastSyncTime,
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Requests Tab
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : filteredRequests.isEmpty
                          ? EmptyStateWidget(
                              onCreateRequest: () {
                                Navigator.pushNamed(
                                    context, AppRoutes.newTravelRequestForm);
                              },
                            )
                          : RefreshIndicator(
                              key: _refreshIndicatorKey,
                              onRefresh: _handleRefresh,
                              child: ListView.builder(
                                padding: EdgeInsets.all(16),
                                itemCount: filteredRequests.length,
                                itemBuilder: (context, index) {
                                  final request = filteredRequests[index];
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 12),
                                    child: TravelRequestCardWidget(
                                      request: request,
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.travelRequestDetailView,
                                          arguments: request,
                                        );
                                      },
                                      onEdit: request.status == 'draft'
                                          ? () {
                                              Navigator.pushNamed(
                                                context,
                                                AppRoutes.newTravelRequestForm,
                                                arguments: request,
                                              );
                                            }
                                          : null,
                                      onDuplicate: () {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.newTravelRequestForm,
                                          arguments: request.copyWith(
                                            id: '',
                                            status: 'draft',
                                          ),
                                        );
                                      },
                                      onDelete: () {
                                        _showDeleteConfirmation(request);
                                      },
                                      onShare: () {
                                        _shareRequest(request);
                                      },
                                      onArchive: () {
                                        _archiveRequest(request);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),

                  // Calendar Tab
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'calendar_today',
                          color: AppTheme.textSecondaryLight,
                          size: 64,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Calendar View',
                          style: AppTheme.lightTheme.textTheme.titleLarge,
                        ),
                        SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                                context, AppRoutes.travelCalendar);
                          },
                          child: Text('Open Full Calendar'),
                        ),
                      ],
                    ),
                  ),

                  // Profile Tab
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'person',
                          color: AppTheme.textSecondaryLight,
                          size: 64,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Profile Settings',
                          style: AppTheme.lightTheme.textTheme.titleLarge,
                        ),
                        SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                                context, AppRoutes.profileSettings);
                          },
                          child: Text('Open Profile'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.newTravelRequestForm);
        },
        child: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(TravelRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Request'),
        content: Text('Are you sure you want to delete this travel request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleDelete(request);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _shareRequest(TravelRequest request) {
    _showSuccessSnackBar('Sharing request: ${request.tripName}');
  }

  void _archiveRequest(TravelRequest request) {
    _showSuccessSnackBar('Request archived: ${request.tripName}');
  }
}
