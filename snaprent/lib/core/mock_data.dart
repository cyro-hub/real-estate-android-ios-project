import 'package:flutter/material.dart';

final Map<String, dynamic> sampleProperty = {
  "_id": "propertyId123",
  "userId": "user456",
  "title": "Modern Studio Apartment in Molyko",
  "description":
      "A modern self-contained studio apartment, fully tiled, located just 2 mins from Checkpoint junction.",
  "images": [
    "https://images.pexels.com/photos/8146320/pexels-photo-8146320.jpeg",
    "https://images.pexels.com/photos/8146321/pexels-photo-8146321.jpeg",
  ],
  "videos": ["https://cdn.snaprent.com/property123/tour.mp4"],
  "location": {
    "type": "Point",
    "coordinates": [9.248, 4.158], // [longitude, latitude]
    "town": "Buea",
    "quarter": "Molyko",
    "street": "Checkpoint Street",
    "landmark": "Opposite Orange Shop",
  },
  "type": "studio",
  "floorLevel": 2,
  "size": "25m²",
  "rentAmount": 35000,
  "currency": "FCFA",
  "paymentFrequency": "monthly",
  "securityDeposit": 20000,
  "amenities": {
    "toilet": "private",
    "bathroom": "private",
    "kitchen": "private",
    "furnished": false,
    "waterAvailable": true,
    "electricity": true,
    "meterType": "prepaid",
    "internet": true,
    "parking": false,
    "balcony": true,
    "ceilingFan": false,
    "tiledFloor": true,
  },
  "houseRules": {
    "smokingAllowed": false,
    "petsAllowed": false,
    "quietHours": "10 PM - 6 AM",
    "visitorsAllowed": true,
  },
  "contact": {
    "phone": "+237690123456",
    "whatsapp": "+237690123456",
    "agentName": "Mr. Bate",
  },
  "viewCount": 100,
  "status": true,
  "createdAt": "2025-08-01T09:00:00Z",
  "expiresAt": "2025-08-31T09:00:00Z",
};

final List<String> defaultTowns = [
  "Buea",
  "Limbe",
  "Molyko",
  "Bonapriso",
  "Bonendale",
  "Mutengene",
  "Bodija",
  "Downtown",
  "Bota",
  "Tiko",
  "Kumba",
  "Muyuka",
  "Bali",
  "Wum",
  "Bamenda",
  "Mbengwi",
  "Nguti",
  "Idenau",
  "Muyuka",
  "Ebolowa",
  "Kumba Road",
  "Muea",
  "Sandpit",
  "Bokwango",
  "New Town",
  "Victoria",
  "Dibanda",
  "Lighthouse",
  "Akwa",
  "Bonakanda",
];

// Add property type list with icons
final List<Map<String, dynamic>> propertyTypes = [
  {"name": "apartment", "icon": Icons.apartment},
  {"name": "house", "icon": Icons.house},
  {"name": "studio", "icon": Icons.meeting_room},
  {"name": "office", "icon": Icons.business},
  {"name": "shop", "icon": Icons.store},
  {"name": "land", "icon": Icons.landscape},
  {"name": "duplex", "icon": Icons.villa},
  {"name": "villa", "icon": Icons.home_work},
];

final List<Map<String, String>> createdAtFilterList = [
  {"name": "All", "from": "", "to": ""},
  {
    "name": "Today",
    "from": DateTime.now()
        .subtract(const Duration(hours: 24))
        .toIso8601String(),
    "to": DateTime.now().toIso8601String(),
  },
  {
    "name": "Yesterday",
    "from": DateTime.now()
        .subtract(
          Duration(
            days: 1,
            hours: DateTime.now().hour,
            minutes: DateTime.now().minute,
            seconds: DateTime.now().second,
          ),
        )
        .toIso8601String(),
    "to": DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
  },
  {
    "name": "Last 7 Days",
    "from": DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
    "to": DateTime.now().toIso8601String(),
  },
  {
    "name": "This Month",
    "from": DateTime(
      DateTime.now().year,
      DateTime.now().month,
      1,
    ).toIso8601String(),
    "to": DateTime.now().toIso8601String(),
  },
  {
    "name": "Last Month",
    "from": DateTime(
      DateTime.now().year,
      DateTime.now().month - 1,
      1,
    ).toIso8601String(),
    "to": DateTime(
      DateTime.now().year,
      DateTime.now().month,
      0,
      23,
      59,
      59,
    ).toIso8601String(),
  },
  {
    "name": "Last 3 Months",
    "from": DateTime(
      DateTime.now().year,
      DateTime.now().month - 3,
      1,
    ).toIso8601String(),
    "to": DateTime.now().toIso8601String(),
  },
];
