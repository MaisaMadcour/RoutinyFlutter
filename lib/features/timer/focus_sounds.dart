import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

class FocusSound {
  final String id;
  final String name;
  final String? file;
  const FocusSound(this.id, this.name, this.file);
}

const kFocusSounds = <FocusSound>[
  FocusSound('none', 'بدون موسيقى', null),
  FocusSound('lofi_beat', 'إيقاع لوفاي', 'music_lofi_beat.mp3'),
  FocusSound('sleepy_lofi', 'لوفاي هادئ', 'music_sleepy_lofi.mp3'),
  FocusSound('ambient', 'أمبيانت', 'music_ambient.mp3'),
  FocusSound('focus_classic', 'تركيز كلاسيكي', 'music_focus_classic.mp3'),
  FocusSound('deep_focus', 'تركيز عميق', 'music_deep_focus.mp3'),
  FocusSound('study_lofi', 'لوفاي للدراسة', 'music_study_lofi.mp3'),
  FocusSound('focus_zone', 'منطقة التركيز', 'music_focus_zone.mp3'),
  FocusSound('focus_pop', 'بوب للتركيز', 'music_focus_pop.mp3'),
  FocusSound('inspiring', 'ملهِم', 'music_inspiring.mp3'),
  FocusSound('frequency_432hz', 'تردد 432Hz', 'music_432hz.mp3'),
];

const _kBaseUrl =
    'https://github.com/MaisaMadcour/Routiny/releases/download/music-v2/';

/// Streams calming background loops while a focus session runs.
class CalmAudioPlayer {
  final AudioPlayer _player = AudioPlayer();
  String _currentId = 'none';

  String get currentId => _currentId;
  bool get isPlaying => _player.playing;

  bool _sessionReady = false;

  // configure the OS audio session for media playback so it keeps
  // playing while the screen is locked / app is in the background
  Future<void> _ensureSession() async {
    if (_sessionReady) return;
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    await session.setActive(true);
    _sessionReady = true;
  }

  Future<void> play(FocusSound sound) async {
    _currentId = sound.id;
    if (sound.file == null) {
      await _player.stop();
      return;
    }
    try {
      await _ensureSession();
      await _player.setLoopMode(LoopMode.one);
      await _player.setUrl('$_kBaseUrl${sound.file}');
      await _player.setVolume(0.85);
      await _player.play();
    } catch (_) {
      _currentId = 'none';
      rethrow;
    }
  }

  Future<void> stop() async {
    _currentId = 'none';
    await _player.stop();
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
