import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ServiceRequestForm extends StatefulWidget {
  final String serviceName;
  final String? serviceId;

  const ServiceRequestForm({
    super.key,
    required this.serviceName,
    this.serviceId,
  });

  @override
  State<ServiceRequestForm> createState() => _ServiceRequestFormState();
}

class _ServiceRequestFormState extends State<ServiceRequestForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  String _urgency = 'Normal';

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      _emailController.text = user.email ?? '';
      _nameController.text = user.displayName ?? '';
      _phoneController.text = user.phoneNumber ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime today = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime(today.year + 2),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      _showMessage('Please select your preferred date.');
      return;
    }

    if (_selectedTime == null) {
      _showMessage('Please select your preferred time.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      final User? user = auth.currentUser;

      final DocumentReference requestRef =
          firestore.collection('service_requests').doc();

      await requestRef.set({
        'requestId': requestRef.id,

        // User information
        'userId': user?.uid,
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),

        // Service information
        'serviceId': widget.serviceId,
        'serviceName': widget.serviceName,

        // Request information
        'preferredDate': Timestamp.fromDate(_selectedDate!),
        'preferredTime': _selectedTime!.format(context),
        'description': _descriptionController.text.trim(),
        'urgency': _urgency,

        // Request management
        'status': 'pending',
        'assignedProviderId': null,
        'assignedProviderName': null,

        // Timestamp
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      _showSuccessDialog(requestRef.id);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      _showMessage(
        'Something went wrong. Please try again.',
      );

      debugPrint('Service request error: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessDialog(String requestId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 30,
              ),
              SizedBox(width: 10),
              Text('Request Sent'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your service request has been submitted successfully.',
              ),
              const SizedBox(height: 15),
              const Text(
                'Request ID',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              SelectableText(
                requestId,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Our team will review your request and contact you shortly.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('DONE'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Select date';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.handyman_outlined,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Service Request',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.serviceName,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // Name
            _buildLabel('Your Name'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                hint: 'Enter your name',
                icon: Icons.person_outline,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            // Phone
            _buildLabel('Contact Number'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                hint: 'Enter contact number',
                icon: Icons.phone_outlined,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your contact number';
                }

                if (value.trim().length < 10) {
                  return 'Enter a valid contact number';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            // Email
            _buildLabel('Email'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                hint: 'Enter email address',
                icon: Icons.email_outlined,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email';
                }

                if (!value.contains('@')) {
                  return 'Enter a valid email';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            // Date
            _buildLabel('Preferred Date'),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _formatDate(_selectedDate),
                      style: TextStyle(
                        color: _selectedDate == null
                            ? Colors.grey.shade600
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Time
            _buildLabel('Preferred Time'),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectTime,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time_outlined,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _selectedTime == null
                          ? 'Select time'
                          : _selectedTime!.format(context),
                      style: TextStyle(
                        color: _selectedTime == null
                            ? Colors.grey.shade600
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Description
            _buildLabel('Describe Your Requirement'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: _inputDecoration(
                hint: 'Tell us what service you need...',
                icon: Icons.description_outlined,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please describe your requirement';
                }

                return null;
              },
            ),

            const SizedBox(height: 22),

            // Urgency
            _buildLabel('Urgency'),
            const SizedBox(height: 10),

            _buildUrgencyOption(
              value: 'Normal',
              title: 'Normal',
              subtitle: 'Regular service request',
              icon: Icons.schedule_outlined,
            ),

            const SizedBox(height: 8),

            _buildUrgencyOption(
              value: 'Priority',
              title: 'Priority',
              subtitle: 'Need service soon',
              icon: Icons.priority_high,
            ),

            const SizedBox(height: 8),

            _buildUrgencyOption(
              value: 'Emergency',
              title: 'Emergency',
              subtitle: 'Immediate assistance needed',
              icon: Icons.warning_amber_rounded,
            ),

            const SizedBox(height: 25),

            // Confirm button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline),
                          SizedBox(width: 8),
                          Text(
                            'CONFIRM BOOKING',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.blue,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildUrgencyOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final bool selected = _urgency == value;

    return InkWell(
      onTap: () {
        setState(() {
          _urgency = value;
        });
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? Colors.blue
                : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
          color: selected
              ? Colors.blue.withValues(alpha: 0.06)
              : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected
                  ? Colors.blue
                  : Colors.grey.shade600,
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            Radio<String>(
              value: value,
              groupValue: _urgency,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _urgency = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}