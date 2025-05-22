import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'dart:ui';
import 'package:capstone_project/main.dart';

class VideoPopup extends StatefulWidget {
  final String videoUrl;

  const VideoPopup({super.key, required this.videoUrl});

  @override
  _VideoPopupState createState() => _VideoPopupState();
}

class _VideoPopupState extends State<VideoPopup>
    with TickerProviderStateMixin {
  late VideoPlayerController _controller;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _controlsController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _controlsAnimation;

  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showControls = true;
  bool _isFullScreen = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _controlsController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
    );
    _controlsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controlsController, curve: Curves.easeInOut),
    );

    _initializeVideo();
    _fadeController.forward();
    _scaleController.forward();
    _controlsController.forward();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
        ..addListener(() {
          if (mounted) {
            setState(() {
              _isPlaying = _controller.value.isPlaying;
            });
          }
        });

      await _controller.initialize();

      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });

      _controller.play();
      _isPlaying = true;
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading video: $e'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _togglePlayPause() {
    if (_isInitialized) {
      setState(() {
        if (_isPlaying) {
          _controller.pause();
        } else {
          _controller.play();
        }
      });
    }
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  void _toggleControlsVisibility() {
    if (_showControls) {
      _controlsController.reverse();
      setState(() {
        _showControls = false;
      });
    } else {
      setState(() {
        _showControls = true;
      });
      _controlsController.forward();

      // Auto-hide controls after 3 seconds if playing
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isPlaying && _showControls) {
          _controlsController.reverse();
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _closeVideo() async {
    await _fadeController.reverse();
    await _scaleController.reverse();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _controlsController.dispose();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    if (!_isFullScreen) {
                      _closeVideo();
                    }
                  },
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 12.0 * _fadeAnimation.value,
                      sigmaY: 12.0 * _fadeAnimation.value,
                    ),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4 * _fadeAnimation.value),
                      ),
                    ),
                  ),
                ),
              ),

              Center(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _isFullScreen
                        ? _buildFullScreenVideo()
                        : _buildWindowedVideo(),
                  ),
                ),
              ),

              if (!_isFullScreen)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 40,
                  right: 30,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: GestureDetector(
                      onTap: () async {
                        await _closeVideo();
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFullScreenVideo() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_isInitialized)
            GestureDetector(
              onTap: _toggleControlsVisibility,
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            )
          else
            _buildLoadingContainer(),

          if (_isInitialized)
            _buildFullScreenControls(),
        ],
      ),
    );
  }

  Widget _buildWindowedVideo() {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    final availableWidth = screenWidth * 0.9;
    final availableHeight = screenHeight * 0.7;

    double aspectRatio = 16 / 9;
    if (_isInitialized && _controller.value.aspectRatio > 0) {
      aspectRatio = _controller.value.aspectRatio;
    }

    // Calculate optimal dimensions
    double videoWidth = availableWidth;
    double videoHeight = videoWidth / aspectRatio;

    if (videoHeight > availableHeight * 0.6) {
      videoHeight = availableHeight * 0.6;
      videoWidth = videoHeight * aspectRatio;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: videoWidth,
          height: videoHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_isInitialized)
                  GestureDetector(
                    onTap: _toggleControlsVisibility,
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _controller.value.size.width,
                          height: _controller.value.size.height,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                    ),
                  )
                else
                  _buildLoadingContainer(),

                if (_isInitialized)
                  _buildVideoControls(),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),
        Container(
          width: videoWidth,
          child: _buildExternalControls(),
        ),
      ],
    );
  }

  Widget _buildLoadingContainer() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: _isLoading
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.8)),
                strokeWidth: 2,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Loading video...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white.withOpacity(0.6),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load video',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoControls() {
    return AnimatedBuilder(
      animation: _controlsAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _showControls ? _controlsAnimation.value : 0.0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                  ),
                ),

                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _togglePlayPause,
                          borderRadius: BorderRadius.circular(30),
                          child: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.black87,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExternalControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white.withOpacity(0.3),
            thumbColor: Colors.white,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 6,
            ),
            overlayColor: Colors.white.withOpacity(0.2),
            trackHeight: 3,
          ),
          child: Slider(
            min: 0,
            max: _controller.value.duration.inSeconds.toDouble(),
            value: _controller.value.position.inSeconds.toDouble(),
            onChanged: (value) {
              _controller.seekTo(Duration(seconds: value.toInt()));
            },
          ),
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${_formatDuration(_controller.value.position)} / ${_formatDuration(_controller.value.duration)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildControlButton(
              Icons.fullscreen,
              _toggleFullScreen,
              size: 20,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFullScreenControls() {
    return AnimatedBuilder(
      animation: _controlsAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _showControls ? _controlsAnimation.value : 0.0,
          child: Container(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.4),
                      ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                  ),
                ),

                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _togglePlayPause,
                          borderRadius: BorderRadius.circular(30),
                          child: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.black87,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                        20, MediaQuery.of(context).padding.top + 20, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildControlButton(
                          Icons.close,
                              () async {
                            await _closeVideo();
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom controls
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      24,
                      8,
                      24,
                      MediaQuery.of(context).padding.bottom + 24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Progress bar
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.white,
                            inactiveTrackColor: Colors.white.withOpacity(0.3),
                            thumbColor: Colors.white,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                            overlayColor: Colors.white.withOpacity(0.2),
                            trackHeight: 3,
                          ),
                          child: Slider(
                            min: 0,
                            max: _controller.value.duration.inSeconds.toDouble(),
                            value: _controller.value.position.inSeconds.toDouble(),
                            onChanged: (value) {
                              _controller.seekTo(Duration(seconds: value.toInt()));
                            },
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Time and fullscreen controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  "${_formatDuration(_controller.value.position)} / ${_formatDuration(_controller.value.duration)}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildControlButton(
                              Icons.fullscreen_exit,
                              _toggleFullScreen,
                              size: 18,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onPressed, {double size = 22}) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(22),
          child: Icon(
            icon,
            color: Colors.white,
            size: size,
          ),
        ),
      ),
    );
  }
}