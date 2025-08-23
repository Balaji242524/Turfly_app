import 'package:flutter/material.dart';

void navigateToRolePage(BuildContext context, String? role) {
  if (role == 'user') {
    Navigator.pushNamed(context, '/user/user_personal_details');
  } else if (role == 'turf_owner') {
    Navigator.pushNamed(context, '/turf_owner/turf_owner_personal_details');
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Invalid role")),
    );
  }
}
