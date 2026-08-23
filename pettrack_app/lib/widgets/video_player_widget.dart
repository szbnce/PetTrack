import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String token;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    required this.token,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
      httpHeaders: {'x-api-token': widget.token},
    )..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
        _controller.play();
        _controller.setLooping(true);
      }).catchError((error) {
        setState(() {
          _error = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return const Center(
        child: Icon(Icons.error_outline, color: Colors.red, size: 48),
      );
    }
    
    if (!_initialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
          child: AnimatedOpacity(
            opacity: _controller.value.isPlaying ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.play_arrow,
                size: 48,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 10,
          right: 10,
          child: VideoProgressIndicator(
            _controller,
            allowScrubbing: true,
            colors: const VideoProgressColors(
              playedColor: Colors.green,
              bufferedColor: Colors.white30,
              backgroundColor: Colors.white12,
            ),
          ),
        ),
      ],
    );
  }
}
