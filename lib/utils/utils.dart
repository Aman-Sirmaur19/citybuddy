import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Utils {
  static void showErrorSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: const TextStyle(color: Colors.white, letterSpacing: 1)),
        backgroundColor: Colors.red.shade900,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(msg,
                style: const TextStyle(letterSpacing: 1, color: Colors.white)),
            const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
        backgroundColor: Colors.black87,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showProgressBar(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  static Future<File?> pickSingleImage() async {
    final ImagePicker picker = ImagePicker();
    final imageFile = await picker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      return File(imageFile.path);
    }
    return null;
  }

  static Future<List<File>> pickMultipleImages() async {
    List<File> images = [];
    final ImagePicker picker = ImagePicker();
    final imageFiles = await picker.pickMultiImage();
    if (imageFiles.isNotEmpty) {
      for (final image in imageFiles) {
        images.add(File(image.path));
      }
    }
    return images;
  }

  static String formatTimeAgo(String createdAt) {
    DateTime createdTime = DateTime.parse(createdAt);
    Duration difference = DateTime.now().difference(createdTime);
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}sec ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}hr ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 365) {
      return '${difference.inDays ~/ 30}mon ago';
    } else {
      return '${difference.inDays ~/ 365}yr ago';
    }
  }
}
