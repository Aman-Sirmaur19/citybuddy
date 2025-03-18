import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../../helper/api.dart';
import '../../../models/complaint_model.dart';
import '../../../providers/location_provider.dart';
import '../../../utils/utils.dart';
import '../../../widgets/custom_text_field.dart';

class PostComplaintScreen extends StatefulWidget {
  final String? title;
  final bool isCustomComplaint;

  const PostComplaintScreen({
    super.key,
    this.title,
    this.isCustomComplaint = false,
  });

  @override
  State<PostComplaintScreen> createState() => _PostComplaintScreenState();
}

class _PostComplaintScreenState extends State<PostComplaintScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _complaintController = TextEditingController();
  List<File> _images = [];
  bool _isUploading = false;

  Future<void> _sendEmail(String subject, String body, String emailId) async {
    final Email email = Email(
      body: body,
      subject: subject,
      recipients: [emailId],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
      print('Email Sent!');
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _complaintController.dispose();
  }

  void _onPickImages() async {
    _images = await Utils.pickMultipleImages();
    setState(() {});
  }

  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];
    setState(() {
      _isUploading = true; // Start uploading
    });

    try {
      for (var image in _images) {
        String fileName = '${const Uuid().v4()}.jpg';
        var ref = APIs.storage.ref().child('images/$fileName');

        await ref.putFile(image);
        String imageUrl = await ref.getDownloadURL();

        imageUrls.add(imageUrl);
      }
    } catch (e) {
      Utils.showErrorSnackBar(context, 'Error uploading images: $e');
    }

    setState(() {
      _isUploading = false; // Stop uploading
    });

    return imageUrls;
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Back',
            icon: const Icon(CupertinoIcons.chevron_back),
          ),
          title: const Text(
            'Complaint',
            style: TextStyle(fontSize: 18),
          ),
          actions: [
            ElevatedButton(
              onPressed: _isUploading
                  ? null
                  : () async {
                      if (!widget.isCustomComplaint) {
                        _subjectController.text = widget.title!;
                      }
                      if (_emailController.text.trim().isEmpty ||
                          _subjectController.text.trim().isEmpty ||
                          _complaintController.text.trim().isEmpty) {
                        Utils.showErrorSnackBar(
                            context, 'Fill all the fields.');
                        return;
                      }
                      List<String> uploadedImages = await _uploadImages();
                      ComplaintModel complaint = ComplaintModel(
                        id: const Uuid().v4(),
                        createdAt: DateTime.now().toString(),
                        senderId: APIs.user.uid,
                        receiverEmail: _emailController.text.trim(),
                        subject: _subjectController.text.trim(),
                        latitude: locationProvider.latitude.toString(),
                        longitude: locationProvider.longitude.toString(),
                        complaint: _complaintController.text.trim(),
                        complaintStatus: ComplaintStatus.pending.toString(),
                        isReplied: false,
                        upVotes: [],
                        replyIds: [],
                        imagesLink: uploadedImages,
                      );
                      try {
                        await APIs.createComplaint(complaint).then((value) {
                          Utils.showSnackBar(context, 'Posted successfully!');
                          Navigator.pop(context);
                        });
                        await _sendEmail(
                          _subjectController.text.trim(),
                          _complaintController.text.trim(),
                          _emailController.text.trim(),
                        );
                      } catch (error) {
                        Utils.showErrorSnackBar(context, error.toString());
                      }
                    },
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.deepPurpleAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Post',
                      style: TextStyle(fontSize: 15),
                    ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
              border: Border(
                  top: BorderSide(
            width: .3,
            color: Colors.grey,
          ))),
          child: Row(
            children: [
              IconButton(
                onPressed: _onPickImages,
                tooltip: 'Photo',
                color: Colors.deepPurpleAccent,
                icon: const Icon(CupertinoIcons.photo_on_rectangle),
              ),
              IconButton(
                onPressed: () {},
                tooltip: 'GIF',
                color: Colors.deepPurpleAccent,
                icon: const Icon(CupertinoIcons.collections),
              ),
              IconButton(
                onPressed: () {},
                tooltip: 'Emoji',
                color: Colors.deepPurpleAccent,
                icon: const Icon(CupertinoIcons.smiley),
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                if (widget.isCustomComplaint) ...[
                  const Text(
                    'Enter subject of complaint',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  CustomTextField(
                    controller: _subjectController,
                    keyboardType: TextInputType.text,
                    hintText: 'Subject',
                  ),
                  const SizedBox(height: 20),
                ],
                if (!widget.isCustomComplaint) ...[
                  Text(
                    widget.title!,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                ],
                const Text(
                  'Enter organization email',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                CustomTextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  hintText: 'Email',
                ),
                const SizedBox(height: 20),
                const Text(
                  'Location',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${locationProvider.city}, ${locationProvider.state}, ${locationProvider.country}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Enter your complaint',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                CustomTextField(
                  controller: _complaintController,
                  keyboardType: TextInputType.text,
                  hintText: 'Complaint',
                ),
                const SizedBox(height: 20),
                if (_images.isNotEmpty) ...[
                  const Text(
                    'Media',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  CarouselSlider(
                    items: _images.map((file) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            file,
                            fit: BoxFit.fill,
                            width: 180,
                          ),
                        ),
                      );
                    }).toList(),
                    options: CarouselOptions(
                      height: 200,
                      padEnds: false,
                      disableCenter: true,
                      enableInfiniteScroll: false,
                    ),
                  ),
                ],
              ],
            ),
            if (_isUploading)
              const Center(
                child:
                    CircularProgressIndicator(color: Colors.deepPurpleAccent),
              ),
          ],
        ),
      ),
    );
  }
}
