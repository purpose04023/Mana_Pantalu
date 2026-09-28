import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:mana_pantalu/app/theme.dart';
import 'package:mana_pantalu/core/providers.dart';
import 'package:mana_pantalu/core/widgets.dart';
import 'package:mana_pantalu/l10n/app_localizations.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final TextEditingController _controller = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          localeId: 'te_IN',
          onResult: (val) => setState(() {
            _controller.text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.feedback),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                lang == 'te' ? 'మీ సందేశం / సమస్యను తెలపండి' : 'Share your feedback or issue',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                maxLines: 5,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.surface,
                  hintText: lang == 'te' ? 'ఇక్కడ టైప్ చేయండి లేదా మాట్లాడండి…' : 'Type or speak here…',
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: IconButton(
                  iconSize: 64,
                  icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.red : AppColors.primary),
                  onPressed: _listen,
                ),
              ),
              Center(
                child: Text(
                  _isListening
                      ? (lang == 'te' ? 'వింటోంది… పలకండి' : 'Listening… speak now')
                      : (lang == 'te' ? 'మాట్లాడేందుకు మైక్ నొక్కండి' : 'Tap mic to speak'),
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ),
              const Spacer(),
              BigButton(
                label: l10n.send,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(lang == 'te' ? 'మీ అభిప్రాయానికి ధన్యవాదాలు!' : 'Thank you for your feedback!')),
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
