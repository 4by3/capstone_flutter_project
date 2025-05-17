import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Added for ThemeProvider
import 'package:video_player/video_player.dart';
import 'package:capstone_project/main.dart'; // Import ThemeProvider

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
    // Access ThemeProvider to determine if dark mode is enabled
    final isDarkMode = Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;
    // Define colors based on theme
    final backgroundColor = isDarkMode ? Colors.grey[900]! : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color.fromARGB(255, 24, 53, 98);
    final accentColor = isDarkMode ? Colors.grey[800]! : const Color.fromARGB(255, 24, 53, 98);
    final inactiveColor = isDarkMode ? Colors.grey[600]! : const Color.fromARGB(255, 24, 53, 98).withOpacity(0.3);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 30,
                    color: isDarkMode ? Colors.white : textColor,
                  ),
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
                              color: textColor,
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
                            style: TextStyle(
                              fontSize: 16,
                              color: textColor,
                            ),
                          ),
                          Expanded(
                            child: Slider(
                              min: 0,
                              max: _controller.value.duration.inSeconds.toDouble(),
                              value: _controller.value.position.inSeconds.toDouble(),
                              onChanged: (value) {
                                setState(() {
                                  _controller.seekTo(Duration(seconds: value.toInt()));
                                });
                              },
                              activeColor: accentColor,
                              inactiveColor: inactiveColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}