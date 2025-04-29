import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPopup extends StatefulWidget {
  final String videoUrl;

  const VideoPopup({super.key, required this.videoUrl});

  @override
  _VideoPopupState createState() => _VideoPopupState();
}

class _VideoPopupState extends State<VideoPopup> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..addListener(() {
        setState(() {});
      })
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _isPlaying = true;
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const customColor = Color.fromARGB(255, 24, 53, 98);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            _controller.value.isInitialized
                ? Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Listener(
                            onPointerDown: (_) {
                              setState(() {
                                _isPlaying = !_controller.value.isPlaying;
                                _controller.value.isPlaying
                                    ? _controller.pause()
                                    : _controller.play();
                              });
                            },
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                setState(() {
                                  _isPlaying = !_controller.value.isPlaying;
                                  _controller.value.isPlaying
                                      ? _controller.pause()
                                      : _controller.play();
                                });
                              },
                              child: AspectRatio(
                                aspectRatio: _controller.value.aspectRatio,
                                child: VideoPlayer(_controller),
                              ),
                            ),
                          ),
                          if (!_controller.value.isPlaying)
                            Icon(
                              Icons.play_arrow,
                              size: 60,
                              color: Colors.white.withOpacity(0.8),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                size: 30,
                                color: customColor
                                ),
                            onPressed: () {
                              setState(() {
                                _isPlaying = !_controller.value.isPlaying;
                                _controller.value.isPlaying
                                    ? _controller.pause()
                                    : _controller.play();
                              });
                            },
                          ),
                          Text(
                            "${_controller.value.position.inMinutes}:${(_controller.value.position.inSeconds % 60).toString().padLeft(2, '0')} / "
                            "${_controller.value.duration.inMinutes}:${(_controller.value.duration.inSeconds % 60).toString().padLeft(2, '0')}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: customColor,
                              ),
                          ),
                          Expanded(
                            child: Slider(
                              min: 0,
                              max: _controller.value.duration.inSeconds
                                  .toDouble(),
                              value: _controller.value.position.inSeconds
                                  .toDouble(),
                              onChanged: (value) {
                                setState(() {
                                  _controller
                                      .seekTo(Duration(seconds: value.toInt()));
                                });
                              },
                              activeColor: customColor,
                              inactiveColor: customColor.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(customColor),
                  ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}