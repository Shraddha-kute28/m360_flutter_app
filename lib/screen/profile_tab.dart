import 'package:flutter/material.dart';
import '../core/token_storage.dart';
import 'login_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth > 600 ? 420.0 : screenWidth * 0.9;

    return FutureBuilder(
      future: Future.wait([
        TokenStorage.getName(),
        TokenStorage.getRole(),
      ]),
      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final name = snapshot.data![0] as String? ?? 'User';
        final role = snapshot.data![1] as String? ?? '';

        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: cardWidth,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      /// Profile Avatar
                      const CircleAvatar(
                        radius: 48,
                        backgroundColor: Color(0xFF1E88E5),
                        child: Icon(Icons.person, size: 46, color: Colors.white),
                      ),

                      const SizedBox(height: 16),

                      /// Name
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      /// Role
                      Text(
                        role,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 28),

                      const Divider(),

                      const SizedBox(height: 10),

                      /// Logout Button (Same Functionality)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.logout),
                          label: const Text("Logout"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            await TokenStorage.clear();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  (_) => false,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
