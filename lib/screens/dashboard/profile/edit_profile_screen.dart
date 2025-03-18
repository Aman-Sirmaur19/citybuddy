import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../utils/utils.dart';
import '../../../widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? profileFile;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  void _selectProfileImage() async {
    final profileImage = await Utils.pickSingleImage();
    if (profileImage != null) {
      setState(() {
        profileFile = profileImage;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _bioController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.deepPurpleAccent,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Back',
            color: Colors.white,
            icon: const Icon(CupertinoIcons.chevron_back),
          ),
          title: const Text(
            'Edit Profile',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          bottom: PreferredSize(
            preferredSize: const Size(double.infinity, 94),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: _selectProfileImage,
                    child: profileFile != null
                        ? CircleAvatar(
                            backgroundImage: FileImage(profileFile!),
                            radius: 45,
                          )
                        : const CircleAvatar(
                            backgroundImage:
                                AssetImage('assets/images/avatar.png'),
                            radius: 45,
                          ),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.only(left: 8, right: 8, top: 20),
          children: [
            CustomTextField(
              controller: _nameController,
              keyboardType: TextInputType.name,
              hintText: 'Name',
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: CustomTextField(
                controller: _bioController,
                keyboardType: TextInputType.text,
                hintText: 'Bio',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
