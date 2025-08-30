import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:snaprent/core/constant.dart';
import 'package:snaprent/core/mock_data.dart';
import 'package:snaprent/services/api_service.dart';
import 'package:snaprent/widgets/input_widget.dart';
import 'package:snaprent/widgets/safe_scaffold.dart';
import 'package:snaprent/widgets/snack_bar.dart';

class UpdatePropertyScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> property;

  const UpdatePropertyScreen({super.key, required this.property});

  @override
  ConsumerState<UpdatePropertyScreen> createState() =>
      _UpdatePropertyScreenState();
}

class _UpdatePropertyScreenState extends ConsumerState<UpdatePropertyScreen> {
  int _currentStep = 0;

  // Global keys for each step
  final _step0FormKey = GlobalKey<FormState>();
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();
  final _step3FormKey = GlobalKey<FormState>();
  final _step4FormKey = GlobalKey<FormState>();
  final _step5FormKey = GlobalKey<FormState>();
  final _step6FormKey = GlobalKey<FormState>();
  final _step7FormKey = GlobalKey<FormState>();

  // Text controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final townController = TextEditingController();
  final quarterController = TextEditingController();
  final streetController = TextEditingController();
  final landmarkController = TextEditingController();
  final floorLevelController = TextEditingController();
  final sizeController = TextEditingController();
  final rentController = TextEditingController();
  final securityDepositController = TextEditingController();
  final agentNameController = TextEditingController();
  final phoneController = TextEditingController();
  final whatsappController = TextEditingController();

  // Dropdown/default values
  String propertyType = 'studio';
  String paymentFrequency = 'monthly';
  String toiletType = 'private';
  String bathroomType = 'private';
  String kitchenType = 'private';
  String meterType = 'prepaid';
  String quietHours = '10 PM - 6 AM';

  bool furnished = false;
  bool waterAvailable = false;
  bool electricity = false;
  bool internet = false;
  bool parking = false;
  bool balcony = false;
  bool ceilingFan = false;
  bool tiledFloor = false;

  bool smokingAllowed = false;
  bool petsAllowed = false;
  bool visitorsAllowed = true;

  final List<String> quietHoursOptions = [
    '10 PM - 6 AM',
    '9 PM - 7 AM',
    '11 PM - 5 AM',
    'No quiet hours',
  ];

  // Map picker
  LatLng selectedCoordinates = const LatLng(4.0511, 9.7679); // default fallback
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadPropertyData(); // Load data from constructor
    _determinePosition(); // Get current user location
  }

  // New method to load existing property data into the form
  void _loadPropertyData() {
    final property = widget.property;

    // Set text controller values
    titleController.text = property['title'] ?? '';
    descriptionController.text = property['description'] ?? '';
    propertyType = property['type'] ?? 'studio';
    floorLevelController.text = (property['floorLevel'] ?? '').toString();
    sizeController.text = property['size'] ?? '';
    rentController.text = (property['rentAmount'] ?? '').toString();
    paymentFrequency = property['paymentFrequency'] ?? 'monthly';
    securityDepositController.text = (property['securityDeposit'] ?? '')
        .toString();

    // Check and set nested location data
    if (property['location'] != null) {
      final location = property['location'];

      townController.text = location['town'] ?? '';
      quarterController.text = location['quarter'] ?? '';
      streetController.text = location['street'] ?? '';
      landmarkController.text = location['landmark'] ?? '';

      // Set map coordinates and center the map
      if (location['coordinates'] != null &&
          location['coordinates'].length >= 2) {
        selectedCoordinates = LatLng(
          location['coordinates'][1],
          location['coordinates'][0],
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(selectedCoordinates, 15);
        });
      }
    }

    // Check and set nested amenities data
    if (property['amenities'] != null) {
      final amenities = property['amenities'];
      toiletType = amenities['toilet'] ?? 'private';
      bathroomType = amenities['bathroom'] ?? 'private';
      kitchenType = amenities['kitchen'] ?? 'private';
      meterType = amenities['meterType'] ?? 'prepaid';
      furnished = amenities['furnished'] ?? false;
      waterAvailable = amenities['waterAvailable'] ?? false;
      electricity = amenities['electricity'] ?? false;
      internet = amenities['internet'] ?? false;
      parking = amenities['parking'] ?? false;
      balcony = amenities['balcony'] ?? false;
      ceilingFan = amenities['ceilingFan'] ?? false;
      tiledFloor = amenities['tiledFloor'] ?? false;
    }

    // Check and set nested house rules data
    if (property['houseRules'] != null) {
      final houseRules = property['houseRules'];
      smokingAllowed = houseRules['smokingAllowed'] ?? false;
      petsAllowed = houseRules['petsAllowed'] ?? false;
      visitorsAllowed = houseRules['visitorsAllowed'] ?? true;
      quietHours = houseRules['quietHours'] ?? '10 PM - 6 AM';
    }

    // Check and set nested contact data
    if (property['contact'] != null) {
      final contact = property['contact'];
      agentNameController.text = contact['agentName'] ?? '';
      phoneController.text = contact['phone'] ?? '';
      whatsappController.text = contact['whatsapp'] ?? '';
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      selectedCoordinates = LatLng(position.latitude, position.longitude);
      _mapController.move(selectedCoordinates, 15);
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    townController.dispose();
    quarterController.dispose();
    streetController.dispose();
    landmarkController.dispose();
    floorLevelController.dispose();
    sizeController.dispose();
    rentController.dispose();
    securityDepositController.dispose();
    agentNameController.dispose();
    phoneController.dispose();
    whatsappController.dispose();
    super.dispose();
  }

  void _nextStep() {
    // Get the key for the current step
    GlobalKey<FormState> currentFormKey;
    switch (_currentStep) {
      case 0:
        currentFormKey = _step0FormKey;
        break;
      case 1:
        currentFormKey = _step1FormKey;
        break;
      case 2:
        currentFormKey = _step2FormKey;
        break;
      case 3:
        currentFormKey = _step3FormKey;
        break;
      case 4:
        currentFormKey = _step4FormKey;
        break;
      case 5:
        currentFormKey = _step5FormKey;
        break;
      case 6:
        currentFormKey = _step6FormKey;
        break;
      case 7:
        currentFormKey = _step7FormKey;
        break;
      default:
        currentFormKey = _step0FormKey; // Fallback
    }

    // Validate only the current step
    if (currentFormKey.currentState!.validate()) {
      if (_currentStep < 7) {
        setState(() => _currentStep += 1);
      } else {
        // This is the last step, so call the update function
        update();
      }
    } else {
      // Show a snackbar if validation fails
      SnackbarHelper.show(
        context,
        "Please fill in all required fields to continue.",
        success: false,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) setState(() => _currentStep -= 1);
  }

  Widget buildCheckboxItem(
    String label,
    bool value,
    Function(bool?) onChanged,
  ) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2 - 32,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.lightBlue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              side: const BorderSide(color: Colors.black54, width: 2),
            ),
            Flexible(
              child: Text(label, style: const TextStyle(color: Colors.black87)),
            ),
          ],
        ),
      ),
    );
  }

  // New function to handle the update
  Future<void> update() async {
    final propertyData = {
      "title": titleController.text.trim(),
      "description": descriptionController.text.trim(),
      "location": {
        "type": "Point",
        "coordinates": [
          selectedCoordinates.longitude,
          selectedCoordinates.latitude,
        ],
        "town": townController.text.trim(),
        "quarter": quarterController.text.trim(),
        "street": streetController.text.trim(),
        "landmark": landmarkController.text.trim(),
      },
      "type": propertyType,
      "floorLevel": int.tryParse(floorLevelController.text) ?? 1,
      "size": sizeController.text.trim(),
      "rentAmount": int.tryParse(rentController.text) ?? 0,
      "currency": "FCFA",
      "paymentFrequency": paymentFrequency,
      "securityDeposit": int.tryParse(securityDepositController.text) ?? 0,
      "amenities": {
        "toilet": toiletType,
        "bathroom": bathroomType,
        "kitchen": kitchenType,
        "furnished": furnished,
        "waterAvailable": waterAvailable,
        "electricity": electricity,
        "meterType": meterType,
        "internet": internet,
        "parking": parking,
        "balcony": balcony,
        "ceilingFan": ceilingFan,
        "tiledFloor": tiledFloor,
      },
      "houseRules": {
        "smokingAllowed": smokingAllowed,
        "petsAllowed": petsAllowed,
        "quietHours": quietHours,
        "visitorsAllowed": visitorsAllowed,
      },
      "contact": {
        "agentName": agentNameController.text.trim(),
        "phone": formatCameroonPhone(phoneController.text.trim(), context),
        "whatsapp": formatCameroonPhone(
          whatsappController.text.trim(),
          context,
        ),
      },
    };

    print(propertyData);

    try {
      final propertyId = widget.property['_id'];
      final response = await ref
          .read(apiServiceProvider)
          .put(
            'properties/$propertyId', // Use PUT for full update
            propertyData,
            context,
          );

      if (response != null && response['success']) {
        if (!mounted) return;
        SnackbarHelper.show(context, "Property updated successfully.");
        Navigator.of(context).pop();
      } else {
        if (!mounted) return;
        SnackbarHelper.show(
          context,
          "Failed to update property.",
          success: false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.show(context, "Error: $e", success: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const fieldSpacing = SizedBox(height: 12);

    return SafeScaffold(
      child: Stepper(
        currentStep: _currentStep,
        onStepContinue: _nextStep,
        onStepCancel: _previousStep,
        onStepTapped: (index) {
          if (_currentStep == index)
            return; // Don't tap if it's the current step
          _nextStep();
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep != 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text("Cancel"),
                  ),
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentStep == 7 ? "Update Property" : "Continue",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
        steps: [
          // Step 0: Basic Info
          Step(
            title: const Text('Basic Info'),
            content: Form(
              key: _step0FormKey,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  textField(
                    controller: titleController,
                    label: 'Title',
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter title' : null,
                  ),
                  fieldSpacing,
                  textField(
                    controller: descriptionController,
                    label: 'Description',
                    maxLines: 3,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter description' : null,
                  ),
                  fieldSpacing,
                  dropdownField(
                    value: propertyType,
                    label: 'Property Type',
                    items: propertyTypes
                        .map(
                          (type) => DropdownMenuItem(
                            value: type["name"]!.toString(),
                            child: Text(type["name"]!.toString()),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => propertyType = val);
                    },
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Select property type' : null,
                  ),
                ],
              ),
            ),
            isActive: _currentStep >= 0,
          ),

          // Step 1: Location
          Step(
            title: const Text('Location'),
            content: Form(
              key: _step1FormKey,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  textField(
                    controller: townController,
                    label: 'Town',
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter town' : null,
                  ),
                  fieldSpacing,
                  textField(controller: quarterController, label: 'Quarter'),
                  fieldSpacing,
                  textField(controller: streetController, label: 'Street'),
                  fieldSpacing,
                  textField(controller: landmarkController, label: 'Landmark'),
                  fieldSpacing,
                  SizedBox(
                    height: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12), // adjust radius
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          center: selectedCoordinates,
                          zoom: 15,
                          onTap: (tapPos, latLng) {
                            setState(() => selectedCoordinates = latLng);
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.bongsc21o.app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: selectedCoordinates,
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 32,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            isActive: _currentStep >= 1,
          ),

          Step(
            title: const Text('Details & Size'),
            content: Form(
              key: _step2FormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  textField(
                    controller: floorLevelController,
                    label: 'Floor Level',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Enter floor level';
                      }
                      if (int.tryParse(v) == null) {
                        return 'Enter valid number';
                      }
                      return null;
                    },
                  ),
                  fieldSpacing,
                  textField(
                    controller: sizeController,
                    label: 'Size (e.g. 25m²)',
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter size' : null,
                  ),
                  fieldSpacing,
                  textField(
                    controller: rentController,
                    label: 'Rent Amount',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter rent amount';
                      if (int.tryParse(v) == null) return 'Enter valid number';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            isActive: _currentStep >= 2,
          ),

          Step(
            title: const Text('Payment & Deposit'),
            content: Form(
              key: _step3FormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  textField(
                    controller: securityDepositController,
                    label: 'Security Deposit',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return 'Enter security deposit';
                      if (int.tryParse(v) == null) return 'Enter valid number';
                      return null;
                    },
                  ),
                  fieldSpacing,
                  dropdownField(
                    value: paymentFrequency,
                    label: 'Payment Frequency',
                    items: const [
                      DropdownMenuItem(
                        value: 'monthly',
                        child: Text('Monthly'),
                      ),
                      DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => paymentFrequency = val);
                    },
                    validator: (v) => v == null || v.isEmpty
                        ? 'Select payment frequency'
                        : null,
                  ),
                ],
              ),
            ),
            isActive: _currentStep >= 3,
          ),

          Step(
            title: const Text('Features'),
            content: Form(
              key: _step4FormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  fieldSpacing,
                  dropdownField(
                    value: toiletType,
                    label: 'Toilet Type',
                    items: const [
                      DropdownMenuItem(
                        value: 'private',
                        child: Text('Private'),
                      ),
                      DropdownMenuItem(value: 'shared', child: Text('Shared')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => toiletType = val);
                    },
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Select toilet type' : null,
                  ),
                  fieldSpacing,
                  dropdownField(
                    value: bathroomType,
                    label: 'Bathroom Type',
                    items: const [
                      DropdownMenuItem(
                        value: 'private',
                        child: Text('Private'),
                      ),
                      DropdownMenuItem(value: 'shared', child: Text('Shared')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => bathroomType = val);
                    },
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Select bathroom type' : null,
                  ),
                  fieldSpacing,
                  dropdownField(
                    value: kitchenType,
                    label: 'Kitchen Type',
                    items: const [
                      DropdownMenuItem(
                        value: 'private',
                        child: Text('Private'),
                      ),
                      DropdownMenuItem(value: 'shared', child: Text('Shared')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => kitchenType = val);
                    },
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Select kitchen type' : null,
                  ),
                  fieldSpacing,
                  dropdownField(
                    value: meterType,
                    label: 'Meter Type',
                    items: const [
                      DropdownMenuItem(
                        value: 'prepaid',
                        child: Text('Prepaid'),
                      ),
                      DropdownMenuItem(
                        value: 'postpaid',
                        child: Text('Postpaid'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => meterType = val);
                    },
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Select meter type' : null,
                  ),
                ],
              ),
            ),
            isActive: _currentStep >= 4,
          ),

          Step(
            title: const Text('Amenities'),
            content: Form(
              key: _step5FormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GridView.count(
                    crossAxisCount: 2, // 2 items per row
                    crossAxisSpacing: 12, // horizontal spacing between items
                    mainAxisSpacing: 8, // vertical spacing between items
                    shrinkWrap: true, // so it takes only necessary height
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 2.3,
                    children: [
                      buildCheckboxItem('Furnished', furnished, (val) {
                        if (val != null) setState(() => furnished = val);
                      }),
                      buildCheckboxItem('Water Available', waterAvailable, (
                        val,
                      ) {
                        if (val != null) setState(() => waterAvailable = val);
                      }),
                      buildCheckboxItem('Electricity', electricity, (val) {
                        if (val != null) setState(() => electricity = val);
                      }),
                      buildCheckboxItem('Internet', internet, (val) {
                        if (val != null) setState(() => internet = val);
                      }),
                      buildCheckboxItem('Parking', parking, (val) {
                        if (val != null) setState(() => parking = val);
                      }),
                      buildCheckboxItem('Balcony', balcony, (val) {
                        if (val != null) setState(() => balcony = val);
                      }),
                      buildCheckboxItem('Ceiling Fan', ceilingFan, (val) {
                        if (val != null) setState(() => ceilingFan = val);
                      }),
                      buildCheckboxItem('Tiled Floor', tiledFloor, (val) {
                        if (val != null) setState(() => tiledFloor = val);
                      }),
                    ],
                  ),
                ],
              ),
            ),
            isActive: _currentStep >= 5,
          ),

          Step(
            title: const Text('House Rules'),
            content: Form(
              key: _step6FormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  dropdownField(
                    value: quietHours,
                    label: 'Quiet Hours',
                    items: quietHoursOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => quietHours = val);
                    },
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Select quiet hours' : null,
                  ),
                  const SizedBox(height: 16),
                  const Text("Allows"),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2, // 2 items per row
                    crossAxisSpacing: 12, // horizontal spacing between items
                    mainAxisSpacing: 8, // vertical spacing between items
                    shrinkWrap: true, // so it takes only necessary height
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 2.9,
                    children: [
                      buildCheckboxItem('Smoking', smokingAllowed, (val) {
                        if (val != null) {
                          setState(() => smokingAllowed = val);
                        }
                      }),
                      buildCheckboxItem('Pets', petsAllowed, (val) {
                        if (val != null) {
                          setState(() => petsAllowed = val);
                        }
                      }),
                      buildCheckboxItem('Visitors', visitorsAllowed, (val) {
                        if (val != null) {
                          setState(() => visitorsAllowed = val);
                        }
                      }),
                    ],
                  ),
                ],
              ),
            ),
            isActive: _currentStep >= 6,
          ),

          Step(
            title: const Text('Contact info'),
            content: Form(
              key: _step7FormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  textField(
                    controller: agentNameController,
                    label: 'Agent Name',
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter agent name' : null,
                  ),
                  fieldSpacing,
                  textField(
                    controller: phoneController,
                    label: 'Phone Number',
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter phone number' : null,
                  ),
                  fieldSpacing,
                  textField(
                    controller: whatsappController,
                    label: 'WhatsApp Number',
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
            isActive: _currentStep >= 7,
          ),
        ],
      ),
    );
  }
}
