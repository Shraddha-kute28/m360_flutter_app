import 'package:flutter/material.dart';

class M360AppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;

  const M360AppBar({
    super.key,
    required this.title,
    this.showBack = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF1E88E5),
      elevation: 0,
      automaticallyImplyLeading: showBack,

      title: Stack(
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

          /// 🔹 CENTER TITLE
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
