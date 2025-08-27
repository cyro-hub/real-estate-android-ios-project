// import 'package:flutter/material.dart';
// import 'package:snaprent/core/constant.dart';
// import 'package:dropdown_search/dropdown_search.dart';

// class FilterDrawer extends StatefulWidget {
//   final List<String> towns;
//   final String? initialSelectedLocation;
//   final double? initialMaxRent;
//   final String? initialPaymentFrequency;
//   final String? initialToilet;
//   final String? initialBathroom;
//   final String? initialKitchen;
//   final bool? initialWaterAvailable;
//   final bool? initialElectricity;
//   final bool? initialParking;

//   const FilterDrawer({
//     super.key,
//     required this.towns,
//     this.initialSelectedLocation,
//     this.initialMaxRent,
//     this.initialPaymentFrequency,
//     this.initialToilet,
//     this.initialBathroom,
//     this.initialKitchen,
//     this.initialWaterAvailable,
//     this.initialElectricity,
//     this.initialParking,
//   });

//   @override
//   State<FilterDrawer> createState() => FilterDrawerState();
// }

// class FilterDrawerState extends State<FilterDrawer> {
//   late String? _selectedLocation;
//   late double? _maxRent;
//   late String? _paymentFrequency;
//   late String? _toilet;
//   late String? _bathroom;
//   late String? _kitchen;
//   late bool? _waterAvailable;
//   late bool? _electricity;
//   late bool? _parking;

//   @override
//   void initState() {
//     super.initState();
//     _selectedLocation = widget.initialSelectedLocation;
//     _maxRent = widget.initialMaxRent;
//     _paymentFrequency = widget.initialPaymentFrequency;
//     _toilet = widget.initialToilet;
//     _bathroom = widget.initialBathroom;
//     _kitchen = widget.initialKitchen;
//     _waterAvailable = widget.initialWaterAvailable;
//     _electricity = widget.initialElectricity;
//     _parking = widget.initialParking;
//   }

//   void _applyFilters() {
//     Navigator.of(context).pop({
//       'location': _selectedLocation,
//       'maxRent': _maxRent,
//       'paymentFrequency': _paymentFrequency,
//       'toilet': _toilet,
//       'bathroom': _bathroom,
//       'kitchen': _kitchen,
//       'waterAvailable': _waterAvailable,
//       'electricity': _electricity,
//       'parking': _parking,
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Get bottom safe area padding (e.g., for navigation bar)
//     final double bottomSafeArea = MediaQuery.of(context).padding.bottom;

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(0), // No border radius
//           topRight: Radius.circular(0), // No border radius
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           const SizedBox(height: 28),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 "Property Filters",
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black54,
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.close, color: Colors.black54),
//                 onPressed: () => Navigator.of(context).pop(),
//               ),
//             ],
//           ),
//           Expanded(
//             child: ListView(
//               // Add bottom padding to ListView to avoid content being covered by system nav bar
//               padding: EdgeInsets.only(
//                 bottom: bottomSafeArea > 0 ? bottomSafeArea + 20 : 0,
//               ),
//               children: [
//                 // Integrated searchable location input
//                 _buildFilterDropdown(
//                   "Location",
//                   DropdownButtonFormField<String>(
//                     value: _selectedLocation,
//                     style: const TextStyle(color: Colors.black54),
//                     decoration: const InputDecoration(
//                       hintText: "Select a town",
//                       border: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.grey),
//                       ),
//                     ),
//                     items: [
//                       const DropdownMenuItem<String>(
//                         value: null,
//                         child: Text("All"),
//                       ),
//                       ...widget.towns.map((town) {
//                         return DropdownMenuItem<String>(
//                           value: town,
//                           child: Text(town),
//                         );
//                       }),
//                     ],
//                     onChanged: (value) =>
//                         setState(() => _selectedLocation = value),
//                   ),
//                 ),
//                 DropdownSearch<String>(
//                   selectedItem: "Menu",
//                   items: (filter, infiniteScrollProps) => this.towns,
//                   decoratorProps: const DropDownDecoratorProps(
//                     decoration: InputDecoration(border: OutlineInputBorder()),
//                   ),
//                   popupProps: const PopupProps.menu(
//                     showSearchBox:
//                         true, // This enables the search functionality
//                     fit: FlexFit.loose,
//                     constraints: BoxConstraints(),
//                   ),
//                 ),

//                 // Max Rent Slider
//                 _buildFilterSlider(
//                   "Max Rent",
//                   _maxRent ?? 0,
//                   (value) => setState(() => _maxRent = value),
//                   min: 0,
//                   max: 800000,
//                   divisions: 1000,
//                 ),

//                 // Payment Frequency
//                 _buildFilterDropdown(
//                   "Payment Frequency",
//                   DropdownButtonFormField<String>(
//                     value: _paymentFrequency,
//                     style: const TextStyle(color: Colors.black54),
//                     decoration: const InputDecoration(
//                       border: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.grey),
//                       ),
//                     ),
//                     items: const [
//                       DropdownMenuItem(value: null, child: Text("Any")),
//                       DropdownMenuItem(
//                         value: 'monthly',
//                         child: Text("Monthly"),
//                       ),
//                       DropdownMenuItem(value: 'yearly', child: Text("Yearly")),
//                     ],
//                     onChanged: (value) =>
//                         setState(() => _paymentFrequency = value),
//                   ),
//                 ),

//                 // Toilets, Bathrooms, and Kitchens
//                 _buildFilterDropdown(
//                   "Toilets",
//                   DropdownButtonFormField<String>(
//                     value: _toilet,
//                     style: const TextStyle(color: Colors.black54),
//                     decoration: const InputDecoration(
//                       border: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.grey),
//                       ),
//                     ),
//                     items: const [
//                       DropdownMenuItem(value: null, child: Text("Any")),
//                       DropdownMenuItem(
//                         value: 'private',
//                         child: Text("Private"),
//                       ),
//                       DropdownMenuItem(value: 'shared', child: Text("Shared")),
//                     ],
//                     onChanged: (value) => setState(() => _toilet = value),
//                   ),
//                 ),
//                 _buildFilterDropdown(
//                   "Bathrooms",
//                   DropdownButtonFormField<String>(
//                     value: _bathroom,
//                     style: const TextStyle(color: Colors.black54),
//                     decoration: const InputDecoration(
//                       border: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.grey),
//                       ),
//                     ),
//                     items: const [
//                       DropdownMenuItem(value: null, child: Text("Any")),
//                       DropdownMenuItem(
//                         value: 'private',
//                         child: Text("Private"),
//                       ),
//                       DropdownMenuItem(value: 'shared', child: Text("Shared")),
//                     ],
//                     onChanged: (value) => setState(() => _bathroom = value),
//                   ),
//                 ),
//                 _buildFilterDropdown(
//                   "Kitchen",
//                   DropdownButtonFormField<String>(
//                     value: _kitchen,
//                     style: const TextStyle(color: Colors.black54),
//                     decoration: const InputDecoration(
//                       border: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.grey),
//                       ),
//                     ),
//                     items: const [
//                       DropdownMenuItem(value: null, child: Text("Any")),
//                       DropdownMenuItem(
//                         value: 'private',
//                         child: Text("Private"),
//                       ),
//                       DropdownMenuItem(value: 'shared', child: Text("Shared")),
//                     ],
//                     onChanged: (value) => setState(() => _kitchen = value),
//                   ),
//                 ),

//                 // Checkbox filters
//                 _buildFilterToggle(
//                   "Water Available",
//                   _waterAvailable,
//                   (value) => setState(() => _waterAvailable = value),
//                 ),
//                 _buildFilterToggle(
//                   "Electricity",
//                   _electricity,
//                   (value) => setState(() => _electricity = value),
//                 ),
//                 _buildFilterToggle(
//                   "Parking",
//                   _parking,
//                   (value) => setState(() => _parking = value),
//                 ),

//                 const SizedBox(height: 20),

//                 // Apply Filters Button
//                 ElevatedButton(
//                   onPressed: _applyFilters,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.indigo,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text(
//                     "Apply Filters",
//                     style: TextStyle(fontSize: 16, color: Colors.white),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 // Reset Button
//                 OutlinedButton(
//                   onPressed: () {
//                     Navigator.of(context).pop(null);
//                   },
//                   style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text(
//                     "Reset",
//                     style: TextStyle(fontSize: 16, color: Colors.black54),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper function for dropdown filters
//   Widget _buildFilterDropdown(String title, Widget dropdown) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Colors.indigo,
//             ),
//           ),
//           const SizedBox(height: 8),
//           dropdown,
//         ],
//       ),
//     );
//   }

//   // Helper function for toggle filters (Switches)
//   Widget _buildFilterToggle(
//     String title,
//     bool? value,
//     ValueChanged<bool?> onChanged,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Colors.indigo,
//             ),
//           ),
//           Transform.scale(
//             scale: .75, // 1.0 is default size, 1.5 is 50% larger
//             child: Switch(
//               value: value ?? false,
//               onChanged: (val) => onChanged(val),
//               activeColor: Colors.indigo,
//               inactiveTrackColor: Colors.white,
//               inactiveThumbColor: Colors.indigo,
//               trackOutlineColor: MaterialStateProperty.all(
//                 const Color.fromARGB(177, 63, 81, 181),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper function for building the slider filter
//   Widget _buildFilterSlider(
//     String title,
//     double value,
//     ValueChanged<double> onChanged, {
//     double min = 0,
//     double max = 100,
//     int? divisions,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.indigo,
//                 ),
//               ),
//               Text(
//                 'Up to FCFA ${formatPrice(value.toInt())}',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.indigo,
//                   fontSize: 16,
//                 ),
//               ),
//             ],
//           ),
//           Slider(
//             value: value,
//             padding: const EdgeInsets.only(top: 16, left: 8, right: 8),
//             activeColor: Colors.indigo,
//             inactiveColor: Colors.grey[300],
//             min: min,
//             max: max,
//             divisions: divisions,
//             onChanged: onChanged,
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:snaprent/core/constant.dart';
import 'package:dropdown_search/dropdown_search.dart';

class FilterDrawer extends StatefulWidget {
  final List<String> towns;
  final String? initialSelectedLocation;
  final double? initialMaxRent;
  final String? initialPaymentFrequency;
  final String? initialToilet;
  final String? initialBathroom;
  final String? initialKitchen;
  final bool? initialWaterAvailable;
  final bool? initialElectricity;
  final bool? initialParking;

  const FilterDrawer({
    super.key,
    required this.towns,
    this.initialSelectedLocation,
    this.initialMaxRent,
    this.initialPaymentFrequency,
    this.initialToilet,
    this.initialBathroom,
    this.initialKitchen,
    this.initialWaterAvailable,
    this.initialElectricity,
    this.initialParking,
  });

  @override
  State<FilterDrawer> createState() => FilterDrawerState();
}

class FilterDrawerState extends State<FilterDrawer> {
  late String? _selectedLocation;
  late double? _maxRent;
  late String? _paymentFrequency;
  late String? _toilet;
  late String? _bathroom;
  late String? _kitchen;
  late bool? _waterAvailable;
  late bool? _electricity;
  late bool? _parking;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialSelectedLocation;
    _maxRent = widget.initialMaxRent;
    _paymentFrequency = widget.initialPaymentFrequency;
    _toilet = widget.initialToilet;
    _bathroom = widget.initialBathroom;
    _kitchen = widget.initialKitchen;
    _waterAvailable = widget.initialWaterAvailable;
    _electricity = widget.initialElectricity;
    _parking = widget.initialParking;
  }

  void _applyFilters() {
    Navigator.of(context).pop({
      'location': _selectedLocation,
      'maxRent': _maxRent,
      'paymentFrequency': _paymentFrequency,
      'toilet': _toilet,
      'bathroom': _bathroom,
      'kitchen': _kitchen,
      'waterAvailable': _waterAvailable,
      'electricity': _electricity,
      'parking': _parking,
    });
  }

  @override
  Widget build(BuildContext context) {
    final double bottomSafeArea = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Property Filters",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black54),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(
                bottom: bottomSafeArea > 0 ? bottomSafeArea + 20 : 0,
              ),
              children: [
                _buildFilterDropdown(
                  "Towns",
                  DropdownSearch<String>(
                    selectedItem: _selectedLocation,
                    items: (filter, infiniteScrollProps) => widget.towns,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedLocation = value;
                      });
                    },
                    decoratorProps: const DropDownDecoratorProps(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Select a town",
                      ),
                    ),
                    popupProps: const PopupProps.menu(
                      showSearchBox:
                          true, // This enables the search functionality
                      fit: FlexFit.loose,
                      constraints: BoxConstraints(),
                    ),
                  ),
                ),
                _buildFilterSlider(
                  "Max Rent",
                  _maxRent ?? 0,
                  (value) => setState(() => _maxRent = value),
                  min: 0,
                  max: 800000,
                  divisions: 1000,
                ),
                _buildFilterDropdown(
                  "Payment Frequency",
                  DropdownButtonFormField<String>(
                    value: _paymentFrequency,
                    style: const TextStyle(color: Colors.black54),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text("Any")),
                      DropdownMenuItem(
                        value: 'monthly',
                        child: Text("Monthly"),
                      ),
                      DropdownMenuItem(value: 'yearly', child: Text("Yearly")),
                    ],
                    onChanged: (value) =>
                        setState(() => _paymentFrequency = value),
                  ),
                ),
                _buildFilterDropdown(
                  "Toilets",
                  DropdownButtonFormField<String>(
                    value: _toilet,
                    style: const TextStyle(color: Colors.black54),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text("Any")),
                      DropdownMenuItem(
                        value: 'private',
                        child: Text("Private"),
                      ),
                      DropdownMenuItem(value: 'shared', child: Text("Shared")),
                    ],
                    onChanged: (value) => setState(() => _toilet = value),
                  ),
                ),
                _buildFilterDropdown(
                  "Bathrooms",
                  DropdownButtonFormField<String>(
                    value: _bathroom,
                    style: const TextStyle(color: Colors.black54),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text("Any")),
                      DropdownMenuItem(
                        value: 'private',
                        child: Text("Private"),
                      ),
                      DropdownMenuItem(value: 'shared', child: Text("Shared")),
                    ],
                    onChanged: (value) => setState(() => _bathroom = value),
                  ),
                ),
                _buildFilterDropdown(
                  "Kitchen",
                  DropdownButtonFormField<String>(
                    value: _kitchen,
                    style: const TextStyle(color: Colors.black54),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text("Any")),
                      DropdownMenuItem(
                        value: 'private',
                        child: Text("Private"),
                      ),
                      DropdownMenuItem(value: 'shared', child: Text("Shared")),
                    ],
                    onChanged: (value) => setState(() => _kitchen = value),
                  ),
                ),
                _buildFilterToggle(
                  "Water Available",
                  _waterAvailable,
                  (value) => setState(() => _waterAvailable = value),
                ),
                _buildFilterToggle(
                  "Electricity",
                  _electricity,
                  (value) => setState(() => _electricity = value),
                ),
                _buildFilterToggle(
                  "Parking",
                  _parking,
                  (value) => setState(() => _parking = value),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Apply Filters",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Reset",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String title, Widget dropdown) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 8),
          dropdown,
        ],
      ),
    );
  }

  Widget _buildFilterToggle(
    String title,
    bool? value,
    ValueChanged<bool?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          Transform.scale(
            scale: .75,
            child: Switch(
              value: value ?? false,
              onChanged: (val) => onChanged(val),
              activeColor: Colors.indigo,
              inactiveTrackColor: Colors.white,
              inactiveThumbColor: Colors.indigo,
              trackOutlineColor: MaterialStateProperty.all(
                const Color.fromARGB(177, 63, 81, 181),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSlider(
    String title,
    double value,
    ValueChanged<double> onChanged, {
    double min = 0,
    double max = 100,
    int? divisions,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              Text(
                'Up to FCFA ${formatPrice(value.toInt())}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            padding: const EdgeInsets.only(top: 16, left: 8, right: 8),
            activeColor: Colors.indigo,
            inactiveColor: Colors.grey[300],
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
