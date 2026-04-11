import 'package:flutter/material.dart';
import '../theme.dart';

class Task {
  final int id;
  final String title;
  final String description;
  final DateTime date;
  final String priority; // 'High', 'Medium', 'Low'
  bool isDone;
  final String? notes;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.priority,
    this.isDone = false,
    this.notes,
  });

  // Couleur du badge (fond) selon design Bloom
  Color get priorityBgColor {
    switch (priority) {
      case 'High':   return AppTheme.priorityHighBg;
      case 'Medium': return AppTheme.priorityMediumBg;
      case 'Low':    return AppTheme.priorityLowBg;
      default:       return AppTheme.priorityMediumBg;
    }
  }

  // Couleur du texte du badge
  Color get priorityColor {
    switch (priority) {
      case 'High':   return AppTheme.priorityHighText;
      case 'Medium': return AppTheme.priorityMediumText;
      case 'Low':    return AppTheme.priorityLowText;
      default:       return AppTheme.priorityMediumText;
    }
  }

  String get priorityLabel => priority;

  // "Oct 24, 2023"
  String get formattedDate {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // "5:00 PM"
  String get formattedTime {
    final hour   = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id:          json['id'],
    title:       json['title'] ?? '',
    description: json['content'] ?? '',
    date:        json['dueDate'] != null
        ? DateTime.parse(json['dueDate'])
        : DateTime.now(),
    priority:    json['priority'] ?? 'medium',
    isDone:      false,
    notes:       json['content'],
  );

  Map<String, dynamic> toJson() => {
    'title':    title,
    'content':  notes ?? description,
    'priority': priority,
    'dueDate':  date.toIso8601String(),
  };
}