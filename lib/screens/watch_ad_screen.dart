import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import '../models/ad_model.dart';
import '../providers/app_provider.dart';
import '../services/ad_service.dart';
import '../theme/ios_theme.dart';

class WatchAdScreen extends ConsumerStatefulWidget {
  final AdLevel level;

  const WatchAdScreen({super.key, required this.level});

  @override
  ConsumerState<WatchAdScreen> createState() => _WatchAdScreenState();
}

class _WatchAdScreenState extends ConsumerState<WatchAdScreen> {
  late ConfettiController _confettiController;
  bool _isWatching = false;
  bool _isCompleted = false;
  int _secondsRemaining = 0;
  int _totalDuration = 0;
  Timer? _timer;
  Map<String, dynamic>? _currentAd;
  final AdService _adService = AdService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _loadAd();
  }

  Future<void> _loadAd() async {
    final customAds = await _adService.getAvailableAds(widget.level);

    if (customAds.isNotEmpty) {
      _currentAd = customAds[DateTime.now().millisecond % customAds.length];
      _totalDuration = _currentAd!['durationSeconds'] ?? 30;
    } else {
      _totalDuration = _getDefaultDuration();
    }

    setState(() {
      _secondsRemaining = _totalDuration;
      _isLoading = false;
    });
  }

  int _getDefaultDuration() {
    switch (widget.level) {
      case AdLevel.oddiy:
        return 15;
      case AdLevel.orta:
        return 20;
      case AdLevel.jiddiy:
        return 30;
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startWatching() {
    setState(() {
      _isWatching = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _completeAd();
        }
      });
    });
  }

  Future<void> _completeAd() async {
    _timer?.cancel();

    final provider = ref.read(appProviderProvider.notifier);
    await provider.watchAd(widget.level);

    setState(() {
      _isWatching = false;
      _isCompleted = true;
    });

    _confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: widget.level.color,
            strokeWidth: 2,
          ),
        ),
      );
    }

    final provider = ref.watch(appProviderProvider);
    final double reward;
    if (_currentAd != null) {
      final baseReward = (_currentAd!['reward'] ?? widget.level.reward)
          .toDouble();
      reward = provider.isPremium ? baseReward * 1.5 : baseReward;
    } else {
      reward = provider.isPremium
          ? widget.level.reward * 1.5
          : widget.level.reward;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // iOS Style Top Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 22,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: widget.level.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: widget.level.color,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.level.icon,
                              color: widget.level.color,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.level.label,
                              style: TextStyle(
                                color: widget.level.color,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                fontFamily: 'SF Pro Display',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // iOS Style Timer
                if (_isWatching)
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          '$_secondsRemaining',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'SF Pro Display',
                          ),
                        ),
                        Text(
                          'soniya qoldi',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 16,
                            fontFamily: 'SF Pro Display',
                          ),
                        ),
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value:
                                (_totalDuration - _secondsRemaining) /
                                _totalDuration,
                            backgroundColor: IOSTheme.systemGray5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              widget.level.color,
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Ad Content
                Expanded(
                  child: Center(
                    child: _isCompleted
                        ? _buildSuccessView(reward)
                        : _isWatching
                        ? _buildAdView()
                        : _buildStartView(reward),
                  ),
                ),

                // iOS Style Bottom Info
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: IOSTheme.systemOrange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.attach_money,
                          color: IOSTheme.systemOrange,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+${reward.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                      if (provider.isPremium) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: IOSTheme.goldGradient[0].withValues(
                              alpha: 0.3,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.workspace_premium,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'x1.5',
                                style: TextStyle(
                                  color: Colors.amber.withValues(alpha: 0.9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.2,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartView(double reward) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: widget.level.color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: widget.level.color, width: 3),
          ),
          child: Icon(widget.level.icon, size: 60, color: widget.level.color),
        ),
        const SizedBox(height: 32),
        Text(
          widget.level.label,
          style: TextStyle(
            color: widget.level.color,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'SF Pro Display',
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Reklama davomiyligi: $_totalDuration soniya',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 16,
            fontFamily: 'SF Pro Display',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Mukofot: ${reward.toStringAsFixed(0)} so\'m',
          style: const TextStyle(
            color: Colors.amber,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'SF Pro Display',
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: _startWatching,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.level.color,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            'REKLAMANI KO\'RISH',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'SF Pro Display',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdView() {
    final adTitle = _currentAd?['title'] ?? 'Reklama';
    final adDescription = _currentAd?['description'] ?? '';
    final adImageUrl = _currentAd?['imageUrl'];

    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: widget.level.color.withValues(alpha: 0.5)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Ad Image or Icon
            if (adImageUrl != null && adImageUrl.isNotEmpty)
              Container(
                width: 200,
                height: 200,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: widget.level.color, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    adImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: widget.level.color.withValues(alpha: 0.2),
                        child: Icon(
                          Icons.image_not_supported,
                          size: 60,
                          color: widget.level.color,
                        ),
                      );
                    },
                  ),
                ),
              )
            else
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: widget.level.color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_circle_outline,
                  size: 60,
                  color: widget.level.color,
                ),
              ),
            const SizedBox(height: 20),
            // Ad Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                adTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SF Pro Display',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            // Ad Description
            if (adDescription.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  adDescription,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                    fontFamily: 'SF Pro Display',
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: widget.level.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Reklama ko\'rilmoqda...',
                style: TextStyle(
                  color: widget.level.color,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'SF Pro Display',
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ekrandan chiqmang!',
              style: TextStyle(
                color: Colors.amber.withValues(alpha: 0.9),
                fontSize: 14,
                fontFamily: 'SF Pro Display',
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView(double reward) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.green, blurRadius: 20, spreadRadius: 5),
            ],
          ),
          child: const Icon(Icons.check, size: 60, color: Colors.white),
        ),
        const SizedBox(height: 32),
        const Text(
          'Tabriklaymiz!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'SF Pro Display',
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Siz ${reward.toStringAsFixed(0)} so\'m ishlandingiz',
          style: const TextStyle(
            color: Colors.amber,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'SF Pro Display',
          ),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade800,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'YOPISH',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'SF Pro Display',
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isCompleted = false;
                  _secondsRemaining = _totalDuration;
                });
                _loadAd();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.level.color,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'YANA KO\'RISH',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'SF Pro Display',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
