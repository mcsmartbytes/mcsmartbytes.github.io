class TravelRequest {
  final String id;
  final String userId;
  final String tripName;
  final String businessJustification;
  final String expectedOutcomes;
  final DateTime departureDate;
  final String? departureTime;
  final DateTime returnDate;
  final String? returnTime;
  final String originCity;
  final String destinationCity;
  final double transportationCost;
  final double accommodationCost;
  final double mealsCost;
  final double otherCost;
  final double totalCost;
  final String status;
  final String priority;
  final String? managerId;
  final String? comments;
  final DateTime? submittedAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TravelRequestAttendee>? attendees;

  TravelRequest({
    required this.id,
    required this.userId,
    required this.tripName,
    required this.businessJustification,
    required this.expectedOutcomes,
    required this.departureDate,
    this.departureTime,
    required this.returnDate,
    this.returnTime,
    required this.originCity,
    required this.destinationCity,
    required this.transportationCost,
    required this.accommodationCost,
    required this.mealsCost,
    required this.otherCost,
    required this.totalCost,
    required this.status,
    required this.priority,
    this.managerId,
    this.comments,
    this.submittedAt,
    this.approvedAt,
    this.rejectedAt,
    required this.createdAt,
    required this.updatedAt,
    this.attendees,
  });

  factory TravelRequest.fromJson(Map<String, dynamic> json) {
    return TravelRequest(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      tripName: json['trip_name'] as String,
      businessJustification: json['business_justification'] as String,
      expectedOutcomes: json['expected_outcomes'] as String,
      departureDate: DateTime.parse(json['departure_date'] as String),
      departureTime: json['departure_time'] as String?,
      returnDate: DateTime.parse(json['return_date'] as String),
      returnTime: json['return_time'] as String?,
      originCity: json['origin_city'] as String,
      destinationCity: json['destination_city'] as String,
      transportationCost: (json['transportation_cost'] as num).toDouble(),
      accommodationCost: (json['accommodation_cost'] as num).toDouble(),
      mealsCost: (json['meals_cost'] as num).toDouble(),
      otherCost: (json['other_cost'] as num).toDouble(),
      totalCost: (json['total_cost'] as num).toDouble(),
      status: json['status'] as String,
      priority: json['priority'] as String,
      managerId: json['manager_id'] as String?,
      comments: json['comments'] as String?,
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : null,
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'] as String)
          : null,
      rejectedAt: json['rejected_at'] != null
          ? DateTime.parse(json['rejected_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      attendees: json['travel_request_attendees'] != null
          ? (json['travel_request_attendees'] as List)
              .map((attendee) => TravelRequestAttendee.fromJson(attendee))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'trip_name': tripName,
      'business_justification': businessJustification,
      'expected_outcomes': expectedOutcomes,
      'departure_date': departureDate.toIso8601String().split('T')[0],
      'departure_time': departureTime,
      'return_date': returnDate.toIso8601String().split('T')[0],
      'return_time': returnTime,
      'origin_city': originCity,
      'destination_city': destinationCity,
      'transportation_cost': transportationCost,
      'accommodation_cost': accommodationCost,
      'meals_cost': mealsCost,
      'other_cost': otherCost,
      'status': status,
      'priority': priority,
      'manager_id': managerId,
      'comments': comments,
      'submitted_at': submittedAt?.toIso8601String(),
      'approved_at': approvedAt?.toIso8601String(),
      'rejected_at': rejectedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  TravelRequest copyWith({
    String? id,
    String? userId,
    String? tripName,
    String? businessJustification,
    String? expectedOutcomes,
    DateTime? departureDate,
    String? departureTime,
    DateTime? returnDate,
    String? returnTime,
    String? originCity,
    String? destinationCity,
    double? transportationCost,
    double? accommodationCost,
    double? mealsCost,
    double? otherCost,
    double? totalCost,
    String? status,
    String? priority,
    String? managerId,
    String? comments,
    DateTime? submittedAt,
    DateTime? approvedAt,
    DateTime? rejectedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TravelRequestAttendee>? attendees,
  }) {
    return TravelRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tripName: tripName ?? this.tripName,
      businessJustification:
          businessJustification ?? this.businessJustification,
      expectedOutcomes: expectedOutcomes ?? this.expectedOutcomes,
      departureDate: departureDate ?? this.departureDate,
      departureTime: departureTime ?? this.departureTime,
      returnDate: returnDate ?? this.returnDate,
      returnTime: returnTime ?? this.returnTime,
      originCity: originCity ?? this.originCity,
      destinationCity: destinationCity ?? this.destinationCity,
      transportationCost: transportationCost ?? this.transportationCost,
      accommodationCost: accommodationCost ?? this.accommodationCost,
      mealsCost: mealsCost ?? this.mealsCost,
      otherCost: otherCost ?? this.otherCost,
      totalCost: totalCost ?? this.totalCost,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      managerId: managerId ?? this.managerId,
      comments: comments ?? this.comments,
      submittedAt: submittedAt ?? this.submittedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      attendees: attendees ?? this.attendees,
    );
  }

  String get formattedTotalCost => '\$${totalCost.toStringAsFixed(2)}';
  String get formattedDepartureDate =>
      '${departureDate.day}/${departureDate.month}/${departureDate.year}';
  String get formattedReturnDate =>
      '${returnDate.day}/${returnDate.month}/${returnDate.year}';
  int get durationInDays => returnDate.difference(departureDate).inDays + 1;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TravelRequest && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TravelRequest{id: $id, tripName: $tripName, status: $status}';
  }
}

class TravelRequestAttendee {
  final String id;
  final String requestId;
  final String attendeeName;
  final String attendeeEmail;
  final String? attendeeRole;
  final DateTime createdAt;

  TravelRequestAttendee({
    required this.id,
    required this.requestId,
    required this.attendeeName,
    required this.attendeeEmail,
    this.attendeeRole,
    required this.createdAt,
  });

  factory TravelRequestAttendee.fromJson(Map<String, dynamic> json) {
    return TravelRequestAttendee(
      id: json['id'] as String,
      requestId: json['request_id'] as String,
      attendeeName: json['attendee_name'] as String,
      attendeeEmail: json['attendee_email'] as String,
      attendeeRole: json['attendee_role'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request_id': requestId,
      'attendee_name': attendeeName,
      'attendee_email': attendeeEmail,
      'attendee_role': attendeeRole,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TravelRequestAttendee && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
