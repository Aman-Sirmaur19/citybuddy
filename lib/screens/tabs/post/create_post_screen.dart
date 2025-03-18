import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../../helper/api.dart';
import '../../../models/post_model.dart';
import '../../../providers/location_provider.dart';
import '../../../utils/utils.dart';

class CreatePostScreen extends StatefulWidget {
  final String userId;
  final String tweetId;

  const CreatePostScreen(
      {super.key, required this.userId, required this.tweetId});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _postController = TextEditingController();
  List<File> _images = [];
  bool _isUploading = false; // Track upload state

  @override
  void dispose() {
    super.dispose();
    _postController.dispose();
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Back',
            icon: const Icon(CupertinoIcons.chevron_back),
          ),
          actions: [
            ElevatedButton(
              onPressed: _isUploading
                  ? null
                  : () async {
                      if (_postController.text.trim().isEmpty) {
                        Utils.showErrorSnackBar(
                            context,
                            widget.userId.isNotEmpty
                                ? 'Write something to reply.'
                                : 'Write something to post.');
                        return;
                      }
                      final locationProvider =
                          Provider.of<LocationProvider>(context, listen: false);
                      List<String> uploadedImages = await _uploadImages();
                      PostModel post = PostModel(
                        id: const Uuid().v4(),
                        createdAt: DateTime.now().toString(),
                        senderId: APIs.user.uid,
                        receiverId: widget.userId,
                        latitude: locationProvider.latitude.toString(),
                        longitude: locationProvider.longitude.toString(),
                        message: _postController.text.trim(),
                        isReplied: widget.userId.isNotEmpty ? true : false,
                        upVotes: [],
                        replyIds: [],
                        imagesLink: uploadedImages,
                      );
                      try {
                        if (widget.userId.isEmpty) {
                          await APIs.createPost(post).then((value) {
                            Utils.showSnackBar(context, 'Posted successfully!');
                          });
                        } else {
                          await APIs.replyPost(post, widget.tweetId);
                        }
                        Navigator.pop(context);
                      } catch (error) {
                        Utils.showErrorSnackBar(context, error.toString());
                      }
                    },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.deepPurpleAccent,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      widget.userId.isNotEmpty ? 'Reply' : 'Post',
                      style: const TextStyle(fontSize: 15),
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      backgroundImage: AssetImage('assets/images/avatar.png'),
                      radius: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _postController,
                        keyboardType: TextInputType.multiline,
                        cursorColor: Colors.deepPurpleAccent,
                        maxLines: null,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          hintText: 'Write something...',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
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
