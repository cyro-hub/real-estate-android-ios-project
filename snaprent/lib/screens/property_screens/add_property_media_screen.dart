import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snaprent/widgets/safe_scaffold.dart';
import 'package:snaprent/widgets/snack_bar.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class AddPropertyMediaScreen extends StatefulWidget {
  final String propertyId;
  const AddPropertyMediaScreen({super.key, required this.propertyId});

  @override
  State<AddPropertyMediaScreen> createState() => _AddPropertyMediaScreenState();
}

class _AddPropertyMediaScreenState extends State<AddPropertyMediaScreen> {
  final ImagePicker _picker = ImagePicker();
  final int _maxMedia = 5;
  List<XFile> _mediaFiles = [];
  Map<String, VideoPlayerController> _videoControllers = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImages() async {
    if (_mediaFiles.length >= _maxMedia) return _showLimitError();

    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      if (_mediaFiles.length + pickedFiles.length > _maxMedia) {
        return _showLimitError();
      }
      setState(() => _mediaFiles.addAll(pickedFiles));
    }
  }

  Future<void> _pickVideo() async {
    if (_mediaFiles.length >= _maxMedia) return _showLimitError();

    final XFile? pickedVideo = await _picker.pickVideo(
      source: ImageSource.gallery,
    );
    if (pickedVideo != null) {
      if (_mediaFiles.length + 1 > _maxMedia) return _showLimitError();

      final controller = VideoPlayerController.file(File(pickedVideo.path))
        ..initialize().then((_) => setState(() {}));
      _videoControllers[pickedVideo.path] = controller;

      setState(() => _mediaFiles.add(pickedVideo));
    }
  }

  void _showLimitError() {
    SnackbarHelper.show(
      context,
      'Maximum $_maxMedia media files allowed',
      success: false,
    );
  }

  void _removeMedia(int index) {
    final file = _mediaFiles[index];
    if (_videoControllers.containsKey(file.path)) {
      _videoControllers[file.path]?.dispose();
      _videoControllers.remove(file.path);
    }
    setState(() => _mediaFiles.removeAt(index));
  }

  Future<void> _submitMedia() async {
    if (_mediaFiles.isEmpty) {
      SnackbarHelper.show(
        context,
        'Please add at least one media file',
        success: false,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://your-backend.com/api/properties/media'),
      );

      for (var file in _mediaFiles) {
        final mimeType = lookupMimeType(file.path)?.split('/');
        if (mimeType != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'media',
              file.path,
              contentType: MediaType(mimeType[0], mimeType[1]),
            ),
          );
        }
      }

      request.fields['propertyId'] = widget.propertyId;

      final response = await request.send();
      if (response.statusCode == 200) {
        SnackbarHelper.show(context, 'Media uploaded successfully');
        setState(() {
          _mediaFiles.clear();
          _videoControllers.forEach((_, c) => c.dispose());
          _videoControllers.clear();
        });
      } else {
        SnackbarHelper.show(context, 'Upload failed', success: false);
      }
    } catch (e) {
      SnackbarHelper.show(context, 'Something went wrong', success: false);
      ;
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _videoControllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeScaffold(
      child: Padding(
        padding: const EdgeInsets.only(top: 36, bottom: 16),
        child: Column(
          children: [
            // Custom Header with a title and a close button
            const Text(
              'Add Property Media',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 32),
            // Modern Media Picker Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMediaButton(
                  icon: Icons.image,
                  label: 'Add Images',
                  onPressed: _pickImages,
                ),
                _buildMediaButton(
                  icon: Icons.video_library,
                  label: 'Add Video',
                  onPressed: _pickVideo,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Media Grid with a placeholder if empty
            Expanded(
              child: _mediaFiles.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                      itemCount: _mediaFiles.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemBuilder: (context, index) {
                        final file = _mediaFiles[index];
                        final isVideo = _videoControllers.containsKey(
                          file.path,
                        );

                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: isVideo
                                  ? _buildVideoThumbnail(file.path)
                                  : Image.file(
                                      File(file.path),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            if (isVideo)
                              const Center(
                                child: Icon(
                                  Icons.play_circle_fill,
                                  color: Colors.white,
                                  size: 50,
                                ),
                              ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => _removeMedia(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            const SizedBox(height: 24),
            // Polished Submit Button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _submitMedia,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: Colors.indigo.shade600,
                  disabledBackgroundColor: Colors.grey.shade400,
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Submit Media',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // A helper method to create the modern media picker buttons.
  Widget _buildMediaButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.indigo.shade400),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // A helper method for the empty state UI.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No media added yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add images or videos to display here',
            style: TextStyle(color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  // Helper method to display video thumbnail.
  Widget _buildVideoThumbnail(String filePath) {
    final controller = _videoControllers[filePath];
    if (controller != null && controller.value.isInitialized) {
      return SizedBox(
        width: controller.value.size.width,
        height: controller.value.size.height,
        child: VideoPlayer(controller),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }
}
