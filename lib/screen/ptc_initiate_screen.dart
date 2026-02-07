import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ticket_service.dart';

class InitiatePTCScreen extends StatefulWidget {
  final int eventId;
  const InitiatePTCScreen({super.key, required this.eventId});

  @override
  State<InitiatePTCScreen> createState() => _InitiatePTCScreenState();
}

class _InitiatePTCScreenState extends State<InitiatePTCScreen> {
  bool isSOPFollowed = false;
  bool isMachineWorking = false;
  bool isInjuryOccurred = false;
  File? closerImage;
  bool loading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked != null) {
      setState(() {
        closerImage = File(picked.path);
      });
    }
  }

  Future<void> _submit() async {
    setState(() => loading = true);

    final success = await TicketService.initiatePTC(
      eventId: widget.eventId,
      isSOPFollowed: isSOPFollowed,
      isMachineWorking: isMachineWorking,
      isInjuryOccurred: isInjuryOccurred,
      closerImage: closerImage,
    );

    setState(() => loading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ticket initiated for PTC approval'),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// ===== APP BAR =====
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
                  height: 37,
                  fit: BoxFit.contain,
                ),
              ),

              /// 🔹 CENTER TITLE (TRUE CENTER)
              const Text(
                'Initiate PTC',
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            elevation: 6,
            shadowColor: Colors.black12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔹 HEADER
                  const Text(
                    'PTC Safety Checklist',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Please confirm the following before initiating PTC',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🔹 CHECKLIST
                  _CheckItem(
                    title: 'SOP Followed',
                    value: isSOPFollowed,
                    onChanged: (v) =>
                        setState(() => isSOPFollowed = v),
                  ),
                  _CheckItem(
                    title: 'Machine Working Properly',
                    value: isMachineWorking,
                    onChanged: (v) =>
                        setState(() => isMachineWorking = v),
                  ),
                  _CheckItem(
                    title: 'Any Injury Occurred',
                    value: isInjuryOccurred,
                    onChanged: (v) =>
                        setState(() => isInjuryOccurred = v),
                  ),

                  const SizedBox(height: 20),

                  /// 🔹 IMAGE UPLOAD
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.upload_file),
                    label: Text(
                      closerImage == null
                          ? 'Upload Closer Image'
                          : 'Image Selected',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                      const Color(0xFF1E88E5),
                      side: const BorderSide(
                          color: Color(0xFF1E88E5)),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12),
                    ),
                  ),

                  if (closerImage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Selected: ${closerImage!.path.split('/').last}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                  const SizedBox(height: 30),

                  /// 🔹 SUBMIT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: loading ? null : _submit,
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
                      child: loading
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text('Submit PTC Request'),
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
}

/// ================= CHECK ITEM =================
class _CheckItem extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CheckItem({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      activeColor: const Color(0xFF1E88E5),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      value: value,
      onChanged: (v) => onChanged(v!),
    );
  }
}
