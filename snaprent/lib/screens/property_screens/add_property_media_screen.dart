import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  Future<void> _pickImages() async {
    if (_mediaFiles.length >= _maxMedia) return _showLimitError();

    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      if (_mediaFiles.length + pickedFiles.length > _maxMedia)
        return _showLimitError();
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Maximum $_maxMedia media files allowed')),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one media file')),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Media uploaded successfully')),
        );
        setState(() {
          _mediaFiles.clear();
          _videoControllers.forEach((_, c) => c.dispose());
          _videoControllers.clear();
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Upload failed')));
      }
    } catch (e) {
      debugPrint('Error uploading media: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Something went wrong')));
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Property Media'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.image),
                    label: const Text('Add Images'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickVideo,
                    icon: const Icon(Icons.video_library),
                    label: const Text('Add Video'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                itemCount: _mediaFiles.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final file = _mediaFiles[index];
                  final isVideo = _videoControllers.containsKey(file.path);

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          color: Colors.black12,
                          child: isVideo
                              ? VideoPlayer(_videoControllers[file.path]!)
                              : Image.file(File(file.path), fit: BoxFit.cover),
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
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeMedia(index),
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.red,
                            child: Icon(
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
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitMedia,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Media'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
