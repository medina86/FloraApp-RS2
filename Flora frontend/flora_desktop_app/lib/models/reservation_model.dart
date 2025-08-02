class Reservation {
  final int id;  
  final String eventType;  
  final DateTime eventDate;  
  final String venueType; 
  final int numberOfGuests; 
  final int numberOfTables;  
  final String themeOrColors;  
  final String location;  
  final String? specialRequests;  
  final double budget; 
  final int userId; 

  Reservation({
    required this.id,
    required this.eventType,
    required this.eventDate,
    required this.venueType,
    required this.numberOfGuests,
    required this.numberOfTables,
    required this.themeOrColors,
    required this.location,
    this.specialRequests,
    required this.budget,
    required this.userId,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] as int,
      eventType: json['eventType'] as String,
      eventDate: DateTime.parse(json['eventDate'] as String),
      venueType: json['venueType'] as String,
      numberOfGuests: json['numberOfGuests'] as int,
      numberOfTables: json['numberOfTables'] as int,
      themeOrColors: json['themeOrColors'] as String,
      location: json['location'] as String,
      specialRequests: json['specialRequests'] as String?,
      budget: (json['budget'] as num).toDouble(),
      userId: json['userId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'EventType': eventType,
      'EventDate': eventDate.toIso8601String(),
      'VenueType': venueType,
      'NumberOfGuests': numberOfGuests,
      'NumberOfTables': numberOfTables,
      'ThemeOrColors': themeOrColors,
      'Location': location,
      'SpecialRequests': specialRequests,
      'Budget': budget,
      'UserId': userId,
    };
  }
}
class DecorationSuggestion {
  final int id;  
  final int decorationRequestId; 
  final String imageUrl;  
  final String? description; 

  DecorationSuggestion({
    required this.id,
    required this.decorationRequestId,
    required this.imageUrl,
    this.description,
  });

  factory DecorationSuggestion.fromJson(Map<String, dynamic> json) {
    return DecorationSuggestion(
      id: json['id'] as int,
      decorationRequestId: json['decorationRequestId'] as int,
      imageUrl: json['imageUrl'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'DecorationRequestId': decorationRequestId,
      'ImageUrl': imageUrl,
      'Description': description,
    };
  }
}
