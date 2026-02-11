import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/api_client.dart';
import '../core/api_constants.dart';
import '../services/ticket_service.dart';

class AddTicketScreen extends StatefulWidget {
  const AddTicketScreen({super.key});

  @override
  State<AddTicketScreen> createState() => _AddTicketScreenState();
}

class _AddTicketScreenState extends State<AddTicketScreen> {
  final TextEditingController _descriptionController =
  TextEditingController();

  /// ===== MACHINE DATA =====
  List<Map<String, dynamic>> _machines = [];
  int? _selectedMachineId;

  /// ===== PROBLEM TYPE =====
  final List<String> _problemTypes = [
    'Breakdown',
    'Maintenance',
    'Inspection',
    'Electrical',
    'Mechanical',
  ];
  String? _selectedProblemType;

  /// ===== IMAGE =====
  File? _image;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadMachines();
  }

  /// ================= LOAD MACHINES =================
  Future<void> _loadMachines() async {
    try {
      final response =
      await ApiClient.getWithToken(ApiConstants.getmachine);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        setState(() {
          _machines =
          List<Map<String, dynamic>>.from(decoded['data']);
        });
      }
    } catch (e) {
      debugPrint('Machine load error: $e');
    }
  }

  /// ================= CAMERA ONLY =================
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1200,
    );

    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  /// ================= SUBMIT =================
  Future<void> _submit() async {
    if (_selectedMachineId == null ||
        _selectedProblemType == null ||
        _descriptionController.text.trim().isEmpty ||
        _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    setState(() => _loading = true);

    final success = await TicketService.createTicket(
      description: _descriptionController.text.trim(),
      machineId: _selectedMachineId.toString(),
      type: _selectedProblemType!,
      image: _image!,
    );

    setState(() => _loading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket created successfully')),
      );
      Navigator.pop(context, true);
    }
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        automaticallyImplyLeading: false,

        title: SizedBox(
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              /// 🔹 LEFT LOGO
              Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'images/appBarIcon.png',
                  height: 34,
                  fit: BoxFit.contain,
                ),
              ),

              /// 🔹 CENTER TITLE (TRUE CENTER)
              const Text(
                'Add Ticket',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),

              /// 🔹 RIGHT CLOSE BUTTON
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),

      /// ===== BODY =====
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Card(
            elevation: 5,
            shadowColor: Colors.black12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ===== MACHINE DROPDOWN =====
                  DropdownButtonFormField<int>(
                    value: _selectedMachineId,
                    hint: const Text('Select Machine'),
                    items: _machines.map((m) {
                      return DropdownMenuItem<int>(
                        value: m['id'],
                        child: Text(
                          m['machineName'] ?? m['name'] ?? '--',
                        ),
                      );
                    }).toList(),
                    onChanged: (v) =>
                        setState(() => _selectedMachineId = v),
                    decoration: _inputDecoration(
                        Icons.precision_manufacturing),
                  ),

                  const SizedBox(height: 16),

                  /// ===== PROBLEM TYPE =====
                  DropdownButtonFormField<String>(
                    value: _selectedProblemType,
                    hint: const Text('Problem Type'),
                    items: _problemTypes
                        .map(
                          (t) => DropdownMenuItem(
                        value: t,
                        child: Text(t),
                      ),
                    )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedProblemType = v),
                    decoration:
                    _inputDecoration(Icons.category),
                  ),

                  const SizedBox(height: 16),

                  /// ===== DESCRIPTION =====
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: _inputDecoration(Icons.description)
                        .copyWith(
                        labelText: 'Problem Description'),
                  ),

                  const SizedBox(height: 20),

                  /// ===== CAMERA =====
                  InkWell(
                    onTap: _pickImage,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      padding:
                      const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(14),
                        border:
                        Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.camera_alt,
                            size: 36,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _image == null
                                ? 'Capture Photo'
                                : 'Photo Captured',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_image != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _image!,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],

                  const SizedBox(height: 26),

                  /// ===== SUBMIT =====
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xFF1E88E5),
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(14),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        'Create Ticket',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ===== INPUT DECORATION =====
  InputDecoration _inputDecoration(IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF9FBFF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
