import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool hasBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.hasBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white, 
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false, 
      leading: hasBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.deepPurple,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 15.0),
          child: Icon(Icons.notifications_none, color: Colors.black),
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}