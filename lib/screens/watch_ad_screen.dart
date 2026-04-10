import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../models/ad_model.dart';
import '../providers/app_provider.dart';
import '../services/ad_service.dart';

class WatchAdScreen extends StatefulWidget {
  final AdLevel level;

  const WatchAdScreen({super.key, required this.level});

  @override
  State<WatchAdScreen> createState() => _WatchAdScreenState();
}

class _WatchAdScreenState extends State<WatchAdScreen> {
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
    // Try to get a custom ad from admin
    final customAds = await _adService.getAvailableAds(widget.level);

    if (customAds.isNotEmpty) {
      // Pick a random custom ad
      _currentAd = customAds[DateTime.now().millisecond % customAds.length];
      _totalDuration = _currentAd!['durationSeconds'] ?? 30;
    } else {
      // Fallback to default duration
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

    final provider = context.read<AppProvider>();
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
          child: CircularProgressIndicator(color: widget.level.color),
        ),
      );
    }

    final provider = context.watch<AppProvider>();
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
                // Top Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: widget.level.color.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: widget.level.color),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.level.icon,
                              color: widget.level.color,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.level.label,
                              style: TextStyle(
                                color: widget.level.color,
                                fontWeight: FontWeight.bold,
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

                // Timer
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
                          ),
                        ),
                        const Text(
                          'soniya qoldi',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        LinearProgressIndicator(
                          value:
                              (_totalDuration - _secondsRemaining) /
                              _totalDuration,
                          backgroundColor: Colors.grey.shade800,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.level.color,
                          ),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
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

                // Bottom Info
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.attach_money, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        '+${reward.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (provider.isPremium) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.workspace_premium,
                          color: Colors.amber,
                          size: 20,
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
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: widget.level.color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: widget.level.color, width: 3),
          ),
          child: Icon(widget.level.icon, size: 80, color: widget.level.color),
        ),
        const SizedBox(height: 32),
        Text(
          widget.level.label,
          style: TextStyle(
            color: widget.level.color,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Reklama davomiyligi: $_totalDuration soniya',
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          'Mukofot: ${reward.toStringAsFixed(0)} so\'m',
          style: const TextStyle(
            color: Colors.amber,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: _startWatching,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.level.color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            'REKLAMANI KO\'RISH',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.level.color.withOpacity(0.5)),
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
                        color: widget.level.color.withOpacity(0.2),
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
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: widget.level.color.withOpacity(0.2),
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
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 20),
            Text(
              'Reklama ko\'rilmoqda...',
              style: TextStyle(
                color: widget.level.color,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ekrandan chiqmang!',
              style: TextStyle(color: Colors.amber, fontSize: 14),
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
          padding: const EdgeInsets.all(40),
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 80, color: Colors.white),
        ),
        const SizedBox(height: 32),
        const Text(
          'Tabriklaymiz!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Siz ${reward.toStringAsFixed(0)} so\'m ishlandingiz',
          style: const TextStyle(
            color: Colors.amber,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('YOPISH'),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('YANA KO\'RISH'),
            ),
          ],
        ),
      ],
    );
  }
}
