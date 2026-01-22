import "package:flutter/material.dart";

class PlaceholderItem {
  final String id;
  final String section;
  final String title;
  final String subtitle;
  final IconData icon;

  const PlaceholderItem({
    required this.id,
    required this.section,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
