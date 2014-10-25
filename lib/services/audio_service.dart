import 'dart:async';
import 'dart:html';
import 'dart:math';
import 'dart:web_audio';
import 'package:issues_leaderboard/app_dispatcher.dart';
import 'package:issues_leaderboard/actions.dart' as actions;

initAudio() {
  var context = new AudioContext();
  var soundNames = ['whip','gunshot','yeehaw'];
  var soundBuffers = {};

  playSound(AudioBuffer buffer, [num delay = 0]) {
    AudioBufferSourceNode source = context.createBufferSource();
    source.buffer = buffer;
    source.connectNode(context.destination);
    source.start(context.currentTime + delay);
  }
  
  playGunshots(num count) {
    var baseDelay = 0.25;
    
    for (var i = 0; i < count; i++) {
      var delay = baseDelay + (new Random().nextDouble() / 10);
      playSound(soundBuffers['gunshot'], delay * i);
    }
    
    if (count >= 4)
      playSound(soundBuffers['yeehaw'], baseDelay * count);
  }

  listenForActions() {
    appDispatcher.listen((action) {
      switch (action['message']) {
        case actions.POINTS_AWARDED:
          num points = action['data'];
          playGunshots(points);
          break;
          
        case actions.DUEL_BEGAN:
          playSound(soundBuffers['whip']);
          break;
      }
    });
  }

  var soundRequests = soundNames.map((name) {
    return HttpRequest.request('/sounds/$name.wav', responseType: 'arraybuffer')
      .then((HttpRequest resp) {
        return context.decodeAudioData(resp.response).then((buffer) {
          soundBuffers[name] = buffer;
        });
      });
  });
  
  Future.wait(soundRequests).then((_) => listenForActions());
}
