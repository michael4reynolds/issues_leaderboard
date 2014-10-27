import 'dart:html';
import 'package:react/react.dart' as react;
import 'package:react/react_client.dart';
import 'package:issues_leaderboard/services/audio_service.dart';
import 'package:issues_leaderboard/app_dispatcher.dart';
import 'package:issues_leaderboard/components/leaderboard.dart';
import 'package:issues_leaderboard/services/github_sync_service.dart';
import 'package:issues_leaderboard/stores/issues_store.dart';
import 'package:issues_leaderboard/stores/leaderboard_store.dart';

void main() {
  // init stores
  issuesStore;
  leaderboardStore;
  
  // init services
  initAudio();
  var token = 'INSERT_YOUR_GITHUB_TOKEN';
  // var since = new DateTime.now().subtract(new Duration(days: 7));
  var since = new DateTime(2014,10,23,12);
  var githubService = new GithubSyncService(token, 'OWNER_NAME', 'REPO_NAME',
      labelName: 'bug', rangeStart: since);
  githubService.start();

  // init react
  setClientConfiguration();
  react.renderComponent(Leaderboard({'dispatcher': appDispatcher}), querySelector('#app'));
}
