import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService instance = TtsService._internal();
  TtsService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _isInit = false;
  bool isPlaying = false;
  String? currentPlayingId;

  Future<void> init() async {
    if (_isInit) return;
    try {
      await _tts.setLanguage("te-IN");
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);

      _tts.setCompletionHandler(() {
        isPlaying = false;
        currentPlayingId = null;
      });

      _tts.setErrorHandler((msg) {
        isPlaying = false;
        currentPlayingId = null;
      });

      _isInit = true;
    } catch (_) {}
  }

  Future<void> speak(String text, String id, {String lang = 'te'}) async {
    await init();
    if (isPlaying && currentPlayingId == id) {
      await stop();
      return;
    }
    await stop();
    try {
      await _tts.setLanguage(lang == 'te' ? "te-IN" : "en-IN");
      isPlaying = true;
      currentPlayingId = id;
      await _tts.speak(text);
    } catch (_) {
      isPlaying = false;
      currentPlayingId = null;
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
    isPlaying = false;
    currentPlayingId = null;
  }
}

class VoiceButton extends StatefulWidget {
  final String text;
  final String itemId;
  final String lang;

  const VoiceButton({
    super.key,
    required this.text,
    required this.itemId,
    this.lang = 'te',
  });

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton> {
  bool _playing = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        setState(() {
          _playing = !_playing;
        });
        if (_playing) {
          await TtsService.instance.speak(widget.text, widget.itemId, lang: widget.lang);
        } else {
          await TtsService.instance.stop();
        }
        if (mounted) {
          setState(() {
            _playing = TtsService.instance.isPlaying && TtsService.instance.currentPlayingId == widget.itemId;
          });
        }
      },
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _playing ? Colors.orange : const Color(0xFF2E6B3A),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _playing ? Icons.stop : Icons.volume_up,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              _playing ? 'ఆపండి' : 'వినండి',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
