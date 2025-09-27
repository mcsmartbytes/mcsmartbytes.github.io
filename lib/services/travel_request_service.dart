import 'package:flutter/material.dart';
import '../models/travel_request.dart';
import '../models/user_profile.dart';
import './supabase_service.dart';

class TravelRequestService {
  static TravelRequestService? _instance;
  static TravelRequestService get instance =>
      _instance ??= TravelRequestService._();
  TravelRequestService._();

  final _client = SupabaseService.instance.client;

  // Get all travel requests for the current user
  Future<List<TravelRequest>> getUserTravelRequests() async {
    try {
      final response = await _client
          .from('travel_requests')
          .select('''
            *,
            travel_request_attendees (*)
          ''')
          .eq('user_id', _client.auth.currentUser!.id)
          .order('created_at', ascending: false);

      return response.map((json) => TravelRequest.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to load travel requests: $error');
    }
  }

  // Get travel requests for manager approval
  Future<List<TravelRequest>> getManagerTravelRequests() async {
    try {
      final response = await _client
          .from('travel_requests')
          .select('''
            *,
            travel_request_attendees (*),
            user_profiles!travel_requests_user_id_fkey (full_name, email)
          ''')
          .eq('manager_id', _client.auth.currentUser!.id)
          .order('created_at', ascending: false);

      return response.map((json) => TravelRequest.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to load manager travel requests: $error');
    }
  }

  // Get travel requests filtered by status
  Future<List<TravelRequest>> getTravelRequestsByStatus(
      List<String> statuses) async {
    try {
      final response = await _client
          .from('travel_requests')
          .select('''
            *,
            travel_request_attendees (*)
          ''')
          .eq('user_id', _client.auth.currentUser!.id)
          .inFilter('status', statuses)
          .order('created_at', ascending: false);

      return response.map((json) => TravelRequest.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to load filtered travel requests: $error');
    }
  }

  // Get single travel request by ID
  Future<TravelRequest> getTravelRequestById(String requestId) async {
    try {
      final response = await _client.from('travel_requests').select('''
            *,
            travel_request_attendees (*),
            user_profiles!travel_requests_user_id_fkey (full_name, email),
            travel_request_timeline (*, user_profiles!travel_request_timeline_action_by_fkey (full_name))
          ''').eq('id', requestId).single();

      return TravelRequest.fromJson(response);
    } catch (error) {
      throw Exception('Failed to load travel request: $error');
    }
  }

  // Create a new travel request
  Future<TravelRequest> createTravelRequest(
      Map<String, dynamic> requestData) async {
    try {
      // Prepare travel request data
      final travelRequestData = {
        'user_id': _client.auth.currentUser!.id,
        'trip_name': requestData['tripName'],
        'business_justification': requestData['businessJustification'],
        'expected_outcomes': requestData['expectedOutcomes'],
        'departure_date': (requestData['departureDate'] as DateTime)
            .toIso8601String()
            .split('T')[0],
        'departure_time': requestData['departureTime'] != null
            ? '${(requestData['departureTime'] as TimeOfDay).hour.toString().padLeft(2, '0')}:${(requestData['departureTime'] as TimeOfDay).minute.toString().padLeft(2, '0')}'
            : null,
        'return_date': (requestData['returnDate'] as DateTime)
            .toIso8601String()
            .split('T')[0],
        'return_time': requestData['returnTime'] != null
            ? '${(requestData['returnTime'] as TimeOfDay).hour.toString().padLeft(2, '0')}:${(requestData['returnTime'] as TimeOfDay).minute.toString().padLeft(2, '0')}'
            : null,
        'origin_city': requestData['originCity'],
        'destination_city': requestData['destinationCity'],
        'transportation_cost': requestData['transportationCost'] ?? 0.0,
        'accommodation_cost': requestData['accommodationCost'] ?? 0.0,
        'meals_cost': requestData['mealsCost'] ?? 0.0,
        'other_cost': requestData['otherCost'] ?? 0.0,
        'status': requestData['status'] ?? 'draft',
        'priority': 'medium',
        'manager_id': requestData['selectedManager'],
        'comments': requestData['comments'],
      };

      // Set submitted_at if status is not draft
      if (requestData['status'] != 'draft') {
        travelRequestData['submitted_at'] = DateTime.now().toIso8601String();
      }

      // Insert travel request
      final response = await _client
          .from('travel_requests')
          .insert(travelRequestData)
          .select()
          .single();

      final requestId = response['id'] as String;

      // Insert attendees if provided
      final attendees =
          requestData['attendees'] as List<Map<String, dynamic>>? ?? [];
      if (attendees.isNotEmpty) {
        final attendeesData = attendees
            .map((attendee) => {
                  'request_id': requestId,
                  'attendee_name': attendee['name'],
                  'attendee_email': attendee['email'],
                  'attendee_role': attendee['role'],
                })
            .toList();

        await _client.from('travel_request_attendees').insert(attendeesData);
      }

      return await getTravelRequestById(requestId);
    } catch (error) {
      throw Exception('Failed to create travel request: $error');
    }
  }

  // Update travel request
  Future<TravelRequest> updateTravelRequest(
      String requestId, Map<String, dynamic> requestData) async {
    try {
      final updateData = Map<String, dynamic>.from(requestData);

      // Handle DateTime and TimeOfDay conversions
      if (updateData['departureDate'] is DateTime) {
        updateData['departure_date'] = (updateData['departureDate'] as DateTime)
            .toIso8601String()
            .split('T')[0];
        updateData.remove('departureDate');
      }

      if (updateData['returnDate'] is DateTime) {
        updateData['return_date'] = (updateData['returnDate'] as DateTime)
            .toIso8601String()
            .split('T')[0];
        updateData.remove('returnDate');
      }

      if (updateData['departureTime'] is TimeOfDay) {
        final time = updateData['departureTime'] as TimeOfDay;
        updateData['departure_time'] =
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
        updateData.remove('departureTime');
      }

      if (updateData['returnTime'] is TimeOfDay) {
        final time = updateData['returnTime'] as TimeOfDay;
        updateData['return_time'] =
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
        updateData.remove('returnTime');
      }

      // Map field names to database columns
      final columnMapping = {
        'tripName': 'trip_name',
        'businessJustification': 'business_justification',
        'expectedOutcomes': 'expected_outcomes',
        'originCity': 'origin_city',
        'destinationCity': 'destination_city',
        'transportationCost': 'transportation_cost',
        'accommodationCost': 'accommodation_cost',
        'mealsCost': 'meals_cost',
        'otherCost': 'other_cost',
        'selectedManager': 'manager_id',
      };

      // Apply column mapping
      for (final entry in columnMapping.entries) {
        if (updateData.containsKey(entry.key)) {
          updateData[entry.value] = updateData[entry.key];
          updateData.remove(entry.key);
        }
      }

      // Remove non-database fields
      updateData.removeWhere((key, value) => key == 'attendees');

      await _client
          .from('travel_requests')
          .update(updateData)
          .eq('id', requestId);

      return await getTravelRequestById(requestId);
    } catch (error) {
      throw Exception('Failed to update travel request: $error');
    }
  }

  // Update travel request status
  Future<TravelRequest> updateTravelRequestStatus(
      String requestId, String status,
      {String? comments}) async {
    try {
      final updateData = {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Set specific timestamps based on status
      switch (status) {
        case 'pending':
          updateData['submitted_at'] = DateTime.now().toIso8601String();
          break;
        case 'approved':
          updateData['approved_at'] = DateTime.now().toIso8601String();
          break;
        case 'rejected':
          updateData['rejected_at'] = DateTime.now().toIso8601String();
          break;
      }

      if (comments != null && comments.isNotEmpty) {
        updateData['comments'] = comments;
      }

      await _client
          .from('travel_requests')
          .update(updateData)
          .eq('id', requestId);

      return await getTravelRequestById(requestId);
    } catch (error) {
      throw Exception('Failed to update travel request status: $error');
    }
  }

  // Delete travel request
  Future<void> deleteTravelRequest(String requestId) async {
    try {
      await _client.from('travel_requests').delete().eq('id', requestId);
    } catch (error) {
      throw Exception('Failed to delete travel request: $error');
    }
  }

  // Get travel requests for calendar view
  Future<List<TravelRequest>> getTravelRequestsForCalendar(
      DateTime startDate, DateTime endDate) async {
    try {
      final response = await _client
          .from('travel_requests')
          .select('*')
          .eq('user_id', _client.auth.currentUser!.id)
          .gte('departure_date', startDate.toIso8601String().split('T')[0])
          .lte('return_date', endDate.toIso8601String().split('T')[0])
          .inFilter('status', ['approved', 'pending']).order('departure_date');

      return response.map((json) => TravelRequest.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to load calendar travel requests: $error');
    }
  }

  // Get user profile
  Future<UserProfile> getCurrentUserProfile() async {
    try {
      final response = await _client
          .from('user_profiles')
          .select('*')
          .eq('id', _client.auth.currentUser!.id)
          .single();

      return UserProfile.fromJson(response);
    } catch (error) {
      throw Exception('Failed to load user profile: $error');
    }
  }

  // Get managers for approval selection
  Future<List<UserProfile>> getManagers() async {
    try {
      final response = await _client
          .from('user_profiles')
          .select('*')
          .inFilter('role', ['manager', 'admin']).order('full_name');

      return response.map((json) => UserProfile.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to load managers: $error');
    }
  }

  // Get travel statistics for dashboard
  Future<Map<String, dynamic>> getTravelStatistics() async {
    try {
      final userId = _client.auth.currentUser!.id;

      // Get counts for different statuses
      final draftCount = await _client
          .from('travel_requests')
          .select('id')
          .eq('user_id', userId)
          .eq('status', 'draft')
          .count();

      final pendingCount = await _client
          .from('travel_requests')
          .select('id')
          .eq('user_id', userId)
          .eq('status', 'pending')
          .count();

      final approvedCount = await _client
          .from('travel_requests')
          .select('id')
          .eq('user_id', userId)
          .eq('status', 'approved')
          .count();

      final rejectedCount = await _client
          .from('travel_requests')
          .select('id')
          .eq('user_id', userId)
          .eq('status', 'rejected')
          .count();

      // Get total cost of approved requests
      final approvedRequests = await _client
          .from('travel_requests')
          .select('total_cost')
          .eq('user_id', userId)
          .eq('status', 'approved');

      final totalApprovedCost = approvedRequests.fold<double>(
        0.0,
        (sum, request) => sum + (request['total_cost'] as num).toDouble(),
      );

      return {
        'draft_count': draftCount.count ?? 0,
        'pending_count': pendingCount.count ?? 0,
        'approved_count': approvedCount.count ?? 0,
        'rejected_count': rejectedCount.count ?? 0,
        'total_approved_cost': totalApprovedCost,
      };
    } catch (error) {
      throw Exception('Failed to load travel statistics: $error');
    }
  }
}