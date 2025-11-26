import 'package:flutter/material.dart';
import 'package:tracking_location_app/widgets/constant.dart';

Widget buildRequestLocationDialog(BuildContext context) {
  return AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    title: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: appColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.location_on, color: appColor, size: 28),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Location Permission',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'To keep you and your family safe, we need "Allow all the time" location permission.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: appColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: appColor.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPermissionBenefit(
                Icons.notifications_active,
                'Send alerts even when app is closed',
              ),
              const SizedBox(height: 8),
              _buildPermissionBenefit(
                Icons.family_restroom,
                'Keep your family informed 24/7',
              ),
              const SizedBox(height: 8),
              _buildPermissionBenefit(
                Icons.security,
                'Continuous safety monitoring',
              ),
            ],
          ),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(false),
        child: const Text(
          'Not Now',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ),
      ElevatedButton(
        onPressed: () => Navigator.of(context).pop(true),
        style: ElevatedButton.styleFrom(
          backgroundColor: appColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Allow',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    ],
  );
}

Widget _buildPermissionBenefit(IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, size: 20, color: appColor),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ),
    ],
  );
}
