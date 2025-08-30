import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:snaprent/core/constant.dart';
import 'package:snaprent/widgets/input_widget.dart';

// Enum and network detection function as provided
enum CameroonNetwork { orange, mtn, unknown }

CameroonNetwork getCameroonNetwork(String phoneNumber) {
  String normalizedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

  // Updated regex to be slightly more robust and current
  // MTN prefixes: 67, 68, 650, 651, 652, 653, 654
  final mtnRegex = RegExp(r'^(?:237)?(67\d{7}|68\d{7}|65[0-4]\d{6})$');
  // Orange prefixes: 655, 656, 657, 658, 659, 69
  final orangeRegex = RegExp(r'^(?:237)?(65[5-9]\d{6}|69\d{7})$');

  if (orangeRegex.hasMatch(normalizedNumber)) {
    return CameroonNetwork.orange;
  } else if (mtnRegex.hasMatch(normalizedNumber)) {
    return CameroonNetwork.mtn;
  } else {
    return CameroonNetwork.unknown;
  }
}

class PaymentDrawer extends StatefulWidget {
  final String? phoneNumber;
  final CameroonNetwork network;
  final String? message;

  const PaymentDrawer({
    super.key,
    this.phoneNumber,
    this.network = CameroonNetwork.unknown,
    this.message,
  });

  @override
  State<PaymentDrawer> createState() => _PaymentDrawerState();
}

class _PaymentDrawerState extends State<PaymentDrawer> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  CameroonNetwork _currentNetwork = CameroonNetwork.unknown;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.phoneNumber != null) {
      phoneNumberController.text = widget.phoneNumber!;
    }
    _updateNetwork(phoneNumberController.text);
    phoneNumberController.addListener(_onPhoneNumberChanged);
  }

  void _onPhoneNumberChanged() {
    _updateNetwork(phoneNumberController.text);
  }

  void _updateNetwork(String number) {
    setState(() {
      _currentNetwork = getCameroonNetwork(number);
    });
  }

  @override
  void dispose() {
    phoneNumberController.removeListener(_onPhoneNumberChanged);
    phoneNumberController.dispose();
    super.dispose();
  }

  void _confirmPayment() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop({
        'phoneNumber': phoneNumberController.text.trim(),
        'message': capitalizeFirstLetter(messageController.text.trim()),
        'network': _currentNetwork.name,
      });
    }
  }

  // Helper to get network icon
  Widget _getNetworkIcon() {
    switch (_currentNetwork) {
      case CameroonNetwork.orange:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SvgPicture.asset(
            'assets/test/orange.svg',
            height: 24,
            width: 24,
          ),
        );
      case CameroonNetwork.mtn:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SvgPicture.asset('assets/test/mtn.svg', height: 24, width: 24),
        );
      case CameroonNetwork.unknown:
      default:
        return const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.phone_android, color: Colors.grey),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                "Phone Number",
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
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Phone Number Input
                  TextFormField(
                    controller: phoneNumberController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'e.g., 678123456 or +237678123456',
                      prefixIcon: _getNetworkIcon(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(
                          color: Colors.indigo,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a phone number';
                      }
                      final cameroonPhoneRegex = RegExp(r'^(?:237)?(6\d{8})$');
                      if (!cameroonPhoneRegex.hasMatch(
                        value.replaceAll(RegExp(r'\D'), ''),
                      )) {
                        return 'Please enter a valid Cameroonian phone number';
                      }
                      if (_currentNetwork == CameroonNetwork.unknown) {
                        return 'Network not recognized (Orange/MTN only)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12.0),
                  textField(
                    controller: messageController,
                    label: 'Reason for Payment',
                    maxLines: 3,
                    validator: (v) => v == null || v.isEmpty
                        ? 'Enter reason for payment'
                        : null,
                  ),
                  const SizedBox(height: 24.0),
                  // Confirm Payment Button
                  ElevatedButton(
                    onPressed: isLoading ? null : _confirmPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 5,
                      shadowColor: Colors.indigo.withOpacity(0.5),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Pay',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
