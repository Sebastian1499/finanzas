import 'package:flutter/material.dart';

@immutable
class AppNotification {
  final String id;
  final String title;
  final String body;
  final IconData icon;
  final Color color;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.icon,
    required this.color,
    required this.isRead,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        title: title,
        body: body,
        icon: icon,
        color: color,
        isRead: isRead ?? this.isRead,
      );
}
