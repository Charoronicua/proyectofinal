import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

class HistoryItem {
  final String imagePath;
  final String recyclingInfo;
  final DateTime timestamp;

  HistoryItem({
    required this.imagePath,
    required this.recyclingInfo,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'imagePath': imagePath,
    'recyclingInfo': recyclingInfo,
    'timestamp': timestamp.toIso8601String(),
  };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
    imagePath: json['imagePath'],
    recyclingInfo: json['recyclingInfo'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

class HistoryItemCard extends StatelessWidget {
  final HistoryItem item;
  final VoidCallback onDelete;

  const HistoryItemCard({
    Key? key,
    required this.item,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
            child: Image.file(
              File(item.imagePath),
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: Icon(Icons.broken_image, size: 64, color: Colors.grey[600]),
                );
              },
            ),
          ),
          // Información
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.recyclingInfo,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(item.timestamp),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}